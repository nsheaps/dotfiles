#!/usr/bin/env bash
# Run all update.d scripts (with optional prompting)
#
# This script runs potentially risky update scripts from update.d/.
# Unlike startup.d scripts (which run automatically on login), these
# should be run manually or with user confirmation.
#
# Usage:
#   run-updates.sh           # Run with prompt (interactive)
#   run-updates.sh --force   # Run without prompting
#   run-updates.sh --check   # Check if updates are available (for shell prompt)
#
# Difference from run-startup.sh:
#   - startup.d: Safe, fast, idempotent scripts that run on every login
#   - update.d: Potentially risky scripts that should be prompted/manual
#
# Inspired by oh-my-zsh update mechanism - prompts periodically rather than
# running automatically, to avoid breaking shells if an update script is buggy.

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
UPDATE_D="${UPDATE_D:-$HOME/.update.d}"
LOG_DIR="${HOME}/.local/log"
LOG_FILE="${LOG_DIR}/dotfiles-update.log"
STATE_DIR="${HOME}/.local/state/dotfiles"
LAST_UPDATE_FILE="${STATE_DIR}/last-update"

# How often to prompt for updates (in days)
UPDATE_INTERVAL_DAYS="${DOTFILES_UPDATE_INTERVAL:-7}"

# Ensure directories exist
mkdir -p "$LOG_DIR" "$STATE_DIR"

# Log function
log() {
  local timestamp
  timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
  echo "[$timestamp] $*" | tee -a "$LOG_FILE"
}

# Check if update.d has any scripts
has_update_scripts() {
  [[ -d "$UPDATE_D" ]] && [[ -n "$(find -L "$UPDATE_D" -maxdepth 1 -type f -name '*.sh' 2>/dev/null)" ]]
}

# Check if we should prompt for updates
should_prompt_update() {
  # If no update scripts, don't prompt
  if ! has_update_scripts; then
    return 1
  fi

  # If never updated, should prompt
  if [[ ! -f "$LAST_UPDATE_FILE" ]]; then
    return 0
  fi

  # Check if enough time has passed
  local last_update
  last_update=$(cat "$LAST_UPDATE_FILE" 2>/dev/null || echo "0")
  local now
  now=$(date +%s)
  local interval_seconds=$((UPDATE_INTERVAL_DAYS * 86400))

  if (( now - last_update > interval_seconds )); then
    return 0
  fi

  return 1
}

# Record that we ran updates
record_update() {
  date +%s > "$LAST_UPDATE_FILE"
}

# Run the update scripts
run_updates() {
  log "=== Starting dotfiles update ==="
  log "Dotfiles directory: $DOTFILES_DIR"
  log "Update.d directory: $UPDATE_D"

  if [[ ! -d "$UPDATE_D" ]]; then
    log "Warning: Update directory does not exist: $UPDATE_D"

    # Create symlink to _home/update.d if it exists
    if [[ -d "$DOTFILES_DIR/_home/update.d" ]]; then
      ln -sf "$DOTFILES_DIR/_home/update.d" "$UPDATE_D"
      log "Created symlink: $UPDATE_D -> $DOTFILES_DIR/_home/update.d"
    else
      log "No update.d directory found - nothing to do"
      return 0
    fi
  fi

  if ! has_update_scripts; then
    log "No update scripts found in $UPDATE_D"
    return 0
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

  record_update
  log "=== Dotfiles update complete ==="
}

# Main
case "${1:-}" in
  --force|-f)
    run_updates
    ;;
  --check|-c)
    # For use in shell prompts - exit 0 if should update, 1 otherwise
    if should_prompt_update; then
      echo "Dotfiles updates available. Run 'run-updates.sh' to update."
      exit 0
    else
      exit 1
    fi
    ;;
  --help|-h)
    echo "Usage: $(basename "$0") [--force|--check|--help]"
    echo ""
    echo "Options:"
    echo "  --force, -f   Run updates without prompting"
    echo "  --check, -c   Check if updates are due (for shell prompts)"
    echo "  --help, -h    Show this help message"
    echo ""
    echo "Environment:"
    echo "  DOTFILES_UPDATE_INTERVAL  Days between update prompts (default: 7)"
    exit 0
    ;;
  "")
    # Interactive mode - prompt if needed
    if ! has_update_scripts; then
      echo "No update scripts found in $UPDATE_D"
      exit 0
    fi

    if should_prompt_update; then
      echo "Dotfiles updates are available."
      read -r -p "Run update scripts now? [y/N] " response
      case "$response" in
        [yY][eE][sS]|[yY])
          run_updates
          ;;
        *)
          echo "Skipping updates. Run 'run-updates.sh --force' to update later."
          ;;
      esac
    else
      echo "Dotfiles are up to date. Use --force to run anyway."
    fi
    ;;
  *)
    echo "Unknown option: $1" >&2
    echo "Run '$(basename "$0") --help' for usage." >&2
    exit 1
    ;;
esac
