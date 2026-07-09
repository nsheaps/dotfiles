#!/usr/bin/env zsh
#
# Homebrew utilities:
#   uufft <tap> - Update and Upgrade Formula From Tap
#     Accepts brew tap format (nsheaps/devsetup) or GitHub repo format
#     (nsheaps/homebrew-devsetup). Runs brew update, then upgrades all
#     formulas from the specified tap.
#
# Aliases:
#   brew-outdated   - brew update, then list outdated formulae/casks
#   brew-update-all - brew update, then upgrade everything (including casks)
#

alias brew-outdated="brew update && brew outdated"
alias brew-update-all="brew update && brew upgrade --greedy"

uufft() {
  if [[ -z "$1" ]]; then
    echo "Usage: uufft <tap>" >&2
    echo "  e.g. uufft nsheaps/devsetup" >&2
    echo "       uufft nsheaps/homebrew-devsetup" >&2
    return 1
  fi

  local tap="$1"

  # Normalize: strip homebrew- prefix from repo portion if present
  # nsheaps/homebrew-devsetup -> nsheaps/devsetup
  tap="${tap%%/*}/${${tap#*/}#homebrew-}"

  echo "Updating brew..."
  brew update || return 1

  echo "Finding formulas in tap ${tap}..."
  local formulas
  formulas=$(brew tap-info --json "$tap" | jq -r '.[].formula_names[]') || {
    echo "Error: could not get formulas for tap ${tap}" >&2
    return 1
  }

  if [[ -z "$formulas" ]]; then
    echo "No formulas found in tap ${tap}" >&2
    return 0
  fi

  echo "Upgrading: ${formulas}"
  brew upgrade ${=formulas}
}
