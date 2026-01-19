#!/usr/bin/env bash
# Dotfiles directory initialized via direnv
#
# Symlink management is handled by bin/wire, not by direnv hooks.
# Run 'bin/wire' to set up:
#   - ~/.dotfiles symlink to this repo
#   - ~/.profile.d, ~/.interactive.d, ~/.startup.d, ~/.update.d symlinks
#   - Managed sections in ~/.zshrc, ~/.bashrc, etc.

echo "Dotfiles directory loaded. Run 'bin/wire' to set up symlinks."
