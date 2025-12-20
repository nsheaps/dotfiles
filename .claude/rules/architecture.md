# Architecture

## Directory Structure

- `_home/`: Contains the canonical versions of dotfiles that should live in `$HOME`
  - `.zshenv`, `.zshrc`, `.zprofile`: Zsh configuration files
  - `.zsh_plugins.txt`: Antidote plugin declarations
  - `.zshrc.d/`: Additional Zsh configuration modules
  - `.config/`: XDG-compliant configuration directory for tools like `gh`, `karabiner`, and `mise`
- `rc.d/`: Shell scripts sourced by direnv when entering the directory
  - `00_setup_symlinks.sh`: Creates symlinks between `_home/` and `$HOME`, and creates convenience symlinks in the repo root
- `.envrc`: Direnv configuration that sources all scripts in `rc.d/`
- `mise_config.toml`: Symlink to `~/.config/mise/config.toml` for tracking tool versions

## Zsh Configuration Flow

The Zsh configuration loads in this order:
1. `.zshenv` - Loaded always, sets up XDG directories and environment (must live at `~/.zshenv`)
2. `.zprofile` - Loaded at login shells, initializes Homebrew and mise shims
3. `.zshrc` - Loaded for interactive shells, sources `.zshrc.d/*.zsh` files and loads Antidote plugins

## Plugin Management

This repository uses [Antidote](https://getantidote.github.io/) for Zsh plugin management. Plugins are declared in `_home/.zsh_plugins.txt` and include:
- `zsh-users/zsh-autosuggestions` and `zsh-users/zsh-completions`
- Various Oh My Zsh plugins via `getantidote/use-omz` (git, autojump, brew, direnv, docker, mise, command-not-found)
- `robbyrussell` theme

## Symlink System

The `rc.d/00_setup_symlinks.sh` script manages bidirectional syncing:
- If a file exists in `~/.` but not in `_home/`, it copies from `~/.` to `_home/`
- If files differ, it warns the user to reconcile manually
- Creates symlinks in repo root (e.g., `zshrc`, `zshenv`) pointing to `$HOME` versions for easy editing

These symlinks are gitignored to avoid conflicts across different machines/users.

## Tool Version Management

The repository uses [mise](https://mise.jdx.dev/) to manage development tool versions:
- Configuration lives in `~/.config/mise/config.toml` (symlinked to `mise_config.toml`)
- Default tools: `node@lts`, `bun@latest`, `go@latest`, `python@latest`
- Mise shims are activated in `.zprofile` for global availability
