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
│   └── stainless-logo.png
└── README.md                    # This file
```

## Profiles

### stainless

- **Light Mode Background**: Light blue (#E3F2FD)
- **Dark Mode Background**: Dark blue (#1E3A5F)
- **Purpose**: Visual indicator for stainless directories
- **Auto-switch**: Activates in directories matching `*/src/stainless-api*` or `*/src/stainless*`

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

### jouzen

- **Light Mode Background**: Light indigo (#F2F0FC)
- **Dark Mode Background**: Dark indigo (#19153A)
- **Purpose**: Visual indicator for `jouzen` (Oura's own org) directories
- **Auto-switch**: Activates in directories matching `*/src/jouzen*`

## Installation

Profiles are picked up by `bin/wire`'s `link_home_dir "_home/Library" "Library"`
call, which walks every file under `_home/Library/**` and symlinks it into the
matching `~/Library/**` path (see `.claude/rules/architecture.md`). There is
no separate installer script and no `dotfiles-managed-` prefix — the file
that lands at `~/Library/Application Support/iTerm2/DynamicProfiles/custom-profiles.json`
IS this repo's file (a real symlink), not a copy. iTerm2 automatically
detects and reloads Dynamic Profiles when the file changes.

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

| Profile      | Mode       | Color        | Hex     | RGB (0-1)         |
| ------------ | ---------- | ------------ | ------- | ------------------ |
| stainless    | Light Mode | Light Blue   | #E3F2FD | 0.95, 0.95, 0.97* |
| stainless    | Dark Mode  | Dark Blue    | #0A1429 | 0.04, 0.08, 0.16   |
| nsheaps      | Light Mode | Light Maroon | #F7F2FA | 0.97, 0.95, 0.98   |
| nsheaps      | Dark Mode  | Dark Maroon  | #42191F | 0.26, 0.10, 0.14   |
| nsheaps-oura | Light Mode | Light Teal   | #EDFAF5 | 0.93, 0.98, 0.96   |
| nsheaps-oura | Dark Mode  | Dark Teal    | #0A2E26 | 0.04, 0.18, 0.15   |
| jouzen       | Light Mode | Light Indigo | #F2F0FC | 0.95, 0.94, 0.99   |
| jouzen       | Dark Mode  | Dark Indigo  | #19153A | 0.10, 0.08, 0.22   |

\* stainless's actual JSON values render closer to a very light gray-blue
than the originally-documented `#E3F2FD` — left as-is (cosmetic, low-value
to chase further); the other rows are exact.

To convert hex to decimal: `Decimal = Hex / 255`

## Resources

- [iTerm2 Dynamic Profiles Documentation](https://iterm2.com/documentation-dynamic-profiles.html)
- [iTerm2 Automatic Profile Switching](https://iterm2.com/documentation-automatic-profile-switching.html)
