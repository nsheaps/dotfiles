#!/usr/bin/env bash
# Reminder after editing todo.md

cat >&2 <<'EOF'
<system>
Todo list updated! Remember:
- todo.md is the SOURCE OF TRUTH (persistent across sessions)
- TodoWrite is just a temporary in-memory snapshot (gets cleared on restart)
- They are EXPECTED to be out of sync - this is normal!
- Always update todo.md regardless of TodoWrite usage
- Mark tasks as completed when done (with commit links if applicable)
- Document any sidequests or tangential work
- Consider running /commit if significant changes were made
</system>
EOF

exit 2
