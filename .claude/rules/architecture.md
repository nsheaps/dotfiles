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
  - `.config/`: XDG-compliant configuration directory for tools like `gh`, `karabiner`, and `mise`
- `bin/`: Executable scripts
  - `wire`: Deployment script that creates symlinks and injects managed sections
  - `run-startup.sh`: Runs startup.d scripts (for Mac login items)
  - `run-updates.sh`: Runs update.d scripts (manual)
  - `lib/source-scripts.sh`: Helper to execute scripts from a directory
- `templates/`: Shell code templates for managed sections
  - `zsh/rc.zsh`, `zsh/profile.zsh`, `zsh/env.zsh`
  - `bash/rc.bash`, `bash/profile.bash`
- `rc.d/`: Shell scripts sourced by direnv when entering the directory
- `.envrc`: Direnv configuration that sources all scripts in `rc.d/`

## Wiring System (bin/wire)

The `bin/wire` script sets up the shell environment:

1. **Creates symlinks** for script directories:
   - `~/.dotfiles` → this repo
   - `~/.profile.d` → `_home/profile.d`
   - `~/.interactive.d` → `_home/interactive.d`
   - `~/.startup.d` → `_home/startup.d`
   - `~/.update.d` → `_home/update.d`

2. **Injects managed sections** into shell RC files:
   - `~/.zshrc`, `~/.zshenv`, `~/.zprofile` (zsh)
   - `~/.bashrc`, `~/.bash_profile` (bash)

The managed sections look like:
```bash
# BEGIN: Managed by dotfiles wire
export DOTFILES_DIR="/path/to/dotfiles"
source "$DOTFILES_DIR/_home/zshrc"
# END: Managed by dotfiles wire
```

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
