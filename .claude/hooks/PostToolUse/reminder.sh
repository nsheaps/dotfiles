#!/usr/bin/env bash
# Debounced reminder to keep scratch files up to date

STATE_FILE=".repo/last-reminder-time"
DEBOUNCE_SECONDS=10

# Ensure state directory exists
STATE_DIR="$(dirname "$STATE_FILE")"
if [[ ! -d "$STATE_DIR" ]]; then
  mkdir -p "$STATE_DIR" 2>/dev/null || exit 0
fi

# Get current time
CURRENT_TIME=$(date +%s)

# Read last execution time
LAST_TIME=0
if [[ -f "$STATE_FILE" ]]; then
  LAST_TIME=$(cat "$STATE_FILE" 2>/dev/null || echo "0")
fi

# Calculate time difference
TIME_DIFF=$((CURRENT_TIME - LAST_TIME))

# Only show reminder if debounce period has passed
if [[ $TIME_DIFF -ge $DEBOUNCE_SECONDS ]]; then
  # Update state file
  echo "$CURRENT_TIME" > "$STATE_FILE" 2>/dev/null

  # Output reminder to stderr
  cat >&2 <<EOF
<system>
  Don't forget to keep these files up to date:
  - .ai/scratch/questions.md
  - .ai/scratch/todo.md (SOURCE OF TRUTH - TodoWrite is just a temp snapshot)
  - .ai/scratch/plan.md

  You should _ALWAYS_ be updating the todo.md file with tasks you do, regardless of your use of Todo and TodoWrite.
  TodoWrite and todo.md are EXPECTED to be out of sync - this is normal! TodoWrite gets cleared on restart.

  <CRITICAL>
    If you update these files, use SlashCommand:/commit to analyze the changes, make a commit, then push your changes.
  </CRITICAL>
</system>
EOF

exit 2
fi
