# Dotfiles for nsheaps

Personal dotfiles for macOS with modular shell configuration.

Inspired by https://github.com/getantidote/zdotdir

## Architecture

This repository uses a modular approach with:
- **`_home/profile.d/`** - Login shell scripts (environment variables, paths)
- **`_home/interactive.d/`** - Interactive shell scripts (functions, aliases)
- **`_home/startup.d/`** - Safe, idempotent scripts run at Mac login
- **`_home/update.d/`** - Potentially risky scripts run manually
- **`bin/wire`** - Deployment script that creates symlinks and injects managed sections

All files in `_home/` are visible (no leading dots) for easier editing. The `bin/wire` script creates symlinks and injects managed sections into shell RC files.

## Quick Start

### Initial Setup

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install base tools (includes antidote, mise, etc.)
brew install --cask nsheaps/devsetup/nsheaps-base

# Clone this repo
git clone git@github.com:nsheaps/dotfiles.git ~/src/nsheaps/dotfiles
cd ~/src/nsheaps/dotfiles

# Install development tools via mise
mise use -g node@lts bun@latest python@latest go@latest

# Deploy the dotfiles
bin/wire

# Start a new shell to test
zsh
```

### Updating Dotfiles

After making changes in the repo:

```bash
cd ~/src/nsheaps/dotfiles

# Edit files in _home/ directory
vim _home/zshrc

# Commit changes
git add .
git commit -m "update zshrc"
git push

# Changes to profile.d/, interactive.d/ are immediate (symlinked)
# Changes to RC file templates require re-running wire:
bin/wire

# Reload shell
source ~/.zshrc  # or open new terminal
```

## Directory Structure

```
dotfiles/
├── bin/
│   ├── wire              # Deployment script (creates symlinks, injects managed sections)
│   ├── run-startup.sh    # Runs startup.d scripts (for Mac login items)
│   ├── run-updates.sh    # Runs update.d scripts (manual)
│   └── lib/
│       └── source-scripts.sh  # Helper to execute scripts from a directory
├── templates/            # Shell code templates for managed sections
│   ├── zsh/
│   │   ├── rc.zsh        # Template for ~/.zshrc managed section
│   │   ├── profile.zsh   # Template for ~/.zprofile managed section
│   │   └── env.zsh       # Template for ~/.zshenv managed section
│   └── bash/
│       ├── rc.bash       # Template for ~/.bashrc managed section
│       └── profile.bash  # Template for ~/.bash_profile managed section
├── _home/
│   ├── profile.d/        # Login shell scripts (symlinked to ~/.profile.d)
│   ├── interactive.d/    # Interactive shell scripts (symlinked to ~/.interactive.d)
│   │   ├── claude.sh     # Claude CLI helper functions
│   │   ├── iterm-auto-profile.sh
│   │   └── open-iterm.sh
│   ├── startup.d/        # Mac login scripts (symlinked to ~/.startup.d)
│   ├── update.d/         # Manual update scripts (symlinked to ~/.update.d)
│   ├── zshrc             # Zsh interactive config
│   ├── zprofile          # Zsh login config
│   ├── zshenv            # Zsh environment config
│   ├── bashrc            # Bash interactive config
│   ├── bash_profile      # Bash login config
│   └── zsh_plugins.txt   # Antidote plugin declarations
├── rc.d/
│   └── 00_setup_symlinks.sh  # Direnv setup (for repo development)
└── .envrc                # Direnv configuration
```

## How It Works

### Wiring (bin/wire)

The `bin/wire` script sets up your shell environment:

1. **Creates symlinks** for script directories:
   - `~/.dotfiles` → this repo
   - `~/.profile.d` → `_home/profile.d`
   - `~/.interactive.d` → `_home/interactive.d`
   - `~/.startup.d` → `_home/startup.d`
   - `~/.update.d` → `_home/update.d`

2. **Injects managed sections** into shell RC files (`~/.zshrc`, `~/.bashrc`, etc.):
   ```bash
   # BEGIN: Managed by dotfiles wire
   export DOTFILES_DIR="/path/to/dotfiles"
   source "$DOTFILES_DIR/_home/zshrc"
   # END: Managed by dotfiles wire
   ```

### Shell Initialization Flow

When you start a shell:
1. Shell loads `~/.zshrc` (or `~/.bashrc`)
2. The managed section sources `_home/zshrc`
3. `_home/zshrc` loads antidote plugins and sources `profile.d/` and `interactive.d/`

### Configuration Management

- **Edit**: Make changes in `_home/` directory
- **Script directories**: Changes are immediate (symlinked)
- **RC files**: Run `bin/wire` after changing templates
- **Customize**: Add personal overrides above the managed section in `~/.zshrc`

## Features

### Claude Workspace Functions

- `claude` - Launch claude with default flags
- `ccresume` - Shorthand for `claude --resume`
- `cccontinue` - Shorthand for `claude --continue`
- `cc-newsession` - Create new Claude workspace
- `cc-tmp` - Create temporary Claude workspace (deleted on exit)
- `cc-resume` - Interactive picker to resume existing workspace
- `claude-update` - Update claude-code via Homebrew

### Development Tools

- **mise** - Version manager for node, python, go, etc.
- **Antidote** - Zsh plugin manager (static loading for faster startup)
- **Homebrew** - Package manager

### Startup & Update Scripts

- **`bin/run-startup.sh`** - Run safe, idempotent startup scripts. Add as a Mac login item.
- **`bin/run-updates.sh`** - Run potentially risky update scripts manually.

## Customization

Add your personal configurations above the managed section in `~/.zshrc`:

```bash
# User customizations (above managed section)
export MY_VAR="value"
alias myalias="command"

# Add tool integrations (OrbStack, rbenv, etc.)
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# BEGIN: Managed by dotfiles wire
# ... (don't edit below here)
```

## Maintenance

### Adding a New Profile Script

```bash
# Create in repo (changes are immediate via symlink)
echo '# My script' > _home/profile.d/50-myconfig.sh

# Restart shell
exec zsh
```

### Adding a New Interactive Function

```bash
# Create in repo
cat > _home/interactive.d/my-function.sh << 'EOF'
#!/usr/bin/env zsh
my-function() {
  echo "Hello from my function"
}
EOF

# Test immediately (symlinked)
source ~/.zshrc
my-function
```

### Updating Antidote Plugins

```bash
# Edit plugin list
vim _home/zsh_plugins.txt

# Reload (antidote will regenerate ~/.zsh_plugins.zsh)
source ~/.zshrc
```

### Re-wiring After Template Changes

```bash
# If you change templates/zsh/*.zsh or templates/bash/*.bash
bin/wire
source ~/.zshrc
```
