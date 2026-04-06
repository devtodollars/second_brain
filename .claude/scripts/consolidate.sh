#!/bin/bash
# consolidate.sh — Extract long-lived facts from today's daily log and append to MEMORY.md.
# Safe to run multiple times: idempotent via a per-day hash stamp.
# Called from pre-compact.sh (background) and optionally a daily cron.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MEMORY_DIR="$PROJECT_ROOT/Memory"
DAILY_DIR="$MEMORY_DIR/daily"
MEMORY_FILE="$MEMORY_DIR/MEMORY.md"
TODAY="$(date +%Y-%m-%d)"
DAILY_FILE="$DAILY_DIR/$TODAY.md"
STAMP_DIR="$MEMORY_DIR/.index"
STAMP_FILE="$STAMP_DIR/consolidate-last-run.txt"
LOCK_FILE="/tmp/consolidate-memory.lock"

# ── Guard 1: daily log must exist ─────────────────────────────────────────
if [ ! -f "$DAILY_FILE" ]; then
  exit 0
fi

# ── Guard 2: daily log must have substantive content ──────────────────────
# Count lines that are NOT blank, headers, template text, or session-end markers
SUBSTANTIVE=$(grep -cv \
  -e '^\s*$' \
  -e '^#' \
  -e '_Append-only' \
  -e '\[session-end\]' \
  -e '\[session-start\]' \
  "$DAILY_FILE" 2>/dev/null || true)

if [ "${SUBSTANTIVE:-0}" -lt 1 ]; then
  exit 0
fi

# ── Guard 3: idempotency — skip if log unchanged since last run ───────────
mkdir -p "$STAMP_DIR"
DAILY_HASH=$(md5 -q "$DAILY_FILE" 2>/dev/null || md5sum "$DAILY_FILE" 2>/dev/null | awk '{print $1}')
if [ -f "$STAMP_FILE" ]; then
  LAST_HASH=$(cat "$STAMP_FILE")
  if [ "$DAILY_HASH" = "$LAST_HASH" ]; then
    exit 0
  fi
fi

# ── Guard 4: prevent concurrent runs ──────────────────────────────────────
if [ -f "$LOCK_FILE" ]; then
  exit 0
fi
touch "$LOCK_FILE"
trap 'rm -f "$LOCK_FILE"' EXIT

# ── Read source files ──────────────────────────────────────────────────────
MEMORY_CONTENT=$(cat "$MEMORY_FILE")
DAILY_CONTENT=$(cat "$DAILY_FILE")

# ── Build extraction prompt ────────────────────────────────────────────────
PROMPT="You are a memory extraction assistant for a personal second brain system.

CURRENT MEMORY.md:
---
${MEMORY_CONTENT}
---

TODAY'S DAILY LOG (${TODAY}):
---
${DAILY_CONTENT}
---

TASK: Identify NEW long-lived facts in the daily log that are NOT already in MEMORY.md.

Long-lived facts: new clients, projects, technical decisions, architectural choices, lessons learned, important preferences or constraints, recurring patterns.
NOT long-lived: routine activity, session markers, task completions with no broader significance, one-off events.

OUTPUT FORMAT — respond with ONLY this structure (omit any section with nothing new):

ACTIVE_PROJECTS:
- <self-contained fact about an active project>

KEY_DECISIONS:
- <self-contained technical or business decision>

LESSONS_LEARNED:
- <self-contained lesson or insight>

IMPORTANT_FACTS:
- <self-contained fact about the user, business, or context>

NONE

Rules:
- If nothing new warrants memory, output exactly: NONE
- Each bullet must be self-contained (include enough context, no pronouns like 'he/it/they')
- Maximum 2 bullets per section
- Never repeat anything already in MEMORY.md
- Never invent facts not supported by the log"

# ── Call claude --print with Haiku ─────────────────────────────────────────
EXTRACTION=$(echo "$PROMPT" | claude --print --model claude-haiku-4-5 2>/dev/null) || {
  # Claude call failed — fail silently, don't corrupt MEMORY.md
  exit 0
}

# ── Check for NONE response ────────────────────────────────────────────────
if echo "$EXTRACTION" | grep -q "^NONE$"; then
  echo "$DAILY_HASH" > "$STAMP_FILE"
  exit 0
fi

# ── Parse section bullets from extraction output ───────────────────────────
extract_section() {
  local tag="$1"
  echo "$EXTRACTION" | awk "/^${tag}:/{found=1; next} found && /^[A-Z_]+:/{found=0} found && /^- /{print}"
}

PROJECTS=$(extract_section "ACTIVE_PROJECTS")
DECISIONS=$(extract_section "KEY_DECISIONS")
LESSONS=$(extract_section "LESSONS_LEARNED")
FACTS=$(extract_section "IMPORTANT_FACTS")

# ── Append bullets to MEMORY.md using Python ──────────────────────────────
APPENDED=0

append_to_section() {
  local section_header="$1"
  local placeholder="$2"
  local new_bullets="$3"

  if [ -z "$new_bullets" ]; then
    return
  fi

  python3 - "$MEMORY_FILE" "$section_header" "$placeholder" "$new_bullets" <<'PYEOF'
import sys

filepath    = sys.argv[1]
header      = sys.argv[2]
placeholder = sys.argv[3]
new_bullets = sys.argv[4].rstrip('\n')

with open(filepath, 'r') as f:
    content = f.read()

# Case 1: section has placeholder — replace it
placeholder_block = f"{header}\n\n{placeholder}"
if placeholder_block in content:
    content = content.replace(placeholder_block, f"{header}\n\n{new_bullets}")
    with open(filepath, 'w') as f:
        f.write(content)
    sys.exit(0)

# Case 2: section already has content — append bullets before next ## heading
lines  = content.splitlines(keepends=True)
result = []
in_section = False
inserted   = False

for line in lines:
    if line.strip() == header.strip():
        in_section = True
        result.append(line)
        continue
    if in_section and not inserted and line.startswith('## '):
        # Insert bullets before this next section heading
        result.append(new_bullets + '\n')
        in_section = False
        inserted   = True
    result.append(line)

# If section was last in file
if in_section and not inserted:
    result.append(new_bullets + '\n')

with open(filepath, 'w') as f:
    f.writelines(result)
PYEOF

  APPENDED=1
}

[ -n "$PROJECTS"  ] && append_to_section "## Active Projects"  "_Nothing tracked yet._"  "$PROJECTS"
[ -n "$DECISIONS" ] && append_to_section "## Key Decisions"    "_Nothing recorded yet._" "$DECISIONS"
[ -n "$LESSONS"   ] && append_to_section "## Lessons Learned"  "_Nothing recorded yet._" "$LESSONS"
[ -n "$FACTS"     ] && append_to_section "## Important Facts"  "_Nothing recorded yet._" "$FACTS"

# ── Save hash stamp ────────────────────────────────────────────────────────
echo "$DAILY_HASH" > "$STAMP_FILE"

# ── Reindex if anything was written ───────────────────────────────────────
if [ "$APPENDED" -eq 1 ]; then
  VENV_PYTHON="$PROJECT_ROOT/.venv/bin/python3"
  if [ -f "$VENV_PYTHON" ] && [ -f "$SCRIPT_DIR/memory_index.py" ]; then
    "$VENV_PYTHON" "$SCRIPT_DIR/memory_index.py" 2>/dev/null || true
  fi
fi
