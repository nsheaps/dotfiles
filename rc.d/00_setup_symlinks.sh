#!/usr/bin/env bash

# This script sets up necessary symlinks for the dotfiles workspace
# The dotfile symlinks are ignored by default to avoid issues with different users on multiple machines


# New link() function: Repo is source of truth
# Usage: link <repo_file_path> <destination_path>
# Creates symlink from destination → repo file
# Example: link "_home/profile.d/00-env.sh" "$HOME/.config/myapp/env.sh"
function link() {
  local repo_file="$1"  # Path relative to repo root (e.g., "_home/config/foo.conf")
  local dest_path="$2"  # Absolute destination path (e.g., "$HOME/.config/foo.conf")

  local source="${DIRENV_ROOT}/${repo_file}"

  # Verify source exists in repo
  if [[ ! -f "${source}" ]]; then
    echo "Error: Source file ${repo_file} does not exist in repo"
    return 1
  fi

  # Create destination directory if needed
  local dest_dir="$(dirname "${dest_path}")"
  if [[ ! -d "${dest_dir}" ]]; then
    mkdir -p "${dest_dir}"
    echo "Created directory: ${dest_dir}"
  fi

  # Create or update symlink
  if [[ -L "${dest_path}" ]]; then
    # Already a symlink - check if it points to the right place
    local current_target="$(readlink "${dest_path}")"
    if [[ "${current_target}" != "${source}" ]]; then
      echo "Warning: ${dest_path} points to ${current_target}, expected ${source}"
      echo "  Run: ln -sfn \"${source}\" \"${dest_path}\" to fix"
    fi
  elif [[ -f "${dest_path}" ]]; then
    # Regular file exists - warn about potential overwrite
    echo "Warning: ${dest_path} exists as a regular file (not a symlink)"
    echo "  Backup and replace with: mv \"${dest_path}\" \"${dest_path}.bak\" && ln -s \"${source}\" \"${dest_path}\""
  else
    # Doesn't exist - would create symlink (but not auto-executing)
    echo "Would create: ln -s \"${source}\" \"${dest_path}\""
    echo "  (Not auto-executing - run manually if desired)"
  fi
}

# Old link() function (deprecated - kept for reference)
# function link() {
#   local file="$1"
#   local source="${HOME}/${file}"
#   local from="${DIRENV_ROOT}/_home/${file}"
#   ...
# }

# RC files (zshrc, zprofile, bashrc, bash_profile) are NOT symlinked
# They're managed by bin/wire which copies _home/ versions to ~/
# This allows user customizations in the user-customizable sections

# Configuration files that SHOULD be symlinked (repo is source of truth):
# Commented out - no auto-linking for now, review PR first
# link "mise_config.toml" "${HOME}/.config/mise/config.toml"

# Note: mise_config.toml in repo root is currently a symlink TO ~/.config/mise/config.toml
# In the new design, we might want to reverse this: store config in repo, symlink from ~/
echo "Dotfiles directory initialized (no auto-linking enabled)"
