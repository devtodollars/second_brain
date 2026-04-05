#!/bin/bash

MEMORY_DIR="$(cd "$(dirname "$0")/../.." && pwd)/Memory"
DAILY_DIR="$MEMORY_DIR/daily"
TODAY="$(date +%Y-%m-%d)"
DAILY_FILE="$DAILY_DIR/$TODAY.md"
TIMESTAMP="$(date +%H:%M)"

# Only append if the daily log exists
if [ ! -f "$DAILY_FILE" ]; then
  exit 0
fi

# Append a session-end marker with timestamp
echo "- [$TIMESTAMP] [session-end] Turn complete." >> "$DAILY_FILE"
