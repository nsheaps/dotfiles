#!/usr/bin/env zsh
#
# Homebrew helper functions covering the update / outdated / upgrade workflow,
# both per-tap and globally. Everything here is a shell function (no aliases)
# so the commands are consistent and can call one another.
#
#   brew-update-tap <tap>    brew update, then report that the tap was updated
#                            and list any outdated formulae it has.
#   brew-update-all          brew update (refreshes all taps).
#   brew-outdated [<tap>]    List outdated formulae; with <tap>, only those
#                            belonging to that tap. (Does not run brew update;
#                            use a brew-update-* command first.)
#   brew-upgrade-tap <tap>   brew update, then upgrade the formulae from <tap>.
#   brew-upgrade-all         brew update, then greedily upgrade everything.
#
# <tap> accepts either brew tap format (nsheaps/devsetup) or GitHub repo format
# (nsheaps/homebrew-devsetup); the leading homebrew- on the repo portion is
# normalized away.

# Normalize a tap reference to brew tap format (user/name), stripping a leading
# homebrew- from the repo portion: nsheaps/homebrew-devsetup -> nsheaps/devsetup
_brew_normalize_tap() {
  local tap="$1"
  printf '%s\n' "${tap%%/*}/${${tap#*/}#homebrew-}"
}

brew-update-tap() {
  if [[ -z "$1" ]]; then
    echo "Usage: brew-update-tap <tap>" >&2
    return 1
  fi

  local tap
  tap="$(_brew_normalize_tap "$1")"

  brew update || return 1
  echo "Tap ${tap} has been updated."

  local outdated
  outdated="$(brew-outdated "$tap")"
  if [[ -n "$outdated" ]]; then
    printf 'Run `brew-upgrade-tap %s` to upgrade the formula to the latest version.\n' "$tap"
    printf 'Outdated formula:\n%s\n' "$outdated"
  fi
}

brew-update-all() {
  brew update
}

brew-outdated() {
  # No tap: list every outdated formula/cask.
  if [[ -z "$1" ]]; then
    brew outdated
    return
  fi

  local tap
  tap="$(_brew_normalize_tap "$1")"

  local tap_formulae
  tap_formulae="$(brew tap-info --json "$tap" 2>/dev/null | jq -r '.[].formula_names[]')" || {
    echo "Error: could not read tap info for ${tap}" >&2
    return 1
  }

  # Intersect the tap's formulae with the currently-outdated ones, comparing on
  # the bare formula name (comm needs sorted, de-duplicated inputs).
  comm -12 \
    <(brew outdated --formula | sed 's#.*/##' | sort -u) \
    <(printf '%s\n' ${(f)tap_formulae} | sed 's#.*/##' | sort -u)
}

brew-upgrade-tap() {
  if [[ -z "$1" ]]; then
    echo "Usage: brew-upgrade-tap <tap>" >&2
    echo "  e.g. brew-upgrade-tap nsheaps/devsetup" >&2
    echo "       brew-upgrade-tap nsheaps/homebrew-devsetup" >&2
    return 1
  fi

  local tap
  tap="$(_brew_normalize_tap "$1")"

  echo "Updating brew..."
  brew update || return 1

  echo "Finding formulae in tap ${tap}..."
  local formulae
  formulae="$(brew tap-info --json "$tap" | jq -r '.[].formula_names[]')" || {
    echo "Error: could not get formulae for tap ${tap}" >&2
    return 1
  }

  if [[ -z "$formulae" ]]; then
    echo "No formulae found in tap ${tap}" >&2
    return 0
  fi

  echo "Upgrading: ${formulae}"
  brew upgrade ${=formulae}
}

brew-upgrade-all() {
  brew update && brew upgrade --greedy
}
