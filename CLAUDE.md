# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository for macOS that manages shell configuration, development tools, and system setup. It uses a symlink-based approach to keep dotfiles in version control while maintaining them in their expected locations in `$HOME`.

## Installation Flow

From the README, the setup process is:
1. Install Homebrew
2. Install the `nsheaps/devsetup/nsheaps-base` cask (which includes antidote and base tools)
3. Add antidote initialization to `.zshrc` (if not already present)
4. Use `mise use -g` to install default tools (node, bun, python, golang)

## Detailed Documentation

See `.claude/rules/` for detailed documentation:
- `architecture.md` - Directory structure, configuration flow, and system architecture
- `workflow.md` - Development workflow, testing, and hook reminders
