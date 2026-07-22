# Plan: activating #5 (profile-sync automation) and #22 (Default profile push)

Status: **draft for review — nothing here is implemented or wired up.** Both
pieces below were blocked by the coding agent's own safety classifier when
attempting to write the code, because both involve *authoring automation that
will repeatedly mutate live personal app state on its own, going forward*,
as opposed to a one-off interactive edit (like task #1's `PlistBuddy Add`, or
the plist edits already authorized). This doc lays out exactly what each
piece would do, in concrete code, so that authorization decision can be made
with the actual diff in view instead of blind.

Both are independent — you can approve one, both, or neither.

---

## #5: launchd LaunchAgent to trigger the profile-sync script

### What it does

`bin/iterm2-profile-sync.sh` already exists (PR #28, tested, not the subject
of this decision — it stages/commits/pushes ONLY `custom-profiles.json`,
never `git add -A`, only pushes on branch `main`). The open question is
*what triggers it*. Researched options:

- iTerm2's own Python API: **no profile-change event exists** (checked the
  Notifications module's 9 documented `async_subscribe_to_*` calls and the
  App class — none relate to profiles/preferences/dynamic-profile reloads).
  AutoLaunch scripts can run persistently, but with nothing to subscribe to,
  a persistent AutoLaunch script could only poll.
- **macOS `launchd` with `WatchPaths`** on `custom-profiles.json` is the one
  mechanism that reacts to the actual file write itself, not a proxy signal.
  This is what's proposed below.

### Where the new code lives

- New: `templates/launchd/iterm2-profile-sync.plist.template` — a plist
  template with two placeholders (`__DOTFILES_DIR__`, `__HOME__`) since
  `WatchPaths` requires a literal, already-resolved absolute path — launchd
  does not expand `$HOME` or any variable inside a loaded plist. This is why
  it can't just be a checked-in file symlinked into `~/Library/LaunchAgents`
  the way everything else in `_home/Library` is: its *content* differs per
  machine (different `$HOME`), so it has to be **generated**, not symlinked
  — same category of thing `inject_managed_section` already does for rc
  files, applied to a LaunchAgent plist instead.
- Modified: `bin/dotfiles` — a new function alongside the existing
  `set_default_iterm_profile` helper, called from `cmd_wire`.

### Concrete snippets

**`templates/launchd/iterm2-profile-sync.plist.template`** (new file):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.nsheaps.dotfiles.iterm2-profile-sync</string>
  <key>ProgramArguments</key>
  <array>
    <string>__DOTFILES_DIR__/bin/iterm2-profile-sync.sh</string>
  </array>
  <key>WatchPaths</key>
  <array>
    <string>__HOME__/Library/Application Support/iTerm2/DynamicProfiles/custom-profiles.json</string>
  </array>
  <key>StandardOutPath</key>
  <string>__DOTFILES_DIR__/log/iterm2-profile-sync-launchd.log</string>
  <key>StandardErrorPath</key>
  <string>__DOTFILES_DIR__/log/iterm2-profile-sync-launchd.log</string>
  <key>RunAtLoad</key>
  <false/>
