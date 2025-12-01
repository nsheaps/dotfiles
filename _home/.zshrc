#!/bin/zsh
#
# .zshrc - Zsh file loaded on interactive shell sessions.
#

# .zshenv is loaded before anything else, including macos path setup using /etc/paths (which then trump stuff in zshenv)
# .zprofile is loaded at login shells (when macos boots)
# .zshrc is loaded at non-login interactive shells (when you open a terminal)
#   in vscode, zshrc may be loaded again

# Source anything in .zshrc.d.
for _rc in ${ZDOTDIR:-$HOME}/.zshrc.d/*.zsh; do
  # Ignore tilde files.
  if [[ $_rc:t != '~'* ]]; then
    source "$_rc"
  fi
done
unset _rc

# Lazy-load (autoload) Zsh function files from a directory.
ZFUNCDIR=${ZDOTDIR:-$HOME}/.zfunctions
fpath=($ZFUNCDIR $fpath)
autoload -Uz $ZFUNCDIR/*(.:t)

# Create an amazing Zsh config using antidote plugins.

# Set the root name of the plugins files (.txt and .zsh) antidote will use.
zsh_plugins="${HOME}/.zsh_plugins"
# Ensure the .zsh_plugins.txt file exists so you can add plugins.
[[ -f ${zsh_plugins}.txt ]] || touch ${zsh_plugins}.txt

# Lazy-load antidote from its functions directory.
fpath=(/opt/homebrew/opt/antidote/share/antidote/functions $fpath)
autoload -Uz antidote

# Generate a new static file whenever .zsh_plugins.txt is updated.
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  antidote bundle <${zsh_plugins}.txt >|${zsh_plugins}.zsh
fi

# Source your static plugins file.
source ${zsh_plugins}.zsh

