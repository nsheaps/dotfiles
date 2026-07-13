#!/usr/bin/env zsh


if command -v gs &> /dev/null; then
  eval "$(gs shell completion zsh)"
fi
