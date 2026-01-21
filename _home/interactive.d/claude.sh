#!/usr/bin/env zsh
# Claude CLI helper functions
#
# Shorthands:
#   claude        - Launch claude with default flags (via run-claude)
#   claude-update - Update claude-code via Homebrew
#

# =============================================================================
# CLI Shorthands
# =============================================================================

# The main logic lives in claude-utils/bin/lib/claude.lib.sh.
# This shell function wraps run-claude for interactive use.

claude() {
  # Use run-claude from claude-utils which handles happy routing and bypass permissions
  if command -v run-claude &> /dev/null; then
    run-claude "$@"
  else
    echo "run-claude not found. Install claude-utils with Homebrew:" >&2
    echo "  brew tap nsheaps/claude-utils" >&2
    echo "  brew install claude-utils" >&2
    echo "Falling back to direct claude invocation." >&2
    command claude "$@"
  fi
}
