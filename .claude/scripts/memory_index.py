#!/usr/bin/env python3
"""
memory_index.py — Index Memory/ markdown files into SQLite for hybrid search.

Usage:
    python .claude/scripts/memory_index.py

Creates/updates Memory/.index/memory.db with:
  - chunks table: id, source, heading, content, embedding (via sqlite-vec)
  - chunks_fts: FTS5 virtual table for keyword search
"""

import os
import re
import sqlite3
import json
import sys
from pathlib import Path

MEMORY_DIR = Path(__file__).parent.parent.parent / "Memory"
INDEX_DIR = MEMORY_DIR / ".index"
DB_PATH = INDEX_DIR / "memory.db"


def get_markdown_files(memory_dir: Path) -> list[Path]:
    files = []
    for path in memory_dir.rglob("*.md"):
        # Skip the index directory itself
        if ".index" in path.parts:
            continue
        files.append(path)
    return sorted(files)


def chunk_markdown(text: str, source: str) -> list[dict]:
    """Split markdown into chunks by heading or paragraph block."""
    chunks = []
    current_heading = ""
    current_lines = []

    def flush(heading, lines):
        content = "\n".join(lines).strip()
        if content and len(content) > 20:
            chunks.append({
                "source": source,
                "heading": heading,
                "content": content,
            })

    for line in text.splitlines():
        heading_match = re.match(r"^#{1,3}\s+(.+)", line)
        if heading_match:
            flush(current_heading, current_lines)
            current_heading = heading_match.group(1)
            current_lines = []
        else:
            current_lines.append(line)

    flush(current_heading, current_lines)
    return chunks


def embed_chunks(chunks: list[dict]) -> list[dict]:
    """Add embeddings to chunks using FastEmbed."""
    try:
        from fastembed import TextEmbedding
    except ImportError:
        print("fastembed not installed. Run: pip install fastembed", file=sys.stderr)
        print("Indexing without embeddings (keyword-only search).", file=sys.stderr)
        for chunk in chunks:
            chunk["embedding"] = None
        return chunks

    model = TextEmbedding(model_name="BAAI/bge-small-en-v1.5")
    texts = [f"{c['heading']} {c['content']}" for c in chunks]
    embeddings = list(model.embed(texts))

    for chunk, emb in zip(chunks, embeddings):
        chunk["embedding"] = emb.tolist()

    return chunks


def setup_db(conn: sqlite3.Connection, embedding_dim: int):
    conn.execute("DROP TABLE IF EXISTS chunks")
    conn.execute("DROP TABLE IF EXISTS chunks_fts")

    conn.execute("""
        CREATE TABLE chunks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            source TEXT NOT NULL,
            heading TEXT,
            content TEXT NOT NULL,
            embedding TEXT
        )
    """)

    conn.execute("""
        CREATE VIRTUAL TABLE chunks_fts USING fts5(
            source,
            heading,
            content,
            content='chunks',
            content_rowid='id'
        )
    """)

    conn.commit()


def insert_chunks(conn: sqlite3.Connection, chunks: list[dict]):
    for chunk in chunks:
        embedding_json = json.dumps(chunk["embedding"]) if chunk.get("embedding") else None
        conn.execute(
            "INSERT INTO chunks (source, heading, content, embedding) VALUES (?, ?, ?, ?)",
            (chunk["source"], chunk["heading"], chunk["content"], embedding_json)
        )

    # Populate FTS index
    conn.execute("""
        INSERT INTO chunks_fts(rowid, source, heading, content)
        SELECT id, source, heading, content FROM chunks
    """)
    conn.commit()


def main():
    INDEX_DIR.mkdir(parents=True, exist_ok=True)

    files = get_markdown_files(MEMORY_DIR)
    if not files:
        print("No markdown files found in Memory/")
        return

    print(f"Indexing {len(files)} file(s)...")
    all_chunks = []
    for path in files:
        rel = str(path.relative_to(MEMORY_DIR.parent))
        text = path.read_text(encoding="utf-8")
        chunks = chunk_markdown(text, rel)
        all_chunks.extend(chunks)
        print(f"  {rel}: {len(chunks)} chunk(s)")

    print(f"Embedding {len(all_chunks)} chunk(s)...")
    all_chunks = embed_chunks(all_chunks)

    embedding_dim = len(all_chunks[0]["embedding"]) if all_chunks[0].get("embedding") else 0

    conn = sqlite3.connect(DB_PATH)
    setup_db(conn, embedding_dim)
    insert_chunks(conn, all_chunks)
    conn.close()

    print(f"Index written to {DB_PATH}")


if __name__ == "__main__":
    main()
