#!/usr/bin/env bash

claude() {
  CLAUDE_BIN="$(command -v claude)"
  local FLAGS=("--allow-dangerously-skip-permissions" "$@")
  echo "Launching claude with flags:"
  for flag in "${FLAGS[@]}"; do
    echo "  $flag"
  done
  exec "$CLAUDE_BIN" "${FLAGS[@]}"
}

ccagent() {
  CLAUDE_BIN="$(command -v claude-agent)"
  echo "NOT IMPLEMENTED"
  exit 1
  # local FLAGS=("--allow-dangerously-skip-permissions")
  # echo "Launching claude **IN AGENT MODE** with flags:"
  # for flag in "${FLAGS[@]}"; do
  #   echo "  $flag"
  # done
  # exec "$CLAUDE_BIN" "${FLAGS[@]}" "$@"
}

ccresume() {
  claude --resume "$@"
}

cccontinue() {
  claude --continue "$@"
}
