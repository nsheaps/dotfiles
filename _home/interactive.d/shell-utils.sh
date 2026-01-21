#!/usr/bin/env zsh
#
# General utilities:
#   restart-shell - Restart the current shell (exec $SHELL -l)
#

restart-shell() {
  exec $SHELL -l
}
