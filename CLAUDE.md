# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository for macOS that manages shell configuration, development tools, and system setup. It uses a symlink-based approach to keep dotfiles in version control while maintaining them in their expected locations in `$HOME`.

## Installation Flow

From the README, the setup process is:
1. Install Homebrew
2. Install the `nsheaps/devsetup/nsheaps-base` cask. It depends on the `dotfiles`
   formula, which installs the global `dotfiles` command and, in its
   `post_install`, runs `dotfiles ensure-wired` to symlink the config and inject
   the managed sections into `~/.zshrc`/`~/.zshenv`/`~/.zprofile` automatically.
3. Open a new shell (or `source ~/.zshrc`).

No manual antidote block or `mise use -g` step is required — the antidote plugin
list (`_home/zsh_plugins.txt`) and the mise tool list
(`_home/.config/mise/config.toml`) ship inside this repo and are wired into
`$HOME` by `dotfiles wire`.

### The `dotfiles` CLI

`bin/dotfiles` is the entry point (installed globally by the formula; shadowed by
the in-repo copy via direnv when inside a checkout):
- `dotfiles wire` — deploy symlinks + managed sections into `$HOME`
- `dotfiles check` — report whether `$HOME` is fully wired (exit 0 if wired)
- `dotfiles ensure-wired` — check, then wire only if needed (non-interactive, used by `post_install`)
- `dotfiles startup` / `dotfiles update` — run `startup.d` / `update.d` scripts

## Detailed Documentation

See `.claude/rules/` for detailed documentation:
- `architecture.md` - Directory structure, configuration flow, and system architecture
- `workflow.md` - Development workflow, testing, and hook reminders
