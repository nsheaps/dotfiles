#!/usr/bin/env bash
# iTerm2 Automatic Profile Switcher
# Automatically switches iTerm profiles based on current directory

iterm2_set_profile() {
  local profile_name="$1"
  # Send iTerm2 escape sequence to change profile
  echo -ne "\033]50;SetProfile=${profile_name}\007"
}

iterm2_auto_switch_profile() {
  # Only run in iTerm2
  [[ "$TERM_PROGRAM" != "iTerm.app" ]] && return

  local current_dir="$PWD"

  case "$current_dir" in
    */src/stainless-api*|*/src/stainless*)
      iterm2_set_profile "stainless"
      ;;
    */src/nsheaps*)
      iterm2_set_profile "nsheaps"
      ;;
    *)
      # Default profile
      iterm2_set_profile "Default"
      ;;
  esac
}

# Hook into shell directory changes
if [[ -n "$ZSH_VERSION" ]]; then
  # Zsh
  autoload -Uz add-zsh-hook
  add-zsh-hook chpwd iterm2_auto_switch_profile
elif [[ -n "$BASH_VERSION" ]]; then
  # Bash
  PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }iterm2_auto_switch_profile"
fi

# Run on initial load
iterm2_auto_switch_profile
