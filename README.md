# Dotfiles for nsheaps

Personal dotfiles for macOS with modular shell configuration.

Inspired by https://github.com/getantidote/zdotdir

## Architecture

This repository uses a modular approach with:
- **`_home/profile.d/`** - Login shell scripts (environment variables, paths)
- **`_home/interactive.d/`** - Interactive shell scripts (functions, aliases)
- **`bin/dotfiles`** - Init script that sources the appropriate configs
- **`bin/wire`** - Deployment script that syncs _home/ to ~/

All files in `_home/` are visible (no leading dots) for easier editing. The `bin/wire` script adds dots when copying to `$HOME`.

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

# Deploy the dotfiles (removes the safety exit first)
# Review bin/wire before running!
sed -i.bak '/^exit 1$/d' bin/wire
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

# Sync changes to ~/
bin/wire

# Reload shell
source ~/.zshrc  # or open new terminal
```

## Directory Structure

```
dotfiles/
├── bin/
│   ├── dotfiles        # Init script (outputs shell code to eval)
│   ├── wire            # Deployment script (syncs _home/ to ~/)
│   └── templates/      # Shell code templates
├── _home/
│   ├── profile.d/      # Login shell scripts
│   │   └── 00-env.sh   # Environment variables (Java, .NET, NVM)
│   ├── interactive.d/  # Interactive shell scripts
│   │   ├── claude-cc-runclaude.sh
│   │   ├── claude-cc-newsession.sh
│   │   └── claude-cc-resume.sh
│   ├── zshrc           # Zsh interactive config
│   ├── zprofile        # Zsh login config
│   ├── zshenv          # Zsh environment config
│   ├── bashrc          # Bash interactive config
│   ├── bash_profile    # Bash login config
│   └── zsh_plugins.txt # Antidote plugin declarations
├── rc.d/
│   └── 00_setup_symlinks.sh  # Direnv setup (for repo development)
└── .envrc              # Direnv configuration
```

## How It Works

### Shell Initialization

When you start a shell, the RC files source the dotfiles init script:

```bash
# In ~/.zshrc, ~/.zprofile, etc.:
eval "$($HOME/src/nsheaps/dotfiles/bin/dotfiles init)"
```

The `dotfiles init` command:
1. Always sources `~/.profile.d/*.sh` (environment setup)
2. For interactive shells, also sources `~/.interactive.d/*.sh` (functions, aliases)

### Configuration Management

- **Edit**: Make changes in `_home/` directory
- **Deploy**: Run `bin/wire` to sync to ~/
- **Customize**: Add personal overrides in the user-customizable sections (above the managed block)

The managed sections are clearly marked:
```bash
### managed by automation ###
eval "$(dotfiles init)"
### end managed by automation ###
```

## Features

### Claude Workspace Functions

- `cc-newsession` - Create new Claude workspace
- `cc-tmp` - Create temporary Claude workspace (deleted on exit)
- `cc-resume` - Resume existing Claude workspace

### Development Tools

- **mise** - Version manager for node, python, go, etc.
- **Antidote** - Zsh plugin manager (static loading for faster startup)
- **Homebrew** - Package manager

## Customization

Add your personal configurations in the user-customizable sections of RC files:

```bash
# In _home/zshrc (above the managed section):

# User-customizable section
export MY_VAR="value"
alias myalias="command"

# Add tool integrations (OrbStack, rbenv, etc.)
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
```

After editing, run `bin/wire` to deploy changes.

## Documentation

See `.ai/scratch/` for detailed documentation:
- **plan.md** - Architecture and design decisions
- **migration.md** - Migration guide from old structure
- **review.md** - Implementation review findings
- **docs/research/eval-vs-source.md** - Research on shell sourcing patterns

## Maintenance

### Adding a New Profile Script

```bash
# Create in repo
echo '# My script' > _home/profile.d/50-myconfig.sh

# Deploy
bin/wire

# Restart shell
exec zsh
```

### Adding a New Interactive Function

```bash
# Create in repo
cat > _home/interactive.d/my-function.sh << 'EOF'
#!/usr/bin/env bash
my-function() {
  echo "Hello from my function"
}
EOF

# Deploy
bin/wire

# Test
my-function
```

### Updating Antidote Plugins

```bash
# Edit plugin list
vim _home/zsh_plugins.txt

# Deploy
bin/wire

# Reload (antidote will regenerate ~/.zsh_plugins.zsh)
source ~/.zshrc
```
