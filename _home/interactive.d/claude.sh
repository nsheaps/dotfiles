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

# MOVED TO claude-utils (brew install claude-utils)
# ccresume() {
#   claude --resume "$@"
# }
#
# cccontinue() {
#   claude --continue "$@"
# }
#
# # Short aliases with visual feedback
# ccr() {
#   echo "Resuming Claude Code Session..."
#   sleep 0.4
#   claude --resume "$@"
# }
#
# ccc() {
#   echo "Continuing Claude Code Session..."
#   sleep 0.4
#   claude --continue "$@"
# }

claude-update() {
  brew update && brew upgrade claude-code
}

# =============================================================================
# General Shell Utilities
# =============================================================================

restart-shell() {
  exec $SHELL -l
}

# MOVED TO claude-utils (brew install claude-utils)
# # Kill orphaned claude processes (PPID=1) that don't have happy in their process tree
# # Usage: claude-clean-orphaned [--force]
# #   Default: dry-run (shows what would be killed)
# #   --force: actually kill the processes
# #   Interactive TTY: prompts for confirmation instead of requiring --force
# claude-clean-orphaned() {
#   local force=false
#   [[ "$1" == "--force" ]] && force=true
#
#   local orphan_pids=()
#
#   # Find claude processes with PPID=1 (orphaned), excluding turbo
#   # Then filter out any that have happy as an ancestor (shouldn't happen for true orphans)
#   local candidates
#   candidates=$(pgrep -f claude | xargs -I {} sh -c 'ps -o pid,ppid,command -p {} 2>/dev/null' | grep -v turbo | awk '$2==1 && /claude/ {print $1}')
#
#   for pid in ${(f)candidates}; do
#     [[ -z "$pid" ]] && continue
#
#     # Check if this is a happy-managed session by examining the command line
#     # Happy-managed sessions have markers like .happy/ paths or mcp__happy__ tools
#     local cmd
#     cmd=$(ps -o command= -p $pid 2>/dev/null)
#     if [[ "$cmd" == *".happy/"* ]] || [[ "$cmd" == *"mcp__happy__"* ]]; then
#       continue
#     fi
#
#     # For orphans (PPID=1), check if any ancestor has happy in the name
#     # This walks up the tree but orphans only have launchd as parent
#     local dominated_by_happy=false
#     local p=$pid
#     while (( p > 1 )); do
#       local pinfo=$(ps -o ppid=,comm= -p $p 2>/dev/null)
#       [[ -z "$pinfo" ]] && break
#       local pp=${pinfo%% *}
#       local pc=${pinfo#* }
#       [[ "$pc" == *happy* ]] && { dominated_by_happy=true; break; }
#       p=$pp
#     done
#     [[ "$dominated_by_happy" == true ]] && continue
#     orphan_pids+=($pid)
#   done
#
#   if [[ ${#orphan_pids[@]} -eq 0 ]]; then
#     echo "No orphaned claude processes found."
#     return 0
#   fi
#
#   echo "Found ${#orphan_pids[@]} orphaned claude process(es):"
#   for pid in "${orphan_pids[@]}"; do
#     ps -o pid,etime,command -p "$pid" 2>/dev/null | tail -1
#   done
#
#   # Determine if we should kill: --force flag, or interactive confirmation
#   local should_kill=false
#   if [[ "$force" == true ]]; then
#     should_kill=true
#   elif [[ -t 0 && -t 1 ]]; then
#     # Interactive TTY - prompt the user
#     echo ""
#     printf "Kill these processes? [y/N] "
#     read -r response
#     [[ "$response" =~ ^[Yy]$ ]] && should_kill=true
#   fi
#
#   if [[ "$should_kill" == true ]]; then
#     echo ""
#     echo "Sending SIGINT to ${#orphan_pids[@]} orphaned process(es)..."
#     kill -INT "${orphan_pids[@]}" 2>/dev/null
#
#     # Wait 1 second for graceful shutdown
#     sleep 1
#
#     # Check which are still alive and send SIGKILL
#     local still_alive=()
#     for pid in "${orphan_pids[@]}"; do
#       kill -0 "$pid" 2>/dev/null && still_alive+=("$pid")
#     done
#
#     if [[ ${#still_alive[@]} -gt 0 ]]; then
#       echo "Sending SIGKILL to ${#still_alive[@]} stubborn process(es)..."
#       kill -9 "${still_alive[@]}" 2>/dev/null
#     fi
#
#     echo "Done."
#   else
#     echo ""
#     echo "(dry-run) Would kill: ${orphan_pids[*]}"
#     echo "Use --force to kill, or run interactively to be prompted."
#   fi
# }

