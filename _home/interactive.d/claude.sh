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

# claude() {
#   # Use run-claude from claude-utils which handles happy routing and bypass permissions
#   if command -v run-claude &> /dev/null; then
#     run-claude "$@"
#   else
#     command claude "$@"
#   fi
# }
