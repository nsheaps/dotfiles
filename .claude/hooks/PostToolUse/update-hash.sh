#!/usr/bin/env bash
# Updates hash after editing questions.md to prevent double notifications

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

# Update or add hash in YAML file
if [[ -f "$HASH_FILE" ]] && grep -q "^${QUESTIONS_FILE}:" "$HASH_FILE" 2>/dev/null; then
  # Update existing entry
  sed -i.bak "s|^${QUESTIONS_FILE}:.*|${QUESTIONS_FILE}: ${CURRENT_HASH}|" "$HASH_FILE" 2>/dev/null
  rm -f "${HASH_FILE}.bak" 2>/dev/null
else
  # Add new entry
  echo "${QUESTIONS_FILE}: ${CURRENT_HASH}" >> "$HASH_FILE" 2>/dev/null
fi
