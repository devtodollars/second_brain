#!/bin/bash

# Prevent recursive calls from the claude -p invocation in session-start
if [ -n "$SESSION_END_HOOK_RUNNING" ]; then
  exit 0
fi

MEMORY_DIR="$(cd "$(dirname "$0")/../.." && pwd)/Memory"
PENDING_FILE="$MEMORY_DIR/.pending_sessions.txt"
DATE=$(date +%Y-%m-%d)

# Read hook payload from stdin and extract transcript path
PAYLOAD=$(cat)
TRANSCRIPT_PATH=$(echo "$PAYLOAD" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('transcript_path', ''))
except:
    print('')
" 2>/dev/null)

# Append date|transcript_path to the pending file (one line per session stop)
if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
  echo "$DATE|$TRANSCRIPT_PATH" >> "$PENDING_FILE"
fi