# =============================================================================
# Workspace Management
# MOVED TO claude-utils (brew install claude-utils)
# =============================================================================

# # Core function that launches Claude in a workspace directory
# cc-runclaude() {
#   local CURRENT_DIR="$PWD"
#   local WS_DIR="$1"
#   shift
#   local is_temp='false'
#   if [[ "$1" == "--temp" ]]; then
#     is_temp='true'
#     shift
#   fi
#   local CLAUDE_ARGS="$@"
#
#   back_to_cwd() {
#     cd "$CURRENT_DIR"
#   }
#   trap back_to_cwd EXIT
#
#   local append_system_prompt="$(cat << EOPROMPT
# The user has launched you in an ephemeral workspace located at $WS_DIR.
# $(if [[ $is_temp == 'true' ]]; then
#     echo "This workspace is temporary and will be deleted when the user exits Claude."
# fi)
#
# This workspace is empty by default. Clarify with the user why it is needed if it is unclear from their prompt.
#
# Assume the user is not an expert at prompt engineering. When they make a request, first apply a critical thinking
# lens by starting with:
#   To fulfill this request, I should start by improving the prompt
#   Let me rewrite the user's prompt to be one that I would use with an AI agent to perform this task.
#   This prompt should be detailed enough that the AI Agent can complete the task in one-shot.
#   If the user's request doesn't contain enough detail to assure a one-shot execution, ask for clarification from the user.
#
# Once you have improved the prompt, proceed to complete the user's request as best as you can.
# EOPROMPT
# )"
#
#   mkdir -p "$WS_DIR"
#   cd "$WS_DIR"
#   printf "Launching Claude...\n"
#   claude --add-dir="$PWD" --append-system-prompt="$append_system_prompt" $CLAUDE_ARGS
# }
#
# # Create a new workspace session
# cc-newsession() {
#   local CURRENT_DIR="$PWD"
#   local is_temp='false'
#
#   if [[ "$1" == "--temp" ]]; then
#     is_temp='true'
#     shift
#   elif [[ -n "$1" ]]; then
#     echo "pass '--temp' to create a temporary claude workspace which is deleted on exit."
#     return 1
#   fi
#
#   local CLAUDE_ARGS="$@"
#   local NOW="$(date +%s)"
#   local WS_DIR="$HOME/.claude/tmp/workspace-$NOW"
#
#   cleanup() {
#     if [[ $is_temp == 'true' ]]; then
#       if [[ -d "$WS_DIR" ]]; then
#         cd "$HOME"
#         rm -rf "$WS_DIR"
#         echo "\nDeleted temporary workspace directory:\n\t$WS_DIR"
#       else
#         echo "\nNothing to clean up"
#       fi
#     else
#       echo "\nLeaving workspace directory intact at:\n\t$WS_DIR"
#     fi
#   }
#   trap cleanup EXIT
#
#   local IS_TMP_ARG=""
#   if [[ $is_temp == 'true' ]]; then
#     IS_TMP_ARG="--temp"
#     echo "Creating temporary workspace directory at:\n\t$WS_DIR"
#   fi
#
#   cc-runclaude "$WS_DIR" "$IS_TMP_ARG" "$@"
# }
#
# # Create a temporary workspace (convenience alias)
# cc-tmp() {
#   cc-newsession --temp "$@"
# }
#
# # Interactive picker to resume an existing workspace
# cc-resume() {
#   cc-resumesession "$*"
# }
#
# cc-resumesession() {
#   if ! command -v gum &> /dev/null; then
#     brew install gum
#   fi
#
#   local OPTIONS=()
#   for dir in "$HOME/.claude/tmp/"workspace-*(N); do
#     [ -d "$dir" ] && OPTIONS+=("$(basename "$dir")")
#   done
#
#   local RESUME_OPTION="Resume from Claude (claude --resume, opens menu)"
#   local CANCEL_OPTION="Cancel"
#   OPTIONS+=("$RESUME_OPTION")
#   OPTIONS+=("$CANCEL_OPTION")
#
#   local SELECTED=$(gum choose "${OPTIONS[@]}")
#   if [ "$SELECTED" = "$CANCEL_OPTION" ] || [ -z "$SELECTED" ]; then
#     echo "Cancelled."
#     return
#   elif [ "$SELECTED" = "$RESUME_OPTION" ]; then
#     claude --resume
#   else
#     local WS_DIR="$HOME/.claude/tmp/$SELECTED"
#     printf "Resuming Claude session in workspace:\n\t$WS_DIR"
#     cc-runclaude "$WS_DIR" "$@"
#     echo "\nLeaving workspace directory intact at:\n\t$WS_DIR"
#   fi
# }
