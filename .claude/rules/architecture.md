# Architecture

## Directory Structure

- `internal/`: Dotfiles' own mechanism — required for the shell config to work
  at all. The rc loaders are always force-wired (managed sections / forced
  symlinks) with no conflict prompt; `internal/interactive.d` is sourced
  directly by the loaders (never exposed as a mutable `~` location).
  - `zshrc`, `zprofile`, `zshenv`: Zsh loader files (guard `DOTFILES_DIR`, set
    up XDG/PATH/Homebrew/mise, source the drop-in dirs)
  - `bashrc`, `bash_profile`: Bash loader files
  - `interactive.d/00-antidote.sh`: Antidote plugin-loading engine (reads
    `_home/zsh_plugins.txt`)
  - `interactive.d/staleness-check.sh`: Runs `dotfiles staleness-check` at
    interactive-shell startup
- `_home/`: Personal content that mirrors `$HOME`'s own structure. `.config`/
  `Library` files are wired with per-file conflict detection (diff/prompt/merge
  — see "Wiring System" below) rather than a blind overwrite; the `*.d` drop-in
  dirs are symlinked into `~` so you can add scripts to them.
  - `zsh_plugins.txt`: Antidote plugin declarations (your plugin choices)
  - `profile.d/`: Login shell scripts (symlinked to `~/.profile.d`)
  - `interactive.d/`: Personal interactive shell scripts — functions, aliases,
    integrations (symlinked to `~/.interactive.d`)
  - `startup.d/`: Safe, idempotent scripts for Mac login (symlinked to `~/.startup.d`)
  - `update.d/`: Potentially risky update scripts (symlinked to `~/.update.d`)
  - `.config/`: XDG-compliant configuration directory (symlinked into `~/.config` by `dotfiles wire`)
  - `Library/`: macOS app-support files (symlinked into `~/Library` by `dotfiles wire`)
  - `.local/bin/`: Personal scripts made reachable from `~/.local/bin`
- `bin/`: Executable scripts
  - `dotfiles`: The `dotfiles` CLI — `wire` (creates symlinks, injects managed sections, symlinks .config), `check` (reports wired state), `ensure-wired` (check-then-wire, used by the formula's `post_install`), `staleness-check` (warns on stderr if `$DOTFILES_DIR` is off-branch or behind the last-fetched remote, rate-limited via a timestamp in `$XDG_CACHE_HOME/dotfiles/`), plus `startup`/`update` delegates
  - `run-startup.sh`: Runs startup.d scripts (for Mac login items; `dotfiles startup` delegates here)
  - `run-updates.sh`: Runs update.d scripts (manual; `dotfiles update` delegates here)
  - `lib/source-scripts.sh`: Helper to execute scripts from a directory
- `Formula/`: Homebrew formula template (`dotfiles.rb.gotmpl`), rendered into the `nsheaps/homebrew-devsetup` tap by the release pipeline
- `templates/`: Shell code templates for managed sections
  - `zsh/rc.zsh`, `zsh/profile.zsh`, `zsh/env.zsh`
  - `bash/rc.bash`, `bash/profile.bash`
- `rc.d/`: Shell scripts sourced by direnv when entering the directory
  - `00_dotfiles_path.sh`: Prepends `bin/` to `PATH` and exports `DOTFILES_DIR` so the in-repo `dotfiles` CLI shadows the brew-installed one while developing
  - `00_setup_symlinks.sh`: Creates convenience symlinks in repo root pointing to `$HOME` files
- `.envrc`: Direnv configuration that sources all scripts in `rc.d/`

## Wiring System (dotfiles wire)

`dotfiles wire` deploys dotfiles from repo to `$HOME`:

1. **Creates symlinks** for the script drop-in directories (always
   force-relinked — the symlink is machinery, so there's nothing to diff or
   prompt about; the files it points at are personal `_home/` content):
   - `~/.dotfiles` → this repo
   - `~/.profile.d` → `_home/profile.d`
   - `~/.interactive.d` → `_home/interactive.d`
   - `~/.startup.d` → `_home/startup.d`
   - `~/.update.d` → `_home/update.d`

   (`internal/interactive.d` is not symlinked into `~` — the rc loaders source
   it directly from `$DOTFILES_DIR`, so dotfiles' own drop-ins always load
   regardless of the state of `~`.)

2. **Injects managed sections** into shell RC files:
   - `~/.zshrc`, `~/.zshenv`, `~/.zprofile` (zsh)
   - `~/.bashrc`, `~/.bash_profile` (bash)

3. **Symlinks .config/Library files** from `_home/.config`/`_home/Library` into `~/.config`/`~/Library`:
   - If the file doesn't exist: symlinks it
   - If it's already the correct symlink, or a plain file identical to the repo copy: leaves it (converting an identical plain file to a symlink)
   - If it differs: in non-interactive mode (or with no TTY) skips and leaves both untouched; interactively prompts to overwrite HOME with the repo copy, sync HOME back to the repo, 3-way merge, or skip

   These are symlinks, not copies, so editing a file under `~/.config` writes straight back through to the repo. Keep that in mind for anything identity- or secret-adjacent — a symlinked file is shared state across every machine wired from the same checkout.

The managed sections look like:
```bash
# BEGIN: Managed by dotfiles wire
export DOTFILES_DIR="/path/to/dotfiles"
source "$DOTFILES_DIR/internal/zshrc"
# END: Managed by dotfiles wire
```

## Convenience Symlinks (rc.d/00_setup_symlinks.sh)

When entering the dotfiles directory (via direnv), `rc.d/00_dotfiles_path.sh` first prepends the repo's `bin/` to `PATH` (so `dotfiles` runs the in-repo copy) and exports `DOTFILES_DIR="$DIRENV_ROOT"`. Then `rc.d/00_setup_symlinks.sh` creates convenience symlinks in the repo root pointing to actual files in `$HOME`. This allows editing deployed files directly:

- `zshrc` → `~/.zshrc`
- `zshenv` → `~/.zshenv`
- `zprofile` → `~/.zprofile`
- `bashrc` → `~/.bashrc`
- `bash_profile` → `~/.bash_profile`
- `mise_config.toml` → `~/.config/mise/config.toml`

These symlinks are gitignored and machine-specific.

## Zsh Configuration Flow

1. `~/.zshenv` - Managed section sources `internal/zshenv` (XDG directories, environment)
2. `~/.zprofile` - Managed section sources `internal/zprofile` (Homebrew, mise shims), then sources `_home/profile.d/*.sh`
3. `~/.zshrc` - Managed section sources `internal/zshrc`, which:
   - Sources all `_home/profile.d/*.sh` scripts
   - Sources `internal/interactive.d/*.sh` (dotfiles' own: antidote plugin
     loading, staleness check) then `_home/interactive.d/*.sh` (your personal
     functions), for TTY — internal first so plugins/fpath are ready before
     your scripts run
   - Antidote loads plugins from `_home/zsh_plugins.txt`

## Plugin Management

Uses [Antidote](https://getantidote.github.io/) for Zsh plugin management:
- Plugins declared in `_home/zsh_plugins.txt`
- Loaded by `internal/interactive.d/00-antidote.sh`
- Compiled to `~/.zsh_plugins.zsh` (regenerated when source changes)
- Includes: zsh-autosuggestions, zsh-completions, various Oh My Zsh plugins, robbyrussell theme

## Tool Version Management

Uses [mise](https://mise.jdx.dev/) for development tool versions:
- Configuration in `~/.config/mise/config.toml`
- Default tools: `node@lts`, `bun@latest`, `go@latest`, `python@latest`
- Mise shims activated in `internal/zprofile` for global availability
