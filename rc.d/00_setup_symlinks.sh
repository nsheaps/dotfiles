#!/usr/bin/env bash

# This script sets up necessary symlinks for the dotfiles workspace
# The dotfile symlinks are ignored by default to avoid issues with different users on multiple machines


function link() {
  local file="$1"
  local source="${HOME}/${file}"
  local from="${DIRENV_ROOT}/_home/${file}"
  local name="$(basename "${source}")"
  local name_no_dot="${name#.}"
  local destination="${DIRENV_ROOT}/${name_no_dot}"
  if [[ ! -f "${source}" ]]; then
    if [[ -f "${from}" ]]; then
      cp "${from}" "${source}"
      echo "[nsheaps/dotfiles] Wrote ${source}"
    else
      echo "Warning: ${source} does not exist, skipping link"
    fi
  # if the contents of ${from} and ${source} differ, print a warning
  elif [[ -f "${from}" ]] && ! diff "${from}" "${source}" > /dev/null; then
    echo "Warning: ${source} differs from ${from}, please reconcile manually"
  fi
  # Create symlink if it doesn't already exist
  if [[ ! -f ${destination} ]]; then
    ln -s "${source}" "${destination}"
    echo "Linked ${source} to ${destination}"
  fi
}

link .zshrc
link .zshenv
link .zprofile

ln -s "${HOME}/.config/mise/config.toml" "${DIRENV_ROOT}/mise_config.toml"

