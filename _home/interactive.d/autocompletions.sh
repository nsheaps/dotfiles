#!/usr/bin/env zsh


if command -v git-spice &> /dev/null; then
  eval "$(git-spice shell completion zsh)"
fi
