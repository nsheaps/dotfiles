#!/bin/zsh
#
# .zshenv - Zsh environment file, loaded always.
#

# .zshenv is loaded before anything else, including macos path setup using /etc/paths (which then trump stuff in zshenv)
# .zprofile is loaded at login shells (when macos boots)
# .zshrc is loaded at non-login interactive shells (when you open a terminal)
#   in vscode, zshrc may be loaded again

# NOTE: .zshenv needs to live at ~/.zshenv, not in $ZDOTDIR!

export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}

# Set ZDOTDIR if you want to re-home Zsh.
# export ZDOTDIR=${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}

# Ensure path arrays do not contain duplicates.
typeset -gU path fpath