</dict>
</plist>
```

**New function in `bin/dotfiles`** (placed near `set_default_iterm_profile`,
called from `cmd_wire` the same way that is):

```bash
# Generate the iTerm2-profile-sync LaunchAgent plist (WatchPaths needs a
# literal, resolved path -- can't be a symlinked checked-in file the way
# the rest of _home/Library is) and (re)register it with launchd so
# bin/iterm2-profile-sync.sh fires whenever custom-profiles.json changes.
# macOS-only; skip with DOTFILES_SKIP_ITERM2_LAUNCHD=1 -- launchctl
# bootstrap talks to the real user's launchd session by UID, so like
# set_default_iterm_profile's `defaults write`, this can't be sandboxed
# into a fake $HOME for wire-test-macos.
install_iterm2_profile_sync_launchd() {
  [[ -n "${DOTFILES_SKIP_ITERM2_LAUNCHD:-}" ]] && return 0
  [[ "$(uname -s)" == "Darwin" ]] || return 0
  command -v launchctl >/dev/null 2>&1 || return 0

  local template="$TEMPLATES_DIR/launchd/iterm2-profile-sync.plist.template"
  local label="com.nsheaps.dotfiles.iterm2-profile-sync"
  local target="$HOME/Library/LaunchAgents/$label.plist"

  [[ -f "$template" ]] || return 0
  mkdir -p "$HOME/Library/LaunchAgents"

  sed -e "s|__DOTFILES_DIR__|$DOTFILES_DIR|g" -e "s|__HOME__|$HOME|g" \
    "$template" >"$target"

  # Idempotent reload: bootout if already loaded (ignore failure -- it
  # won't be loaded on a first run), then bootstrap fresh from the file
  # that was just (re)written, so an edited template takes effect on the
  # next `dotfiles wire` without needing a logout/login.
  launchctl bootout "gui/$(id -u)/$label" 2>/dev/null || true
  if launchctl bootstrap "gui/$(id -u)" "$target" 2>/dev/null; then
    echo "  Registered iterm2-profile-sync LaunchAgent (watches custom-profiles.json)"
  else
    echo "  Warning: launchctl bootstrap failed for $label -- it will still" >&2
    echo "  load automatically on next login, or run manually:" >&2
    echo "    launchctl bootstrap gui/\$(id -u) '$target'" >&2
  fi
}
```

Call site in `cmd_wire`, right after the existing
`set_default_iterm_profile "$default_profile_name"` call:

```bash
install_iterm2_profile_sync_launchd
```

**CI escape hatch**: `wire-test-macos.yaml` already sets
`DOTFILES_SKIP_ITERM_DEFAULT=1` for the analogous `defaults write` reason;
add `DOTFILES_SKIP_ITERM2_LAUNCHD=1` alongside it so `dotfiles wire --yes`
in that job never touches the *runner's* real launchd session.

### Risk / irreversibility

- **Touches**: writes one file (`~/Library/LaunchAgents/<label>.plist`,
  regenerated in full on every `wire` run, not hand-edited) and registers
  one launchd job via `launchctl bootstrap`. Nothing else on the system.
- **Reversible**: yes, fully. `launchctl bootout gui/$(id -u)/<label>`
  unregisters it immediately; deleting the plist file removes it
  permanently (LaunchAgents only auto-(re)load at login, so a deleted file
  with no active bootstrap just stops existing). No live app state is
  touched by *this* piece — it only ever triggers the already-reviewed
  `bin/iterm2-profile-sync.sh`.
- **Misfire risk**: if `WatchPaths` fires more often than expected (e.g.
  something else touches the file, several rapid edits), the worst case is
  redundant invocations of a script that's already idempotent and narrowly
  scoped (no-op fast exit when there's nothing to commit). The launchd
  piece itself has no destructive behavior of its own — it's purely a
  trigger. Persists across reboots (LaunchAgents auto-load at login), which
  is the intended behavior but worth naming explicitly as a "keeps running
  even after this session ends" property.
- **New territory**: first use of `launchd` anywhere in this repo, and the
  first generated (not symlinked, not append-marker-injected) artifact
  under `~/Library/LaunchAgents`. Modifies the bash-3.2-constrained
  `cmd_wire` path, so it'd need a pass through `wire-test-macos.yaml` (with
  the skip var set) to confirm it doesn't break existing wire idempotency.

---

## #22: push `default-profile.json` into the live Default bookmark on `wire`

### What it does

The Default profile (Guid `DEFAULT`) can never be Guid-unshadowed the way
nsheaps/nsheaps-oura/jouzen were (iTerm2 always keeps a regular profile with
that Guid) — see task #21. The data half is already done and pushed
(branch `nate-ai/iterm2-default-profile-sync`,
`_home/Library/Application Support/iTerm2/default-profile.json`, a snapshot
of Default's current settings, deliberately outside `DynamicProfiles/`).
What's missing is the mechanism that actually applies that JSON to the live
plist, on every `dotfiles wire` run, as the user explicitly suggested.

### Where the new code lives

- New: `bin/iterm2-apply-default-profile.py` — reads
  `default-profile.json`, finds the `Guid == "DEFAULT"` entry in the live
  plist's `New Bookmarks`, merges the JSON's keys into it (only the keys
  present in the JSON; every other live key on that bookmark — `Guid`,
  `Working Directory`, etc. — is left untouched), writes the plist back.
- Modified: `bin/dotfiles` — one more call from `cmd_wire`, same shape as
  the `set_default_iterm_profile` / `install_iterm2_profile_sync_launchd`
  calls above.

### Concrete snippet

**`bin/iterm2-apply-default-profile.py`** (new file, full content):

```python
#!/usr/bin/env python3
"""Push the tracked Default iTerm2 profile config into the live plist.

Unlike nsheaps/nsheaps-oura/jouzen, the built-in "Default" profile
(Guid "DEFAULT") can never be managed as a Rewritable Dynamic Profile:
iTerm2 always keeps a regular profile with that Guid, and a same-Guid
Dynamic Profile is permanently ignored (see bin/iterm2-export-profiles.py's
module docstring). So Default can't get the other 3 profiles' true
bidirectional live sync (UI edit -> file, immediately).

This script is the one-way half of a workaround: it merges
default-profile.json's keys into the live plist's Default bookmark
(Guid "DEFAULT" in "New Bookmarks"), overwriting only the keys present in
the JSON and leaving every other live key (Guid, Working Directory, etc.)
untouched. Intended to be run from `dotfiles wire`, so Default's tracked
settings apply on every wire run.

IMPORTANT ASYMMETRY: this is push-only (config -> live). If someone edits
Default's settings via iTerm2's Preferences UI, that edit is NOT captured
back into default-profile.json automatically, and running this script (or
`dotfiles wire`) again will silently overwrite it with the tracked config.
This script prints a warning listing which tracked keys currently differ
from the live profile before applying, so an overwrite-in-progress is at
least visible -- it does not prompt, diff, or offer a merge the way
`dotfiles wire`'s .config/Library file handling does for the same class of
conflict. If that stronger guarantee is needed here too, it's a separate,
larger follow-up.

Usage:
    bin/iterm2-apply-default-profile.py
    bin/iterm2-apply-default-profile.py --plist <path> --config <path>
"""

