#!/usr/bin/env zsh
# Claude CLI helper functions
#
# Shorthands:
#   claude        - Launch claude with default flags
#   claude-update - Update claude-code via Homebrew
#
# General utilities:
#   restart-shell - Restart the current shell (exec $SHELL -l)
#
# NOTE: Many functions have been moved to claude-utils package.
# Install via: brew tap nsheaps/devsetup && brew install claude-utils
# Moved commands: ccresume, cccontinue, ccr, ccc, claude-clean-orphaned,
#                 cc-tmp, cc-newsession, cc-resume

# =============================================================================
# CLI Shorthands
# =============================================================================

_claudeish() {
  # Commands that only exist in claude (not happy) - always redirect to claude
  local CLAUDE_ONLY_COMMANDS=("auth" "plugin")
  # Commands that exist in both - pass through to whichever binary was requested
  local PASSTHROUGH_COMMANDS=("doctor" "daemon")
  local BIN_NAME="$1"
  shift

  local HAS_CLAUDE_ONLY_COMMAND=false
  local HAS_PASSTHROUGH_COMMAND=false

  # Check if this is a claude-only command
  for cmd in "${CLAUDE_ONLY_COMMANDS[@]}"; do
    if [[ "$1" == "$cmd" ]]; then
      HAS_CLAUDE_ONLY_COMMAND=true
      break
    fi
  done

  # Check if this is a passthrough command (exists in both CLIs)
  for cmd in "${PASSTHROUGH_COMMANDS[@]}"; do
    if [[ "$1" == "$cmd" ]]; then
      HAS_PASSTHROUGH_COMMAND=true
      break
    fi
  done

  # Only redirect to claude for claude-only commands
  if [[ $HAS_CLAUDE_ONLY_COMMAND == true ]]; then
    BIN_NAME="claude"
  fi

  local HAS_SPECIAL_COMMAND=false
  if [[ $HAS_CLAUDE_ONLY_COMMAND == true ]] || [[ $HAS_PASSTHROUGH_COMMAND == true ]]; then
    HAS_SPECIAL_COMMAND=true
  fi

  if [[ "$BIN_NAME" == "happy" ]] && ! command -v happy &> /dev/null; then
    echo "happy CLI not found. Install via \`npm install -g happy-coder\`" >&2
    echo "  see: https://happy.engineering/docs/quick-start/" >&2
    echo "Falling back to 'claude'." >&2
    BIN_NAME="claude"
  fi

  local CLAUDE_BIN=(command "$BIN_NAME")

  if [[ $HAS_SPECIAL_COMMAND == true ]]; then
    # pass through directly
    $CLAUDE_BIN "$@"
    return
  fi

  local FLAGS=("--allow-dangerously-skip-permissions" "$@")
  echo "Launching $BIN_NAME with flags:" >&2
  for flag in "${FLAGS[@]}"; do
    echo "  $flag" >&2
  done
  $CLAUDE_BIN "${FLAGS[@]}"
}

happy() {
  _claudeish "happy" "$@"
}

claude() {
  # claude passes through to happy all the time
  # _claudeish "claude" "$@"
  happy "$@"
}

# =============================================================================
# General Shell Utilities
# =============================================================================

restart-shell() {
  exec $SHELL -l
}
