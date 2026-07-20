#!/usr/bin/env zsh
# Warn on stderr at shell startup if this dotfiles checkout has drifted from
# its remote (wrong branch, or behind as of the last fetch). The actual
# logic (and the once-per-interval rate limiting) lives in
# `dotfiles staleness-check` so it can be shellchecked and run standalone;
# see `dotfiles staleness-check --help`.

if command -v dotfiles &> /dev/null; then
  dotfiles staleness-check
fi
