#!/usr/bin/env bash
# iTerm2 Dynamic Profiles Setup
#
# This script manages iTerm2 dynamic profiles by:
# 1. Cleaning up any previous dotfiles-managed profiles
# 2. Copying current profiles from the dotfiles repo
#
# Run on: repo update, machine start (via run-updates.sh login item)

set -euo pipefail

# Configuration
# Resolve symlinks to get the real script location (handles symlinked parent directories)
SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# Navigate from _home/update.d to repo root
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
ITERM_PROFILES_SRC="$DOTFILES_DIR/_home/.config/iterm2/DynamicProfiles"
ITERM_PROFILES_DST="$HOME/Library/Application Support/iTerm2/DynamicProfiles"

# Marker file to identify dotfiles-managed profiles
MARKER_PREFIX="dotfiles-managed-"

log() {
  echo "[iterm-profiles] $*"
}

# Clean up previous dotfiles-managed profiles
cleanup_old_profiles() {
  log "Cleaning up previous dotfiles-managed profiles..."

  if [[ -d "$ITERM_PROFILES_DST" ]]; then
    # Remove any files with our marker prefix
    find "$ITERM_PROFILES_DST" -maxdepth 1 -type f -name "${MARKER_PREFIX}*.json" -delete 2>/dev/null || true
    log "Cleanup complete"
  else
    log "iTerm2 DynamicProfiles directory does not exist yet"
  fi
}

# Copy current profiles to iTerm2
install_profiles() {
  log "Installing iTerm2 profiles..."

  if [[ ! -d "$ITERM_PROFILES_SRC" ]]; then
    log "Warning: Source profiles directory does not exist: $ITERM_PROFILES_SRC"
    return 1
  fi

  # Ensure destination directory exists
  mkdir -p "$ITERM_PROFILES_DST"

  # Copy each profile file with our marker prefix
  local count=0
  for profile in "$ITERM_PROFILES_SRC"/*.json; do
    if [[ -f "$profile" ]]; then
      local basename
      basename="$(basename "$profile")"
      local dest_file="$ITERM_PROFILES_DST/${MARKER_PREFIX}${basename}"

      cp "$profile" "$dest_file"
      log "Installed: $basename -> ${MARKER_PREFIX}${basename}"
      ((count++)) || true
    fi
  done

  if [[ $count -eq 0 ]]; then
    log "Warning: No profile files found in $ITERM_PROFILES_SRC"
  else
    log "Installed $count profile(s)"
  fi
}

main() {
  log "=== iTerm2 Profile Setup ==="
  log "Source: $ITERM_PROFILES_SRC"
  log "Destination: $ITERM_PROFILES_DST"

  cleanup_old_profiles
  install_profiles

  log "=== iTerm2 Profile Setup Complete ==="
}

main "$@"
