#!/usr/bin/env bash
# Run all startup.d scripts (safe, idempotent scripts for login items)
# Add as Mac login item: System Settings > General > Login Items

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="$DOTFILES_DIR/log"

mkdir -p "$LOG_DIR"
exec "$SCRIPT_DIR/lib/source-scripts.sh" "${STARTUP_D:-$HOME/.startup.d}" 2>&1 | tee -a "$LOG_DIR/startup.log"
