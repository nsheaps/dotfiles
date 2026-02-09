#!/usr/bin/env zsh


if ! command -v gs &> /dev/null; then
  echo "git-spice is not found" >&2
else
  eval "$(gs shell completion zsh)"
fi
