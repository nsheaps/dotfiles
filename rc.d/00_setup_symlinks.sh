#!/usr/bin/env bash
# Dotfiles directory initialized via direnv
#
# This script creates convenience symlinks WITHIN the project pointing to
# actual files in $HOME for easy editing. This is the inverse of what bin/wire
# does (which deploys FROM repo TO $HOME).
#
# These symlinks are gitignored to avoid conflicts across different machines.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Dotfiles directory loaded: $DOTFILES_DIR"

# Create convenience symlinks in repo root pointing to $HOME files
# These allow editing the actual deployed files directly from the repo
create_convenience_symlink() {
  local name="$1"
  local home_file="$HOME/.$name"
  local repo_link="$DOTFILES_DIR/$name"

  if [[ -f "$home_file" ]]; then
    if [[ -L "$repo_link" ]]; then
      # Already a symlink, check if it points to the right place
      local current_target
      current_target="$(readlink "$repo_link")"
      if [[ "$current_target" != "$home_file" ]]; then
        ln -sfn "$home_file" "$repo_link"
        echo "  Updated: $name → ~/.$name"
      fi
    else
      ln -sfn "$home_file" "$repo_link"
      echo "  Created: $name → ~/.$name"
    fi
  fi
}

echo "Creating convenience symlinks for easy editing..."

# Shell config files
create_convenience_symlink "zshrc"
create_convenience_symlink "zshenv"
create_convenience_symlink "zprofile"
create_convenience_symlink "bashrc"
create_convenience_symlink "bash_profile"

# Mise config (special case - different path structure)
if [[ -f "$HOME/.config/mise/config.toml" ]]; then
  if [[ ! -L "$DOTFILES_DIR/mise_config.toml" ]] || \
     [[ "$(readlink "$DOTFILES_DIR/mise_config.toml")" != "$HOME/.config/mise/config.toml" ]]; then
    ln -sfn "$HOME/.config/mise/config.toml" "$DOTFILES_DIR/mise_config.toml"
    echo "  Created: mise_config.toml → ~/.config/mise/config.toml"
  fi
fi

echo ""
echo "Run 'bin/wire' to deploy dotfiles from repo to \$HOME."
