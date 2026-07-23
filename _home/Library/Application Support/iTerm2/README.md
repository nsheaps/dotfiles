# iTerm2 Configuration

This directory contains iTerm2 profile configurations that are version-controlled in dotfiles.

> Note: this README previously described a `_home/.config/iterm2/` layout, a
> `_home/startup.d/00-iterm-profiles.sh` installer, and a switch script named
> `iterm-auto-profile.sh` — none of that exists. It described an aspirational
> design, not the actual implementation. Corrected below to match what's
> really here.

## Structure

```
_home/Library/Application Support/iTerm2/
├── DynamicProfiles/
│   └── custom-profiles.json    # Custom profile definitions
├── assets/
│   ├── oura-logo.png                # Official Oura ring mark (jouzen)
│   └── oura-logo-nsheaps-oura.png   # Oura mark + nsheaps-oura avatar badge
└── README.md                    # This file
```

## Profiles

### nsheaps

- **Light Mode Background**: Light maroon (#F7F2FA, warm-tinted)
- **Dark Mode Background**: Dark maroon/burgundy (#42191F)
- **Purpose**: Visual indicator for `nsheaps` personal directories
- **Auto-switch**: Activates in directories matching `*/src/nsheaps*` — but
  see the ordering note below, this pattern is intentionally last.

### nsheaps-oura

- **Light Mode Background**: Light teal (#EDFAF5)
- **Dark Mode Background**: Dark teal (#0A2E26)
- **Purpose**: Visual indicator for `nsheaps-oura` (work-affiliated) directories
- **Auto-switch**: Activates in directories matching `*/src/nsheaps-oura*`
- **Background image**: `oura-logo-nsheaps-oura.png` — the official Oura ring
  mark (fetched from `ouraring.com`'s own `og:image`) with the `nsheaps-oura`
  GitHub avatar composited into a small circular badge, bottom-right, with a
  white separation ring — the same visual pattern GitHub uses for "acting on
  behalf of" app/bot badges.

### jouzen

- **Light Mode Background**: Light indigo (#F2F0FC)
- **Dark Mode Background**: Dark indigo (#19153A)
- **Purpose**: Visual indicator for `jouzen` (Oura's own org) directories
- **Auto-switch**: Activates in directories matching `*/src/jouzen*`
- **Background image**: `oura-logo.png` — the plain official Oura ring mark,
  same source as above, no badge.

## Installation

Profiles are picked up by `bin/wire`'s `link_home_dir "_home/Library" "Library"`
call, which walks every file under `_home/Library/**` and symlinks it into the
matching `~/Library/**` path (see `.claude/rules/architecture.md`). There is
no separate installer script and no `dotfiles-managed-` prefix — the file
that lands at `~/Library/Application Support/iTerm2/DynamicProfiles/custom-profiles.json`
IS this repo's file (a real symlink), not a copy. iTerm2 automatically
detects and reloads Dynamic Profiles when the file changes.

### Live sync: Rewritable Dynamic Profiles

Per [iTerm2's own Dynamic Profiles documentation][dynamic-profiles-docs]: "A
Dynamic Profile with a Guid equal to an existing Guid of a regular profile
will be ignored." `nsheaps`, `nsheaps-oura`, and `jouzen` used to *also*
exist as regular (non-Dynamic) profiles in
`~/Library/Preferences/com.googlecode.iterm2.plist` ("New Bookmarks") with
the same Guids as their `custom-profiles.json` entries, which meant iTerm2
loaded and then silently discarded the Dynamic Profile definitions below in
favor of the regular ones — this file was documentation/backup only, not
the live source of truth.

That's fixed now: those 3 profiles are marked `"Rewritable": true` in this
file, and their same-Guid regular-profile counterparts have been removed
from the plist's "New Bookmarks" (confirmed on the machine this was fixed
on by re-reading the plist directly — only the `DEFAULT` Guid remains),
so the Dynamic Profile definitions here are what iTerm2 actually loads
there. Per the docs, a Rewritable Dynamic Profile's settings CAN be
edited through iTerm2's Preferences UI, and iTerm2 writes those changes
back into this file on disk — since this file is a real symlink into the
repo (see Installation above), a UI edit lands as a regular working-tree
diff here, ready to be committed. Not independently re-confirmed: whether
iTerm2's own conflict-warning log actually stopped, or a live
UI-edit-round-trips-to-file check — see the corresponding PR/task history
for what's been checked. `Default` is deliberately left alone (not
Rewritable, no Guid removed) since it's the one profile we don't want
Dynamic-Profile-managed.

### Regenerating this file

`bin/iterm2-export-profiles.py` reads the *current* regular profiles out of
`~/Library/Preferences/com.googlecode.iterm2.plist` ("New Bookmarks") and
overwrites this file with a full, key-sorted export — sorted so a re-export
after a no-op change in iTerm2 produces a clean diff (the plist's own
on-disk key order is arbitrary and shifts between saves). Run it after
changing a profile's settings in iTerm2's Preferences UI to bring this file
back in sync:

```bash
bin/iterm2-export-profiles.py
```

[dynamic-profiles-docs]: https://iterm2.com/documentation-dynamic-profiles.html

## Automatic Profile Switching

Handled by `_home/interactive.d/iterm2.sh` (sourced by the interactive-shell
loader, only when `$TERM_PROGRAM == iTerm.app`):

1. Registers a zsh `precmd` hook (runs before every prompt)
2. Matches `$PWD` against a `case` statement to pick a profile, and
   separately builds a badge (repo name + branch + dirty/ahead/behind state)
3. Sends iTerm2 proprietary escape sequences (`SetProfile`, `SetUserVar`) —
   deduplicated so it only emits a sequence when the value actually changed

### Customizing Switch Rules

Edit `_home/interactive.d/iterm2.sh`'s `_iterm2_update_profile()` case
statement. **Order matters** — patterns are matched top-to-bottom, and a
shorter/broader glob will shadow a longer one that comes after it. E.g.
`*/src/nsheaps*` also matches `*/src/nsheaps-oura/*`, so the `nsheaps-oura`
and `jouzen` branches must be listed *before* the plain `nsheaps` branch:

```bash
case "$PWD" in
  */src/nsheaps-oura*) _iterm2_set_profile "nsheaps-oura" ;;
  */src/jouzen*)       _iterm2_set_profile "jouzen" ;;
  */src/nsheaps*)      _iterm2_set_profile "nsheaps" ;;   # must come after the two above
esac
```

## Color Reference

Colors are defined using decimal RGB values (0-1 scale):

| Profile      | Mode       | Color        | Hex     | RGB (0-1)        |
| ------------ | ---------- | ------------ | ------- | ---------------- |
| nsheaps      | Light Mode | Light Maroon | #F7F2FA | 0.97, 0.95, 0.98 |
| nsheaps      | Dark Mode  | Dark Maroon  | #42191F | 0.26, 0.10, 0.14 |
| nsheaps-oura | Light Mode | Light Teal   | #EDFAF5 | 0.93, 0.98, 0.96 |
| nsheaps-oura | Dark Mode  | Dark Teal    | #0A2E26 | 0.04, 0.18, 0.15 |
| jouzen       | Light Mode | Light Indigo | #F2F0FC | 0.95, 0.94, 0.99 |
| jouzen       | Dark Mode  | Dark Indigo  | #19153A | 0.10, 0.08, 0.22 |

To convert hex to decimal: `Decimal = Hex / 255`

## Resources

- [iTerm2 Dynamic Profiles Documentation](https://iterm2.com/documentation-dynamic-profiles.html)
- [iTerm2 Automatic Profile Switching](https://iterm2.com/documentation-automatic-profile-switching.html)
