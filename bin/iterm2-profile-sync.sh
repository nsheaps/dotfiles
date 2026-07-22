#!/usr/bin/env bash
# Commit and push changes to custom-profiles.json ONLY.
#
# Triggered from _home/interactive.d/iterm2.sh once per new interactive
# shell (only when $TERM_PROGRAM == iTerm.app): when a Rewritable Dynamic
# Profile is edited via iTerm2's Preferences UI, iTerm2 writes the change
# straight into custom-profiles.json (a real symlink into this repo), and
# the next shell/tab opened picks it up here and syncs it to origin/main.
#
# Deliberately narrower than `dotfiles sync`: this only ever stages the
# one profiles file, never `git add -A` -- it runs unattended in the
# background, so it must never sweep up unrelated work-in-progress
# changes elsewhere in the repo (see rules/dont-delete-unrecognized-files.md
# equivalent concern: don't touch what you don't own).
#
# Direct-to-main push is an explicit, narrow exception granted for this
# one file (externally-driven config synced FROM iTerm2's own UI, not
# authored by an agent or a human editing the repo) -- see
# rules/github-prefs.md's repo-scoped exception note for the rationale.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROFILE_JSON_REL="_home/Library/Application Support/iTerm2/DynamicProfiles/custom-profiles.json"
PROFILE_JSON="$DOTFILES_DIR/$PROFILE_JSON_REL"
LOG_DIR="$DOTFILES_DIR/log"

mkdir -p "$LOG_DIR"
exec >>"$LOG_DIR/iterm2-profile-sync.log" 2>&1
echo "---- $(date) ----"

if [[ ! -f "$PROFILE_JSON" ]]; then
  echo "iterm2-profile-sync: $PROFILE_JSON_REL not found, skipping."
  exit 0
fi

if ! git -C "$DOTFILES_DIR" rev-parse --git-dir &>/dev/null; then
  echo "iterm2-profile-sync: $DOTFILES_DIR is not a git checkout, skipping."
  exit 0
fi

current_branch="$(git -C "$DOTFILES_DIR" symbolic-ref --quiet --short HEAD || true)"
if [[ "$current_branch" != "main" ]]; then
  echo "iterm2-profile-sync: on branch '$current_branch', not main; skipping (this repo checkout should stay on main -- see rules/git-prefs.md)."
  exit 0
fi

if git -C "$DOTFILES_DIR" diff --quiet -- "$PROFILE_JSON_REL" &&
  git -C "$DOTFILES_DIR" diff --cached --quiet -- "$PROFILE_JSON_REL"; then
  echo "iterm2-profile-sync: no changes to $PROFILE_JSON_REL, nothing to do."
  exit 0
fi

echo "iterm2-profile-sync: change detected, committing..."
git -C "$DOTFILES_DIR" add -- "$PROFILE_JSON_REL"
git -C "$DOTFILES_DIR" commit --quiet -m \
  "chore(iterm2): sync profile changes from iTerm2 UI on $(hostname 2>/dev/null || echo unknown)"

echo "iterm2-profile-sync: fetching..."
if ! git -C "$DOTFILES_DIR" fetch --quiet origin main; then
  echo "iterm2-profile-sync: fetch failed; leaving commit local for next run." >&2
  exit 1
fi

echo "iterm2-profile-sync: rebasing onto origin/main..."
if ! git -C "$DOTFILES_DIR" rebase --quiet origin/main; then
  echo "iterm2-profile-sync: rebase conflict; aborting rebase, leaving commit local for manual resolution." >&2
  git -C "$DOTFILES_DIR" rebase --abort || true
  exit 1
fi

echo "iterm2-profile-sync: pushing to main..."
if ! git -C "$DOTFILES_DIR" push --quiet origin HEAD:refs/heads/main; then
  echo "iterm2-profile-sync: push failed (remote may have moved); will retry next shell start." >&2
  exit 1
fi

echo "iterm2-profile-sync: done."
