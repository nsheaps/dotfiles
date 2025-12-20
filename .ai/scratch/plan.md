# Shell Configuration Refactoring Plan

## Goal
Restructure shell configuration to use a unified approach with `profile.d/` and `interactive.d/` directories, automated syncing, and consistent bash scripts.

## Architecture

### Directory Structure (FLAT - no subdirectories within each folder)
```
dotfiles/
├── bin/
│   └── dotfiles           # Script that handles init and sync operations
└── _home/
    ├── profile.d/         # Login shell scripts (NOT dotfiles in repo)
    │   └── 00-env.sh      # Environment variables (Java, .NET, NVM)
    ├── interactive.d/     # Interactive shell scripts (NOT dotfiles in repo)
    │   ├── claude-cc-runclaude.sh
    │   ├── claude-cc-newsession.sh
    │   ├── claude-cc-resume.sh
    │   └── kpup.sh
    └── (existing files)
```

### File Format
- All scripts use `.sh` extension
- All scripts use bash internally with `#!/usr/bin/env bash` shebang
- This ensures compatibility across shells

### Home Directory Symlinks (created by wiring script)
- `~/.profile.d` → `dotfiles/_home/profile.d`
- `~/.interactive.d` → `dotfiles/_home/interactive.d`

Note: The directories in the repo do NOT have leading dots to keep them
visible in file explorers. The wiring script creates the dotfile symlinks.

### Sourcing Order
**~/.zprofile (and ~/.bash_profile):**
- Sources everything in `~/.profile.d/*.sh` (sorted)

**~/.zshrc (and ~/.bashrc):**
- Sources everything in `~/.profile.d/*.sh` (sorted) - first
- Sources everything in `~/.interactive.d/*.sh` (sorted) - second

### Shell RC Files (~/.zshrc, ~/.zprofile, ~/.bashrc, ~/.bash_profile)
Each file should have:
1. A header comment explaining when the file is sourced
2. User-customizable section at the top (not managed)
3. `### managed by automation ###` wrapper around the synced section
4. The synced section primarily contains:
   ```bash
   source <($HOME/src/nsheaps/dotfiles/bin/dotfiles init)
   ```

### Header Comments
**~/.zshrc / ~/.bashrc:**
```bash
# sourced when an interactive shell is spawned. Use to customize the feel of
# your terminal, but scripts run outside the terminal may not use this setup
```

**~/.zprofile / ~/.bash_profile:**
```bash
# sourced when you login to your computer. Changes here need a restart to take
# effect. These commands should never print output, as it may cause issues with
# automation running the script.
```

### bin/dotfiles Script
The script should support at least:
- `dotfiles init` - Outputs shell script to stdout (for `source <(...)` pattern)
- `dotfiles sync` - Syncs the managed section of ~/.zshrc, ~/.zprofile, ~/.bashrc, ~/.bash_profile

The `init` command behavior depends on which shell/file is sourcing it:
- For login shells (zprofile/bash_profile): Source `~/.profile.d/*.sh`
- For interactive shells (zshrc/bashrc): Source `~/.profile.d/*.sh` then `~/.interactive.d/*.sh`

## Scripts to Create

### profile.d/ (login shell scripts)
1. **00-env.sh** - Environment variables (Java/OpenJDK 21, .NET, NVM setup)

### interactive.d/ (interactive shell scripts)
1. **claude-cc-runclaude.sh** - Core function that launches Claude in a workspace directory
2. **claude-cc-newsession.sh** - Creates new Claude workspace sessions (includes cc-tmp)
3. **claude-cc-resume.sh** - Resumes existing Claude workspace sessions (includes cc-resumesession)
4. **kpup.sh** - Kill process using port utility

## Current State / Cleanup Needed

### Already Completed
- ✅ `~/shellrc.d` symlink - removed
- ✅ `/Users/nathan.heaps/src/nsheaps/dotfiles/shellrc.d/` directory - removed

### Still Need Cleanup
- `~/.zshrc` lines 27-32 - Remove shellrc.d sourcing logic (dead code)

### Existing _home Structure (review needed)
- `_home/.zshrc` - Has antidote setup, may need update
- `_home/.zshrc.d/00_zshconfig.zsh` - Review first, then migrate or remove
- `_home/.zprofile`, `_home/.zshenv`, `_home/.zsh_plugins.txt`

### Important: Edit _home/ not ~/
- All RC file edits should be made to `_home/` versions
- DO NOT edit files in `~/` directly during refactoring
- After refactoring is complete, create a wiring script to sync _home/ to ~/

## Next Steps

1. Review `_home/.zshrc.d/00_zshconfig.zsh` contents
2. Create `_home/.profile.d/` directory
3. Create `_home/.interactive.d/` directory
4. Create `bin/dotfiles` script with `init` and `sync` subcommands
5. Move/create environment setup in `_home/.profile.d/00-env.sh`
6. Migrate recovered Claude functions to `_home/.interactive.d/claude-*.sh`:
   - cc-runclaude → claude-cc-runclaude.sh
   - cc-newsession → claude-cc-newsession.sh
   - cc-tmp → claude-cc-tmp.sh (wrapper)
   - cc-resume/cc-resumesession → claude-cc-resume.sh
7. Move utilities to `_home/.interactive.d/` (e.g., kpup.sh if exists)
8. Update _home/.zshrc with managed section and header comment
9. Update _home/.zprofile with managed section and header comment
10. Update _home/.bashrc with managed section and header comment
11. Update _home/.bash_profile with managed section and header comment (create if needed)
12. Create symlinks for .profile.d and .interactive.d
13. Test shell initialization
14. Clean up unused files (_home/.zshrc.d) - SAFELY (backup first!)
15. Create wiring script to sync _home/ to ~/ (after refactor complete)

## Open Questions
- Should we keep the antidote setup in the `dotfiles init` output or in the managed section directly?
- Should `.zshenv` also be managed?
- How does the dotfiles init script detect whether it's being called from a login shell vs interactive shell?
