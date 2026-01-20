#!/usr/bin/env zsh
# Claude CLI helper functions
#
# Shorthands:
#   claude        - Launch claude with default flags
#   ccresume      - Shorthand for 'claude --resume'
#   cccontinue    - Shorthand for 'claude --continue'
#   claude-update - Update claude-code via Homebrew
#
# Workspace management (cc-* prefix):
#   cc-tmp        - Create temporary workspace (deleted on exit)
#   cc-newsession - Create persistent workspace
#   cc-resume     - Interactive picker for existing workspaces
#   cc-runclaude  - Core function to launch claude in a workspace

# =============================================================================
# CLI Shorthands
# =============================================================================

_claudeish() {
  local BIN_NAME="$1"
  shift
  local CLAUDE_BIN=(command "$BIN_NAME")
  local FLAGS=("--allow-dangerously-skip-permissions" "$@")
  echo "Launching $BIN_NAME with flags:" >&2
  for flag in "${FLAGS[@]}"; do
    echo "  $flag" >&2
  done
  $CLAUDE_BIN "${FLAGS[@]}"
}

happy() {
  USE_BIN="happy"
  if ! command -v happy &> /dev/null; then
    echo "happy CLI not found. Install via \`npm install -g happy-coder\`" >&2
    echo "  see: https://happy.engineering/docs/quick-start/" >&2
    echo "Falling back to 'claude' command." >&2
    USE_BIN="claude"
  fi
  _claudeish "$USE_BIN" "$@"
}

claude() {
  _claudeish "happy" "$@"
}

ccresume() {
  claude --resume "$@"
}

cccontinue() {
  claude --continue "$@"
}

claude-update() {
  brew update && brew upgrade claude-code
}

# =============================================================================
# Workspace Management
# =============================================================================

# Core function that launches Claude in a workspace directory
cc-runclaude() {
  local CURRENT_DIR="$PWD"
  local WS_DIR="$1"
  shift
  local is_temp='false'
  if [[ "$1" == "--temp" ]]; then
    is_temp='true'
    shift
  fi
  local CLAUDE_ARGS="$@"

  back_to_cwd() {
    cd "$CURRENT_DIR"
  }
  trap back_to_cwd EXIT

  local append_system_prompt="$(cat << EOPROMPT
The user has launched you in an ephemeral workspace located at $WS_DIR.
$(if [[ $is_temp == 'true' ]]; then
    echo "This workspace is temporary and will be deleted when the user exits Claude."
fi)

This workspace is empty by default. Clarify with the user why it is needed if it is unclear from their prompt.

Assume the user is not an expert at prompt engineering. When they make a request, first apply a critical thinking
lens by starting with:
  To fulfill this request, I should start by improving the prompt
  Let me rewrite the user's prompt to be one that I would use with an AI agent to perform this task.
  This prompt should be detailed enough that the AI Agent can complete the task in one-shot.
  If the user's request doesn't contain enough detail to assure a one-shot execution, ask for clarification from the user.

Once you have improved the prompt, proceed to complete the user's request as best as you can.
EOPROMPT
)"

  mkdir -p "$WS_DIR"
  cd "$WS_DIR"
  printf "Launching Claude...\n"
  claude --add-dir="$PWD" --append-system-prompt="$append_system_prompt" $CLAUDE_ARGS
}

# Create a new workspace session
cc-newsession() {
  local CURRENT_DIR="$PWD"
  local is_temp='false'

  if [[ "$1" == "--temp" ]]; then
    is_temp='true'
    shift
  elif [[ -n "$1" ]]; then
    echo "pass '--temp' to create a temporary claude workspace which is deleted on exit."
    return 1
  fi

  local CLAUDE_ARGS="$@"
  local NOW="$(date +%s)"
  local WS_DIR="$HOME/.claude/tmp/workspace-$NOW"

  cleanup() {
    if [[ $is_temp == 'true' ]]; then
      if [[ -d "$WS_DIR" ]]; then
        cd "$HOME"
        rm -rf "$WS_DIR"
        echo "\nDeleted temporary workspace directory:\n\t$WS_DIR"
      else
        echo "\nNothing to clean up"
      fi
    else
      echo "\nLeaving workspace directory intact at:\n\t$WS_DIR"
    fi
  }
  trap cleanup EXIT

  local IS_TMP_ARG=""
  if [[ $is_temp == 'true' ]]; then
    IS_TMP_ARG="--temp"
    echo "Creating temporary workspace directory at:\n\t$WS_DIR"
  fi

  cc-runclaude "$WS_DIR" "$IS_TMP_ARG" "$@"
}

# Create a temporary workspace (convenience alias)
cc-tmp() {
  cc-newsession --temp "$@"
}

# Interactive picker to resume an existing workspace
cc-resume() {
  cc-resumesession "$*"
}

cc-resumesession() {
  if ! command -v gum &> /dev/null; then
    brew install gum
  fi

  local OPTIONS=()
  for dir in "$HOME/.claude/tmp/"workspace-*(N); do
    [ -d "$dir" ] && OPTIONS+=("$(basename "$dir")")
  done

  local RESUME_OPTION="Resume from Claude (claude --resume, opens menu)"
  local CANCEL_OPTION="Cancel"
  OPTIONS+=("$RESUME_OPTION")
  OPTIONS+=("$CANCEL_OPTION")

  local SELECTED=$(gum choose "${OPTIONS[@]}")
  if [ "$SELECTED" = "$CANCEL_OPTION" ] || [ -z "$SELECTED" ]; then
    echo "Cancelled."
    return
  elif [ "$SELECTED" = "$RESUME_OPTION" ]; then
    claude --resume
  else
    local WS_DIR="$HOME/.claude/tmp/$SELECTED"
    printf "Resuming Claude session in workspace:\n\t$WS_DIR"
    cc-runclaude "$WS_DIR" "$@"
    echo "\nLeaving workspace directory intact at:\n\t$WS_DIR"
  fi
}
