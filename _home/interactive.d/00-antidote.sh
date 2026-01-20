#!/usr/bin/env zsh

# Lazy-load (autoload) Zsh function files from a directory.
ZFUNCDIR=${ZDOTDIR:-$HOME}/.zfunctions
if [[ -d "$ZFUNCDIR" ]]; then
  fpath=($ZFUNCDIR $fpath)
  autoload -Uz $ZFUNCDIR/*(.:t) 2>/dev/null
fi

# Antidote plugin management
# Plugins are defined in _home/zsh_plugins.txt, compiled to ~/.zsh_plugins.zsh
zsh_plugins_src="${DOTFILES_DIR}/_home/zsh_plugins.txt"
zsh_plugins_compiled="${HOME}/.zsh_plugins.zsh"

# Lazy-load antidote from its functions directory (supports Apple Silicon and Intel Macs)
if (( $+commands[brew] )); then
  _antidote_dir="$(brew --prefix antidote 2>/dev/null)/share/antidote"
  if [[ -d "$_antidote_dir/functions" ]]; then
    fpath=("$_antidote_dir/functions" $fpath)
    autoload -Uz antidote
  fi
  unset _antidote_dir
fi

# Generate compiled plugins file when source changes
if [[ ! -f "$zsh_plugins_compiled" ]] || [[ "$zsh_plugins_src" -nt "$zsh_plugins_compiled" ]]; then
  antidote bundle <"$zsh_plugins_src" >"$zsh_plugins_compiled"
fi

# Source the compiled plugins
source "$zsh_plugins_compiled"
