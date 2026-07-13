#!/usr/bin/env bash
# Shared helper for the brew-*-tap scripts.
#
# Normalize a tap reference to brew tap format (user/name), stripping a
# leading homebrew- from the repo portion:
#   nsheaps/homebrew-devsetup -> nsheaps/devsetup
brew_normalize_tap() {
  local tap="$1" user repo
  user="${tap%%/*}"
  repo="${tap#*/}"
  repo="${repo#homebrew-}"
  printf '%s\n' "${user}/${repo}"
}
