# `gh` config — why `hosts.yml` is not here

`config.yml` (preferences: protocol, aliases, prompt behavior) is tracked and
wired normally — it has no secrets and is safe to symlink into `~/.config/gh/`.

`hosts.yml` is **deliberately not tracked here**, and should never be added
back. `bin/wire`'s `link_home_dir` doesn't copy `.config` files — it
symlinks them, live, into the repo. For `hosts.yml` that's actively unsafe:

1. **Identity conflict.** This machine now runs two GitHub identities
   (`nsheaps` personal, `nsheaps-oura` work) via an isolated `GH_CONFIG_DIR`
   per identity — see `nsheaps-oura/docs`' multi-account-github-auth doc.
   `~/.config/gh/hosts.yml` is the *default* identity's file. A tracked,
   symlinked copy would silently force whichever `user:` it names as the
   default on every machine this repo is wired to, regardless of which
   identity should actually be default there.
2. **Secret-leak risk on Linux.** On macOS, `gh` keeps the actual OAuth token
   in Keychain and `hosts.yml` holds only identity metadata (no secret) — so
   the risk here is "wrong default identity," not credential exposure. On
   Linux (no Keychain), `gh` can fall back to storing the OAuth token
   **in plaintext directly in `hosts.yml`**. A live symlink into a git
   working tree turns "run `gh auth login`" into "write a live token where a
   `git add -A` — or an auto-commit hook — can commit it." That's not
   hypothetical: this workspace has since built an auto-commit hookify rule
   for another repo; the failure mode is real, not theoretical.

Let each machine's `gh auth login` create its own independent, untracked
`~/.config/gh/hosts.yml`. If you want a *starting point* for a new machine,
document the expected `user:` value in prose (as above) — don't wire a live
file.
