# Dotfiles for nsheaps

Personal dotfiles for macOS with modular shell configuration.

Inspired by https://github.com/getantidote/zdotdir

## Architecture

This repository uses a modular approach with:
- **`_home/profile.d/`** - Login shell scripts (environment variables, paths)
- **`_home/interactive.d/`** - Interactive shell scripts (functions, aliases)
- **`_home/startup.d/`** - Safe, idempotent scripts run at Mac login
- **`_home/update.d/`** - Potentially risky scripts run manually
- **`bin/dotfiles`** - The `dotfiles` CLI that creates symlinks and injects managed sections (`dotfiles wire` / `dotfiles check` / `dotfiles sync`)

All files in `_home/` are visible (no leading dots) for easier editing. The `dotfiles` CLI creates symlinks and injects managed sections into shell RC files.

## Quick Start

### Initial Setup

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install base tools. The nsheaps-base cask depends on the `dotfiles` formula,
# which installs the global `dotfiles` command AND wires the shell config into
# $HOME automatically on install — no manual `bin/wire`, no copy-pasting an
# antidote block into ~/.zshrc.
brew install --cask nsheaps/devsetup/nsheaps-base

# Start a new shell to pick up the changes
zsh
```

That's it — the formula's `post_install` runs `dotfiles ensure-wired`, so the
managed sections and symlinks are already in place. Verify with:

```bash
dotfiles check     # reports whether $HOME is fully wired
```

### Local Development

To hack on the dotfiles themselves, clone the repo. `direnv` prepends the repo's
`bin/` to `PATH`, so `dotfiles` resolves to your working copy (not the installed
one) while you're inside the checkout:

```bash
git clone git@github.com:nsheaps/dotfiles.git ~/src/nsheaps/dotfiles
cd ~/src/nsheaps/dotfiles   # direnv: `dotfiles` now = ./bin/dotfiles

# Re-deploy from your working copy
dotfiles wire
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
dotfiles wire

# Reload shell
source ~/.zshrc  # or open new terminal
```

## Directory Structure

```
dotfiles/
├── bin/
│   ├── dotfiles          # The `dotfiles` CLI (wire, check, ensure-wired, startup, update, sync)
│   ├── run-startup.sh    # Runs startup.d scripts (for Mac login items)
│   ├── run-updates.sh    # Runs update.d scripts (manual)
│   └── lib/
│       └── source-scripts.sh  # Helper to execute scripts from a directory
├── Formula/
│   └── dotfiles.rb.gotmpl  # Homebrew formula template (rendered by the release pipeline)
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
│   │   ├── open-iterm.sh
│   │   └── staleness-check.sh  # Warns if the dotfiles checkout is stale (dotfiles staleness-check)
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

### Wiring (dotfiles wire)

`dotfiles wire` sets up your shell environment:

1. **Creates symlinks** for script directories:
   - `~/.dotfiles` → this repo (or, see below, a real checkout if you used `--repo`)
   - `~/.profile.d` → `_home/profile.d`
   - `~/.interactive.d` → `_home/interactive.d`
   - `~/.startup.d` → `_home/startup.d`
   - `~/.update.d` → `_home/update.d`

**`dotfiles wire --repo <url>`** — instead of symlinking `~/.dotfiles` to
wherever this CLI is currently running from (e.g. the Homebrew-managed
`opt`/`libexec` copy), clones `<url>` to `~/.dotfiles` as a real, independent
git checkout, then wires everything else *from that clone* — so your
`~/.config/...`/`~/Library/...` symlinks point at your own editable checkout,
not a copy you can't easily push commits from. Useful right after
`brew install dotfiles`, when you want your own real, personal checkout at
`~/.dotfiles` instead of a symlink into Homebrew's cellar. Once used, later
plain `dotfiles wire`/`dotfiles check` calls automatically recognize the real
checkout at `~/.dotfiles` and keep using it — you don't need to pass `--repo`
again. Refuses (rather than touching anything) if `~/.dotfiles` already
exists as something it didn't create: a real directory that isn't a git
checkout, or a checkout of a *different* repo.

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
- **RC files**: Run `dotfiles wire` after changing templates
- **Check**: Run `dotfiles check` to confirm `$HOME` is fully wired
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

- **`dotfiles startup`** - Run safe, idempotent startup scripts. Add as a Mac login item. (Delegates to `bin/run-startup.sh`.)
- **`dotfiles update`** - Run potentially risky update scripts manually. (Delegates to `bin/run-updates.sh`.)

### Staleness Check

Every new interactive shell runs `dotfiles staleness-check` (via
`_home/interactive.d/staleness-check.sh`). At most once every 16 hours (tracked
in `$XDG_CACHE_HOME/dotfiles/last-staleness-check`), it checks `$DOTFILES_DIR`
against the last-fetched remote state — no network access, so it never blocks
shell startup — and prints a warning to stderr if:
- the checkout is on a different branch than the remote's default branch, or is behind it
- the checkout has uncommitted changes, or has local commits not yet pushed to its upstream

(the second warning can show up even if you never `cd` into the repo — `.config`
files under `$DOTFILES_DIR` are symlinked into `$HOME`, not copied, so editing
one of them through its `~/.config` symlink is enough to leave the checkout
dirty). A no-op if `$DOTFILES_DIR` isn't a git checkout (e.g. the
Homebrew-installed copy).

```bash
dotfiles staleness-check --force   # check now, ignoring the interval
DOTFILES_SKIP_STALENESS_CHECK=1    # disable entirely
DOTFILES_STALENESS_CHECK_INTERVAL=3600   # override the interval (seconds)
```

### Sync (dotfiles sync)

`dotfiles sync` clears the uncommitted/unpushed warning above: it commits any
local changes in `$DOTFILES_DIR` (message `sync: local changes from <host>`),
fetches, rebases onto the current branch's remote counterpart, then pushes
(setting the upstream if none is configured yet). If the rebase hits
conflicts, it stops and tells you to resolve them in `$DOTFILES_DIR` and
re-run `dotfiles sync`.

```bash
dotfiles sync
```

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
dotfiles wire
source ~/.zshrc
```
