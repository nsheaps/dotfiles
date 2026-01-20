#!/usr/bin/env bash
# Execute all *.sh scripts from a directory in sorted order
#
# Usage: source-scripts.sh <directory>
#
# Used by run-startup.sh and run-updates.sh to execute scripts
# from startup.d/ and update.d/ directories.

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $(basename "$0") <directory>" >&2
  exit 1
fi

DIRECTORY="$1"

if [[ ! -d "$DIRECTORY" ]]; then
  echo "Error: Directory does not exist: $DIRECTORY" >&2
  exit 1
fi

for script in $(find -L "$DIRECTORY" -maxdepth 1 -type f -name '*.sh' | sort); do
  if [[ -f "$script" ]]; then
    echo "Running: $script"
    bash "$script"
  fi
done
