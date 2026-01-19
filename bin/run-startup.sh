#!/usr/bin/env bash
# Run all startup.d scripts
#
# This script is designed to be used as a Mac login item to run
# safe, idempotent startup scripts on each login.
#
# Usage:
#   run-startup.sh
#
# Add as login item:
#   System Settings > General > Login Items > Add this script
#
# What it does:
#   1. Runs all *.sh scripts in ~/.startup.d/ (or $STARTUP_D if set)
#   2. Logs output to ~/.local/log/dotfiles-startup.log
#
# Difference from run-updates.sh:
#   - startup.d: Safe, fast, idempotent scripts (e.g., iTerm profile sync)
#   - update.d: Potentially risky update scripts (prompted, not automatic)

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
STARTUP_D="${STARTUP_D:-$HOME/.startup.d}"
LOG_DIR="${HOME}/.local/log"
LOG_FILE="${LOG_DIR}/dotfiles-startup.log"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Log function
log() {
  local timestamp
  timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
  echo "[$timestamp] $*" | tee -a "$LOG_FILE"
}

# Main execution
main() {
  log "=== Starting dotfiles startup ==="
  log "Dotfiles directory: $DOTFILES_DIR"
  log "Startup.d directory: $STARTUP_D"

  if [[ ! -d "$STARTUP_D" ]]; then
    log "Warning: Startup directory does not exist: $STARTUP_D"
    log "Creating symlink to dotfiles startup.d..."

    # Create symlink to _home/startup.d if it exists
    if [[ -d "$DOTFILES_DIR/_home/startup.d" ]]; then
      ln -sf "$DOTFILES_DIR/_home/startup.d" "$STARTUP_D"
      log "Created symlink: $STARTUP_D -> $DOTFILES_DIR/_home/startup.d"
    else
      log "Error: Source directory does not exist: $DOTFILES_DIR/_home/startup.d"
      exit 1
    fi
  fi

  # Run all startup scripts using source-scripts.sh
  if [[ -x "$SCRIPT_DIR/source-scripts.sh" ]]; then
    log "Running startup scripts via source-scripts.sh..."
    "$SCRIPT_DIR/source-scripts.sh" "$STARTUP_D" 2>&1 | tee -a "$LOG_FILE"
  else
    # Fallback: run scripts directly
    log "Running startup scripts directly..."
    for script in $(find -L "$STARTUP_D" -maxdepth 1 -type f -name '*.sh' | sort); do
      if [[ -f "$script" ]]; then
        log "Running: $script"
        bash "$script" 2>&1 | tee -a "$LOG_FILE" || {
          log "Warning: Script failed: $script"
        }
      fi
    done
  fi

  log "=== Dotfiles startup complete ==="
}

main "$@"
