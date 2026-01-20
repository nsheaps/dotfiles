#!/usr/bin/env zsh
# iTerm2 dynamic badge - sets user.badge based on current directory
# Shows owner/repo in git repos, or path when in ~/src

# Only run in iTerm2
[[ "$TERM_PROGRAM" == "iTerm.app" ]] || return 0

# Set an iTerm2 user variable
# Usage: iterm2_set_user_var <name> <value>
iterm2_set_user_var() {
  printf "\033]1337;SetUserVar=%s=%s\007" "$1" "$(echo -n "$2" | base64)"
}

# Update the badge variable based on current directory
_update_iterm2_badge() {
  local badge_text=""

  # Check if we're in a git repo
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    # Try to get owner/repo from remote URL
    local remote_url
    remote_url=$(git remote get-url origin 2>/dev/null)

    if [[ -n "$remote_url" ]]; then
      # Extract owner/repo from various URL formats:
      # git@github.com:owner/repo.git
      # https://github.com/owner/repo.git
      # https://github.com/owner/repo
      badge_text=$(echo "$remote_url" | sed -E 's#^(git@|https://)([^:/]+)[:/]##; s#\.git$##')
    else
      # No remote, just show the repo name
      badge_text=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")
    fi
  elif [[ "$PWD" == "$HOME/src/"* ]]; then
    # In ~/src but not a git repo - show org/folder structure
    # e.g., ~/src/nsheaps -> "nsheaps", ~/src/nsheaps/ai -> "nsheaps/ai"
    badge_text="${PWD#$HOME/src/}"
  fi

  iterm2_set_user_var "badge" "$badge_text"
}

# Run on directory change (zsh hook)
if [[ -n "$ZSH_VERSION" ]]; then
  autoload -Uz add-zsh-hook
  add-zsh-hook chpwd _update_iterm2_badge
fi

# Run once on shell start
_update_iterm2_badge
