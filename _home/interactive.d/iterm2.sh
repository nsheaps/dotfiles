#!/usr/bin/env zsh
# iTerm2 integration - profile switching and dynamic badge
# Combines profile auto-switching with git-aware badge display

# Only run in iTerm2
[[ "$TERM_PROGRAM" == "iTerm.app" ]] || return 0

# =============================================================================
# Helper Functions (self-deduplicating to avoid unnecessary redraws)
# =============================================================================

# Cache for deduplication
_ITERM2_CURRENT_PROFILE=""
typeset -gA _ITERM2_USER_VARS

# Set iTerm2 profile (only emits escape sequence if value changed)
_iterm2_set_profile() {
  [[ "$1" == "$_ITERM2_CURRENT_PROFILE" ]] && return
  _ITERM2_CURRENT_PROFILE="$1"
  printf "\033]50;SetProfile=%s\007" "$1"
}

# Set iTerm2 user variable (only emits escape sequence if value changed)
_iterm2_set_user_var() {
  [[ "${_ITERM2_USER_VARS[$1]}" == "$2" ]] && return
  _ITERM2_USER_VARS[$1]="$2"
  printf "\033]1337;SetUserVar=%s=%s\007" "$1" "$(echo -n "$2" | base64)"
}

# =============================================================================
# Profile Switching
# =============================================================================

_iterm2_update_profile() {
  case "$PWD" in
    */src/stainless-api*|*/src/stainless*)
      _iterm2_set_profile "stainless"
      ;;
    */src/nsheaps*)
      _iterm2_set_profile "nsheaps"
      ;;
    *)
      _iterm2_set_profile "Default"
      ;;
  esac
}

# =============================================================================
# Badge Updates
# =============================================================================

_iterm2_update_badge() {
  local badge_text=""
  local git_info=""

  # Check if we're in a git repo
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    # Try to get owner/repo from remote URL
    local remote_url repo_name
    remote_url=$(git remote get-url origin 2>/dev/null)

    if [[ -n "$remote_url" ]]; then
      # Extract owner/repo from various URL formats
      repo_name=$(echo "$remote_url" | sed -E 's#^(git@|https://)([^:/]+)[:/]##; s#\.git$##')
    else
      # No remote, just show the repo name
      repo_name=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")
    fi

    # Get branch name
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)

    # Get ahead/behind counts
    local ahead=0 behind=0
    local upstream
    upstream=$(git rev-parse --abbrev-ref '@{upstream}' 2>/dev/null)
    if [[ -n "$upstream" ]]; then
      ahead=$(git rev-list --count '@{upstream}..HEAD' 2>/dev/null || echo 0)
      behind=$(git rev-list --count 'HEAD..@{upstream}' 2>/dev/null || echo 0)
    fi

    # Check clean/dirty status
    local dirty=""
    if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
      dirty="✗"
    else
      dirty="✓"
    fi

    # Build git status line
    git_info="$branch"
    [[ $ahead -gt 0 ]] && git_info+=" ↑$ahead"
    [[ $behind -gt 0 ]] && git_info+=" ↓$behind"
    git_info+=" $dirty"

    badge_text="${repo_name}"$'\n'"${git_info}"
  elif [[ "$PWD" == "$HOME/src/"* ]]; then
    # In ~/src but not a git repo - show org/folder structure
    badge_text="${PWD#$HOME/src/}"
  fi

  _iterm2_set_user_var "badge" "$badge_text"
}

# =============================================================================
# Combined Update (single hook)
# =============================================================================

_iterm2_update() {
  _iterm2_update_profile
  _iterm2_update_badge
}

# Register single precmd hook
if [[ -n "$ZSH_VERSION" ]]; then
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _iterm2_update
fi

# Run once on shell start
_iterm2_update
