#!/usr/bin/env python3
"""
memory_search.py — Hybrid semantic + keyword search over indexed memory.

Usage:
    python .claude/scripts/memory_search.py "your query here" [--top 5]

Returns top-N relevant chunks with source file and content snippet.
Hybrid score = 0.7 * vector_similarity + 0.3 * keyword_rank
Falls back to keyword-only if embeddings are unavailable.
"""

import argparse
import json
import math
import sqlite3
import sys
from pathlib import Path
from typing import Optional

MEMORY_DIR = Path(__file__).parent.parent.parent / "Memory"
DB_PATH = MEMORY_DIR / ".index" / "memory.db"

VECTOR_WEIGHT = 0.7
KEYWORD_WEIGHT = 0.3


def cosine_similarity(a: list[float], b: list[float]) -> float:
    dot = sum(x * y for x, y in zip(a, b))
    mag_a = math.sqrt(sum(x * x for x in a))
    mag_b = math.sqrt(sum(x * x for x in b))
    if mag_a == 0 or mag_b == 0:
        return 0.0
    return dot / (mag_a * mag_b)


def embed_query(query: str) -> Optional[list]:
    try:
        from fastembed import TextEmbedding
        model = TextEmbedding(model_name="BAAI/bge-small-en-v1.5")
        return list(list(model.embed([query]))[0])
    except ImportError:
        return None


def keyword_search(conn: sqlite3.Connection, query: str, top_k: int) -> dict[int, float]:
    """FTS5 search — returns {rowid: normalized_rank}"""
    try:
        rows = conn.execute(
            """
            SELECT rowid, rank
            FROM chunks_fts
            WHERE chunks_fts MATCH ?
            ORDER BY rank
            LIMIT ?
            """,
            (query, top_k * 3),
        ).fetchall()
    except sqlite3.OperationalError:
        return {}

    if not rows:
        return {}

    # FTS5 rank is negative (lower = better), normalize to [0, 1]
    ranks = [abs(r) for _, r in rows]
    max_rank = max(ranks) if ranks else 1
    return {rowid: 1.0 - (abs(rank) / max_rank) for rowid, rank in rows}


def vector_search(conn: sqlite3.Connection, query_emb: list[float], top_k: int) -> dict[int, float]:
    """Brute-force cosine similarity over all stored embeddings."""
    rows = conn.execute(
        "SELECT id, embedding FROM chunks WHERE embedding IS NOT NULL"
    ).fetchall()

    scores = {}
    for row_id, emb_json in rows:
        emb = json.loads(emb_json)
        scores[row_id] = cosine_similarity(query_emb, emb)

    return dict(sorted(scores.items(), key=lambda x: x[1], reverse=True)[:top_k * 3])


def hybrid_search(query: str, top_k: int) -> list[dict]:
    if not DB_PATH.exists():
        print(f"Index not found at {DB_PATH}. Run memory_index.py first.", file=sys.stderr)
        sys.exit(1)

    conn = sqlite3.connect(DB_PATH)

    kw_scores = keyword_search(conn, query, top_k)
    query_emb = embed_query(query)
    vec_scores = vector_search(conn, query_emb, top_k) if query_emb else {}

    # Combine all candidate IDs
    all_ids = set(kw_scores) | set(vec_scores)

    combined = {}
    for row_id in all_ids:
        kw = kw_scores.get(row_id, 0.0)
        vec = vec_scores.get(row_id, 0.0)
        if vec_scores:
            combined[row_id] = VECTOR_WEIGHT * vec + KEYWORD_WEIGHT * kw
        else:
            combined[row_id] = kw

    top_ids = sorted(combined, key=lambda x: combined[x], reverse=True)[:top_k]

    if not top_ids:
        conn.close()
        return []

    placeholders = ",".join("?" * len(top_ids))
    rows = conn.execute(
        f"SELECT id, source, heading, content FROM chunks WHERE id IN ({placeholders})",
        top_ids,
    ).fetchall()
    conn.close()

    row_map = {r[0]: r for r in rows}
    results = []
    for row_id in top_ids:
        if row_id not in row_map:
            continue
        _, source, heading, content = row_map[row_id]
        results.append({
            "score": round(combined[row_id], 4),
            "source": source,
            "heading": heading or "(top level)",
            "snippet": content[:300].replace("\n", " "),
        })

    return results


def main():
    parser = argparse.ArgumentParser(description="Search memory files")
    parser.add_argument("query", help="Search query")
    parser.add_argument("--top", type=int, default=5, help="Number of results (default: 5)")
    args = parser.parse_args()

    results = hybrid_search(args.query, args.top)

    if not results:
        print("No results found.")
        return

    for i, r in enumerate(results, 1):
        print(f"\n[{i}] score={r['score']} | {r['source']} — {r['heading']}")
        print(f"    {r['snippet']}")


if __name__ == "__main__":
    main()
