# Architecture

## Directory Structure

- `_home/`: Contains the canonical versions of dotfiles
  - `zshrc`, `zprofile`, `zshenv`: Zsh configuration files (no leading dot)
  - `bashrc`, `bash_profile`: Bash configuration files
  - `zsh_plugins.txt`: Antidote plugin declarations
  - `profile.d/`: Login shell scripts (symlinked to `~/.profile.d`)
  - `interactive.d/`: Interactive shell scripts (symlinked to `~/.interactive.d`)
  - `startup.d/`: Safe, idempotent scripts for Mac login (symlinked to `~/.startup.d`)
  - `update.d/`: Potentially risky update scripts (symlinked to `~/.update.d`)
  - `.config/`: XDG-compliant configuration directory (copied to `~/.config` by `dotfiles wire`)
- `bin/`: Executable scripts
  - `dotfiles`: The `dotfiles` CLI — `wire` (creates symlinks, injects managed sections, copies .config), `check` (reports wired state), `ensure-wired` (check-then-wire, used by the formula's `post_install`), plus `startup`/`update` delegates
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

1. **Creates symlinks** for script directories:
   - `~/.dotfiles` → this repo
   - `~/.profile.d` → `_home/profile.d`
   - `~/.interactive.d` → `_home/interactive.d`
   - `~/.startup.d` → `_home/startup.d`
   - `~/.update.d` → `_home/update.d`

2. **Injects managed sections** into shell RC files:
   - `~/.zshrc`, `~/.zshenv`, `~/.zprofile` (zsh)
   - `~/.bashrc`, `~/.bash_profile` (bash)

3. **Copies .config files** from `_home/.config` to `~/.config`:
   - If file doesn't exist: copies it
   - If file matches: skips
   - If file differs: prompts user to overwrite, sync back to repo, or keep

The managed sections look like:
```bash
# BEGIN: Managed by dotfiles wire
export DOTFILES_DIR="/path/to/dotfiles"
source "$DOTFILES_DIR/_home/zshrc"
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

1. `~/.zshenv` - Managed section sources `_home/zshenv` (XDG directories, environment)
2. `~/.zprofile` - Managed section sources `_home/zprofile` (Homebrew, mise shims)
3. `~/.zshrc` - Managed section sources `_home/zshrc`, which:
   - Loads antidote plugins from `_home/zsh_plugins.txt`
   - Sources all `_home/profile.d/*.sh` scripts
   - Sources all `_home/interactive.d/*.sh` scripts (for TTY)

## Plugin Management

Uses [Antidote](https://getantidote.github.io/) for Zsh plugin management:
- Plugins declared in `_home/zsh_plugins.txt`
- Compiled to `~/.zsh_plugins.zsh` (regenerated when source changes)
- Includes: zsh-autosuggestions, zsh-completions, various Oh My Zsh plugins, robbyrussell theme

## Tool Version Management

Uses [mise](https://mise.jdx.dev/) for development tool versions:
- Configuration in `~/.config/mise/config.toml`
- Default tools: `node@lts`, `bun@latest`, `go@latest`, `python@latest`
- Mise shims activated in `_home/zprofile` for global availability
