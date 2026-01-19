#!/usr/bin/env bash
# Run all update.d scripts
#
# This script is designed to be used as a Mac login item to run
# update/configuration scripts on each login.
#
# Usage:
#   run-updates.sh
#
# Add as login item:
#   System Settings > General > Login Items > Add this script
#
# What it does:
#   1. Runs all *.sh scripts in ~/.update.d/ (or $UPDATE_D if set)
#   2. Logs output to ~/.local/log/dotfiles-update.log

exit 1
# Script untested.
# I think update.d and startup.d should be different
# if we update at startup and it's broken, we might break all shells
# updating should be done similar to how oh-my-zsh prompts every so often

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
UPDATE_D="${UPDATE_D:-$HOME/.update.d}"
LOG_DIR="${HOME}/.local/log"
LOG_FILE="${LOG_DIR}/dotfiles-update.log"

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
  log "=== Starting dotfiles update ==="
  log "Dotfiles directory: $DOTFILES_DIR"
  log "Update.d directory: $UPDATE_D"

  if [[ ! -d "$UPDATE_D" ]]; then
    log "Warning: Update directory does not exist: $UPDATE_D"
    log "Creating symlink to dotfiles update.d..."

    # Create symlink to _home/update.d if it exists
    if [[ -d "$DOTFILES_DIR/_home/update.d" ]]; then
      ln -sf "$DOTFILES_DIR/_home/update.d" "$UPDATE_D"
      log "Created symlink: $UPDATE_D -> $DOTFILES_DIR/_home/update.d"
    else
      log "Error: Source directory does not exist: $DOTFILES_DIR/_home/update.d"
      exit 1
    fi
  fi

  # Run all update scripts using source-scripts.sh
  if [[ -x "$SCRIPT_DIR/source-scripts.sh" ]]; then
    log "Running update scripts via source-scripts.sh..."
    "$SCRIPT_DIR/source-scripts.sh" "$UPDATE_D" 2>&1 | tee -a "$LOG_FILE"
  else
    # Fallback: run scripts directly
    log "Running update scripts directly..."
    for script in $(find -L "$UPDATE_D" -maxdepth 1 -type f -name '*.sh' | sort); do
      if [[ -f "$script" ]]; then
        log "Running: $script"
        bash "$script" 2>&1 | tee -a "$LOG_FILE" || {
          log "Warning: Script failed: $script"
        }
      fi
    done
  fi

  log "=== Dotfiles update complete ==="
}

main "$@"
