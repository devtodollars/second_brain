#!/bin/bash

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
MEMORY_DIR="$ROOT_DIR/Memory"
DAILY_DIR="$MEMORY_DIR/daily"

# Load .env if present
if [ -f "$ROOT_DIR/.env" ]; then
  set -a
  # shellcheck disable=SC1091
  source "$ROOT_DIR/.env"
  set +a
fi
TODAY="$(date +%Y-%m-%d)"
DAILY_FILE="$DAILY_DIR/$TODAY.md"
PENDING_FILE="$MEMORY_DIR/.pending_sessions.txt"

# Create today's daily log if it doesn't exist
if [ ! -f "$DAILY_FILE" ]; then
  cat > "$DAILY_FILE" <<EOF
# Daily Log - $TODAY

_Append-only log. Add entries with timestamps as the day progresses._

EOF

  # Carry over unchecked todos from yesterday into today's log
  YESTERDAY="$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d 'yesterday' +%Y-%m-%d 2>/dev/null)"
  YESTERDAY_FILE="$DAILY_DIR/$YESTERDAY.md"

  if [ -f "$YESTERDAY_FILE" ]; then
    python3 - "$YESTERDAY_FILE" "$DAILY_FILE" <<'PYEOF'
import sys, re

src = sys.argv[1]
dst = sys.argv[2]

with open(src) as f:
    lines = f.readlines()

# Collect unchecked todos grouped by section header
sections = {}   # header -> [todo lines]
order = []      # preserve section order
current = None

for line in lines:
    stripped = line.rstrip()
    if re.match(r'^#{1,3} ', stripped):
        current = stripped
        # only track sections that have todos
    elif re.match(r'^- \[ \] ', stripped) and current is not None:
        if current not in sections:
            sections[current] = []
            order.append(current)
        sections[current].append(stripped)

if not sections:
    sys.exit(0)

# Append to today's log
with open(dst, 'a') as f:
    for header in order:
        f.write(f"\n{header}\n\n")
        for todo in sections[header]:
            f.write(f"{todo}\n")
PYEOF
  fi
fi

# Process any pending session summaries from previous sessions
if [ -f "$PENDING_FILE" ]; then
  # Deduplicate lines (multiple stops in same session write the same transcript path)
  UNIQUE_SESSIONS=$(sort -u "$PENDING_FILE")
  rm "$PENDING_FILE"

  export SESSION_END_HOOK_RUNNING=1

  while IFS='|' read -r SESSION_DATE TRANSCRIPT_PATH; do
    [ -z "$TRANSCRIPT_PATH" ] || [ ! -f "$TRANSCRIPT_PATH" ] && continue

    # Extract recent conversation from JSONL transcript
    RECENT=$(python3 - "$TRANSCRIPT_PATH" <<'PYEOF'
import sys, json

transcript_path = sys.argv[1]
messages = []

try:
    with open(transcript_path) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                d = json.loads(line)
                msg_type = d.get('type', '')
                if msg_type not in ('user', 'assistant'):
                    continue
                content = d.get('message', {}).get('content', '')
                if isinstance(content, list):
                    text_parts = [
                        c.get('text', '') for c in content
                        if isinstance(c, dict) and c.get('type') == 'text'
                    ]
                    text = ' '.join(text_parts)
                else:
                    text = str(content)
                text = text.strip()[:600]
                if text:
                    messages.append(f"{msg_type.upper()}: {text}")
            except:
                pass
except:
    pass

print('\n\n'.join(messages[-12:]))
PYEOF
)

    [ -z "$RECENT" ] && continue

    # Summarize the session with Haiku
    SUMMARY=$(printf 'Summarize what was accomplished in this Claude Code session in ONE concise sentence (max 20 words). Be specific. Output only the summary, nothing else.\n\n---\n%s\n---' "$RECENT" | \
      claude -p --model claude-haiku-4-5-20251001 2>/dev/null | head -1)

    TARGET_LOG="$DAILY_DIR/$SESSION_DATE.md"
    if [ -n "$SUMMARY" ] && [ -f "$TARGET_LOG" ]; then
      TIMESTAMP=$(date +%H:%M)
      echo "- [$TIMESTAMP] $SUMMARY" >> "$TARGET_LOG"
    fi
  done <<< "$UNIQUE_SESSIONS"
fi

# Inject memory files as context
echo "=============================="
echo "SECOND BRAIN CONTEXT LOADED"
echo "=============================="
echo ""

echo "--- SOUL.md ---"
cat "$MEMORY_DIR/SOUL.md"
echo ""

echo "--- USER.md ---"
cat "$MEMORY_DIR/USER.md"
echo ""

echo "--- MEMORY.md ---"
cat "$MEMORY_DIR/MEMORY.md"
echo ""

echo "--- TODAY'S LOG ($TODAY) ---"
cat "$DAILY_FILE"
echo ""

# Also show yesterday's log if it exists (for continuity)
YESTERDAY="$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d 'yesterday' +%Y-%m-%d 2>/dev/null)"
YESTERDAY_FILE="$DAILY_DIR/$YESTERDAY.md"
if [ -f "$YESTERDAY_FILE" ]; then
  echo "--- YESTERDAY'S LOG ($YESTERDAY) ---"
  cat "$YESTERDAY_FILE"
  echo ""
fi

echo "=============================="
echo "END OF CONTEXT"
echo "=============================="
