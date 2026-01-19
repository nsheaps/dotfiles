#!/usr/bin/env bash
# Run all update.d scripts (potentially risky, run manually)
# Usage: run-updates.sh

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="$DOTFILES_DIR/log"

mkdir -p "$LOG_DIR"
exec "$SCRIPT_DIR/source-scripts.sh" "${UPDATE_D:-$HOME/.update.d}" 2>&1 | tee -a "$LOG_DIR/updates.log"
