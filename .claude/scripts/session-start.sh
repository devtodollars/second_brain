#!/bin/bash

MEMORY_DIR="$(cd "$(dirname "$0")/../.." && pwd)/Memory"
DAILY_DIR="$MEMORY_DIR/daily"
TODAY="$(date +%Y-%m-%d)"
DAILY_FILE="$DAILY_DIR/$TODAY.md"

# Create today's daily log if it doesn't exist
if [ ! -f "$DAILY_FILE" ]; then
  cat > "$DAILY_FILE" <<EOF
# Daily Log - $TODAY

_Append-only log. Add entries with timestamps as the day progresses._

EOF
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
