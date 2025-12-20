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

# link .zshrc
# link .zshenv
# link .zprofile

# if ${DIRENV_ROOT}/mise_config.toml doesn't exist, create a symlink to ${HOME}/.config/mise/config.toml
# TODO: the file from within this repo should be the source of truth. `link` should take  the local file path, and where to symlink it from, so this is always the source of truth
# The one exception is the zshrc/zprofile/bashrc/bash_profile files, which are in-lined by dotfiles init from within the rc file to enable users to put specific overrides without them being in the repo.
# The direnv logic to warn you they're out of date also should be updated for this design
if [[ ! -f "${DIRENV_ROOT}/mise_config.toml" ]]; then
  ln -s "${HOME}/.config/mise/config.toml" "${DIRENV_ROOT}/mise_config.toml"
  echo "Linked ${HOME}/.config/mise/config.toml to ${DIRENV_ROOT}/mise_config.toml"
fi
