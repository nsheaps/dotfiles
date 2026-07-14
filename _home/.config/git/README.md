# Git config — why identity/credentials are not here

`config` (aliases, core preferences) is tracked and wired normally into
`~/.config/git/config` — it has no secrets and is safe to symlink, same
rationale as `_home/.config/gh/config.yml`.

`user.name`, `user.email`, and any `credential.*`/signing settings are
**deliberately not tracked here**, and should never be added back:

1. **Per-machine/per-identity.** Like `gh`'s `hosts.yml`, identity is
   machine- and context-dependent (e.g. personal vs work email via
   `includeIf "gitdir:"`). A tracked, symlinked value would silently force
   the same identity on every machine this repo is wired to.
2. **Secret-adjacent.** Credential helpers and signing key paths can be
   machine-specific or point at material that shouldn't live in a public
   repo's live symlink target.

Git reads `~/.gitconfig` *after* `~/.config/git/config` and lets
single-valued settings there win, so set your identity in `~/.gitconfig`
(untracked, per-machine) — it layers on top of the shared settings here
without conflicting:

```ini
# ~/.gitconfig (not tracked, create per-machine)
[user]
    name = Your Name
    email = you@example.com
```
