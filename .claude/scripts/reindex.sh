#!/bin/bash
# reindex.sh — Re-index Memory/ files after any write/edit.
# Called automatically by the PostToolUse hook.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Only reindex if the modified file is inside Memory/
# CLAUDE_TOOL_INPUT_FILE_PATH is set by the PostToolUse hook
if [ -n "$CLAUDE_TOOL_INPUT_FILE_PATH" ]; then
  case "$CLAUDE_TOOL_INPUT_FILE_PATH" in
    *Memory/*) ;;  # proceed
    *) exit 0 ;;   # not a memory file, skip
  esac
fi

cd "$PROJECT_ROOT" || exit 1

VENV_PYTHON="$PROJECT_ROOT/.venv/bin/python3"

# Run indexer using venv Python
if [ -f "$VENV_PYTHON" ] && [ -f "$SCRIPT_DIR/memory_index.py" ]; then
  "$VENV_PYTHON" "$SCRIPT_DIR/memory_index.py" 2>/dev/null
fi