import argparse
import json
import plistlib
import sys
from pathlib import Path

DEFAULT_PLIST = Path.home() / "Library/Preferences/com.googlecode.iterm2.plist"
REPO_ROOT = Path(__file__).resolve().parent.parent
DEFAULT_CONFIG = REPO_ROOT / (
    "_home/Library/Application Support/iTerm2/default-profile.json"
)

BINARY_PLIST_MAGIC = b"bplist00"


def _is_binary_plist(path: Path) -> bool:
    with open(path, "rb") as f:
        return f.read(len(BINARY_PLIST_MAGIC)) == BINARY_PLIST_MAGIC


def apply_default_profile(plist_path: Path, config_path: Path) -> dict:
    """Merge config_path's keys into plist_path's Guid=DEFAULT bookmark.

    Returns a small report dict ({"changed_keys": [...], "applied": bool})
    so callers (and tests) can assert on what happened without re-reading
    the file from disk.
    """
    with open(config_path) as f:
        config = json.load(f)

    binary = _is_binary_plist(plist_path)
    with open(plist_path, "rb") as f:
        data = plistlib.load(f)

    bookmarks = data.get("New Bookmarks", [])
    default_bookmark = next(
        (b for b in bookmarks if b.get("Guid") == "DEFAULT"), None
    )
    if default_bookmark is None:
        raise LookupError(
            f"No regular profile with Guid 'DEFAULT' found in {plist_path} "
            "-- expected iTerm2 to always keep one."
        )

    changed_keys = sorted(
        k for k, v in config.items() if default_bookmark.get(k) != v
    )

    default_bookmark.update(config)

    fmt = plistlib.FMT_BINARY if binary else plistlib.FMT_XML
    with open(plist_path, "wb") as f:
        plistlib.dump(data, f, fmt=fmt, sort_keys=False)

    return {"changed_keys": changed_keys, "applied": True}


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--plist",
        type=Path,
        default=DEFAULT_PLIST,
        help=f"iTerm2 prefs plist to modify (default: {DEFAULT_PLIST})",
    )
    parser.add_argument(
        "--config",
        type=Path,
        default=DEFAULT_CONFIG,
        help=f"Default profile config to push (default: {DEFAULT_CONFIG})",
    )
    args = parser.parse_args(argv)

    if not args.plist.exists():
        print(f"error: plist not found: {args.plist}", file=sys.stderr)
        return 1
    if not args.config.exists():
        print(f"error: config not found: {args.config}", file=sys.stderr)
        return 1

    try:
        report = apply_default_profile(args.plist, args.config)
    except LookupError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1

    if report["changed_keys"]:
        print(
            "iterm2-apply-default-profile: overwriting "
            f"{len(report['changed_keys'])} key(s) that differed from "
            f"tracked config: {', '.join(report['changed_keys'])}"
        )
    else:
        print("iterm2-apply-default-profile: already matches tracked config.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
```

**Call site in `cmd_wire`** (near the other iTerm2-related wire steps):

```bash
# Push the tracked Default-profile config into the live plist -- see
# bin/iterm2-apply-default-profile.py's docstring for why this is a
# one-way (config -> live) push rather than the other 3 profiles' true
# bidirectional sync.
apply_default_iterm_profile() {
  [[ -n "${DOTFILES_SKIP_ITERM_DEFAULT_PROFILE_SYNC:-}" ]] && return 0
  [[ "$(uname -s)" == "Darwin" ]] || return 0
  command -v python3 >/dev/null 2>&1 || return 0

  local apply_script="$DOTFILES_DIR/bin/iterm2-apply-default-profile.py"
  [[ -x "$apply_script" ]] || return 0

  python3 "$apply_script" || echo "  Warning: failed to apply Default profile config." >&2
}
```

...called from `cmd_wire` as `apply_default_iterm_profile`, and a matching
`DOTFILES_SKIP_ITERM_DEFAULT_PROFILE_SYNC=1` added to `wire-test-macos.yaml`
alongside the existing `DOTFILES_SKIP_ITERM_DEFAULT=1`.

### Risk / irreversibility — meaningfully higher than #5

This is the more dangerous of the two, and worth reading closely before
approving:

- **Touches**: directly rewrites the live
  `~/Library/Preferences/com.googlecode.iterm2.plist`'s Default bookmark
  entry, in place, **every time `dotfiles wire` runs** — not just when a
  human deliberately runs `dotfiles wire`, but also from the Homebrew
  formula's `post_install` -> `ensure-wired` path, i.e. potentially during
  an unattended `brew upgrade`.
- **What an overwrite discards**: any live edit made to Default via
  iTerm2's Preferences UI since the tracked `default-profile.json` was
  last updated gets silently replaced by the tracked config's values on
  the next wire run. The only safeguard in the design above is a printed
  warning listing which keys are about to change — there is no prompt, no
  diff view, no skip-if-changed check, and no way to recover the
  overwritten live value afterward (short of the plist backup you'd want
  to take before the *first* run, same as task #1's pattern — but nothing
  automatic backs it up on every subsequent run).
- **Misfire risk is the real concern here**: if `default-profile.json` ever
  contains a bad value (e.g. a malformed color dict, wrong font name,
  content that got hand-edited incorrectly in a future PR), the very next
  `dotfiles wire` — run by anyone, anywhere this dotfiles repo is
  checked out, including non-interactively — pushes that bad value
  straight into the live Default profile with zero review gate in
  between. This is different from the other 3 profiles: a bad value there
  would just sit inert in `custom-profiles.json` until something in
  iTerm2's own UI touches it. Here, `wire` applies it unconditionally.
- **Possible mitigations, not yet built, worth deciding on explicitly**:
  1. Ship as designed above (push + warn, no gate) — simplest, matches
     what the user explicitly asked for, but carries the misfire risk
     above.
  2. Add a "last-applied" fingerprint (e.g. a hash of the config file,
     stored somewhere like `~/.cache/dotfiles/default-profile.sha256`) so
     `wire` can distinguish "live matches what we pushed last time, safe
     to reapply" from "live has diverged since last wire (user edited it
     in the UI), skip and warn loudly instead of overwriting."
  3. Go further and give Default the same interactive diff/prompt/3-way
     merge treatment `dotfiles wire` already has for `.config`/`Library`
     file conflicts, reusing that existing machinery conceptually. Most
     consistent with the rest of the repo, but the most work, and Default
     isn't really a "file conflict" in the same shape (it's one entry deep
     inside a plist array, not a standalone file) so it wouldn't drop
     straight into that existing code path unmodified.

---

## The shared question

Both pieces above are code a human can review line-by-line before it ever
runs (nothing here has executed against the real plist or been committed).
The actual decision is about what happens *after* that review: should
`dotfiles wire` be allowed to carry this kind of automation going forward
(mutating live iTerm2 state on every future run, unattended), or does each
new instance of "wire touches live app state automatically" need its own
explicit go-ahead the way these two did? Whichever way that's decided, #22
specifically also has its own separate, narrower question above (which of
the three mitigation levels, if any, beyond "push + warn").
