#!/bin/bash

MEMORY_DIR="$(cd "$(dirname "$0")/../.." && pwd)/Memory"
DAILY_DIR="$MEMORY_DIR/daily"
TODAY="$(date +%Y-%m-%d)"
DAILY_FILE="$DAILY_DIR/$TODAY.md"

cat <<'EOF'
==============================
PRE-COMPACT: SAVE CONTEXT NOW
==============================

The conversation is about to be compacted. Before context is lost, you MUST:

1. SCAN this conversation for:
   - Decisions made (technical choices, approaches agreed on)
   - Facts learned about the user, clients, or project
   - Tasks started or completed
   - Anything that should persist beyond this conversation

2. APPEND non-trivial items to today's daily log using the Write or Edit tool:
   Format: - [HH:MM] <brief description of what happened/was decided>

3. UPDATE Memory/MEMORY.md if any long-lived facts emerged:
   - New clients or projects
   - Key architectural decisions
   - Important preferences or constraints
   - Lessons learned

4. If nothing significant happened, write a single line:
   - [HH:MM] [compact] Session active, no new facts to record.

Daily log path:
EOF

echo "   $DAILY_FILE"
echo ""
echo "Do this NOW before responding to anything else."
echo "=============================="

# Auto-extract facts from daily log in the background (non-blocking)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
bash "$SCRIPT_DIR/consolidate.sh" &
