#!/usr/bin/env bash
# Helper script to read questions.md only if it has changed

QUESTIONS_FILE=".ai/scratch/questions.md"
HASH_FILE=".repo/hashes.yaml"

# Exit early if questions.md doesn't exist
if [[ ! -f "$QUESTIONS_FILE" ]]; then
  exit 0
fi

# Ensure the hash file directory exists
HASH_DIR="$(dirname "$HASH_FILE")"
if [[ ! -d "$HASH_DIR" ]]; then
  mkdir -p "$HASH_DIR" 2>/dev/null || exit 0
fi

# Get current SHA256 hash
CURRENT_HASH=$(shasum -a 256 "$QUESTIONS_FILE" 2>/dev/null | awk '{print $1}')
if [[ -z "$CURRENT_HASH" ]]; then
  exit 0
fi

# Read previous hash from YAML file
PREV_HASH=""
if [[ -f "$HASH_FILE" ]]; then
  PREV_HASH=$(grep "^${QUESTIONS_FILE}:" "$HASH_FILE" 2>/dev/null | awk '{print $2}')
fi

# If file has changed, output to stderr and update hash
if [[ "$CURRENT_HASH" != "$PREV_HASH" ]]; then
  # Update or add hash in YAML file
  if [[ -f "$HASH_FILE" ]] && grep -q "^${QUESTIONS_FILE}:" "$HASH_FILE" 2>/dev/null; then
    # Update existing entry
    sed -i.bak "s|^${QUESTIONS_FILE}:.*|${QUESTIONS_FILE}: ${CURRENT_HASH}|" "$HASH_FILE" 2>/dev/null
    rm -f "${HASH_FILE}.bak" 2>/dev/null
  else
    # Add new entry (create file if it doesn't exist)
    echo "${QUESTIONS_FILE}: ${CURRENT_HASH}" >> "$HASH_FILE" 2>/dev/null
  fi

  # Output to stderr so Claude sees it
  cat >&2 <<EOF
The questions file at .ai/scratch/questions.md has been updated. Please read it using the Read tool to check for:
1. New questions from the user that need answers
2. User answers to your previous questions

Read the file at: .ai/scratch/questions.md
EOF
fi
