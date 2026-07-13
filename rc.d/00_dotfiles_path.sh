#!/usr/bin/env bash
# Make the in-repo `dotfiles` CLI take precedence while developing.
#
# The `dotfiles` command is normally installed globally by the Homebrew formula
# (nsheaps/devsetup/dotfiles). When you cd into a checkout of this repo, direnv
# prepends the repo's bin/ to PATH so `dotfiles wire` / `dotfiles check` run
# against your working copy instead of the installed one.
#
# DOTFILES_DIR is also exported so the CLI (and any manual sourcing) resolves to
# this checkout rather than the installed libexec copy.

# PATH_add is provided by direnv's stdlib; this file is sourced from .envrc.
PATH_add "${DIRENV_ROOT}/bin"
export DOTFILES_DIR="${DIRENV_ROOT}"
