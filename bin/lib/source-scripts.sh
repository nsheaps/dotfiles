#!/usr/bin/env bash
# Source all *.sh scripts from a directory in sorted order
#
# Usage:
#   source-scripts.sh <directory>
#   source "$(source-scripts.sh --output <directory>)"
#
# Modes:
#   (default)   Execute scripts directly (for update.d style scripts)
#   --output    Output shell code to be eval'd (for profile.d/interactive.d sourcing)
#
# This script provides a DRY way to source scripts from directories like:
#   - profile.d/    (login shell scripts)
#   - interactive.d/ (interactive shell scripts)
#   - update.d/     (update/startup scripts)

set -euo pipefail

usage() {
  echo "Usage: $(basename "$0") [--output] <directory>" >&2
  echo "" >&2
  echo "Options:" >&2
  echo "  --output    Output shell code instead of executing directly" >&2
  echo "" >&2
  echo "Examples:" >&2
  echo "  $(basename "$0") ~/.update.d              # Execute all scripts" >&2
  echo "  eval \"\$($(basename "$0") --output ~/.profile.d)\"  # Source in current shell" >&2
  exit 1
}

OUTPUT_MODE=false
DIRECTORY=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --output)
      OUTPUT_MODE=true
      shift
      ;;
    -h|--help)
      usage
      ;;
    *)
      if [[ -z "$DIRECTORY" ]]; then
        DIRECTORY="$1"
      else
        echo "Error: Unexpected argument: $1" >&2
        usage
      fi
      shift
      ;;
  esac
done

if [[ -z "$DIRECTORY" ]]; then
  echo "Error: Directory argument required" >&2
  usage
fi

if [[ ! -d "$DIRECTORY" ]]; then
  echo "Error: Directory does not exist: $DIRECTORY" >&2
  exit 1
fi

if [[ "$OUTPUT_MODE" == "true" ]]; then
  # Output shell code to be sourced via eval
  cat <<EOF
# Source all scripts from $DIRECTORY
if [[ -d "$DIRECTORY" ]]; then
  for __source_script in "\$(find -L "$DIRECTORY" -maxdepth 1 -type f -name '*.sh' | sort)"; do
    if [[ -f "\$__source_script" ]]; then
      source "\$__source_script"
    fi
  done
  unset __source_script
fi
EOF
else
  # Execute scripts directly
  for script in $(find -L "$DIRECTORY" -maxdepth 1 -type f -name '*.sh' | sort); do
    if [[ -f "$script" ]]; then
      echo "Running: $script"
      bash "$script"
    fi
  done
fi
