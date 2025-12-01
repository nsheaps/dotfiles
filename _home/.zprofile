#!/bin/zsh
# .zshenv is loaded before anything else, including macos path setup using /etc/paths (which then trump stuff in zshenv)
# .zprofile is loaded at login shells (when macos boots)
# .zshrc is loaded at non-login interactive shells (when you open a terminal)
#   in vscode, zshrc may be loaded again

# Load brew, which adds the brew bin to PATH
eval "$(/opt/homebrew/bin/brew shellenv)"

# do a non-interactive mise activation to set up shims for tools so they can be available globally
mise activate --shims
