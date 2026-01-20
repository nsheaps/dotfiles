# Dotfiles Implementation Review

**Branch:** `feat/complete-dotfiles-refactoring`
**Merge Base:** `e485be96936b4f5cbe093c78609316f40733f44c`
**Review Date:** 2026-01-19

---

## Implementation Summary

This branch refactors the dotfiles system from an eval-based initialization approach to a managed-sections architecture using `bin/wire`. The new system:

1. Creates symlinks for script directories (`profile.d`, `interactive.d`, `startup.d`, `update.d`)
2. Injects managed sections into shell RC files that source canonical files from `_home/`
3. Consolidates Claude CLI functions into a single `interactive.d/claude.sh` file
4. Adds iTerm2 dynamic profile management with automatic switching
5. Removes old hook scripts that are no longer needed

---

## Critical Findings

### 1. [ADDRESSED] Bash RC Files No Longer Reference Deleted Script

**Previous Status:** `_home/bashrc` and `_home/bash_profile` referenced deleted `bin/dotfiles init`
**Current Status:** Files now contain minimal shell configuration - the old eval reference is gone.

**Verification:**
- `/Users/nathan.heaps/src/nsheaps/dotfiles/_home/bashrc` - Now contains only user-customizable section placeholder
- `/Users/nathan.heaps/src/nsheaps/dotfiles/_home/bash_profile` - Sources Homebrew correctly

**Result:** FIXED

### 2. [ADDRESSED] Missing ~/.dotfiles Symlink

**Previous Status:** `~/.dotfiles` symlink was missing
**Current Status:** Symlink exists and points correctly

**Verification:**
```
~/.dotfiles -> /Users/nathan.heaps/src/nsheaps/dotfiles
```

**Result:** FIXED

### 3. [ADDRESSED] Hardcoded Homebrew Path for Antidote

**Previous Status:** Hardcoded `/opt/homebrew/opt/antidote/share/antidote/functions`
**Current Status:** Now uses dynamic detection:
```zsh
if (( $+commands[brew] )); then
  _antidote_dir="$(brew --prefix antidote 2>/dev/null)/share/antidote"
  if [[ -d "$_antidote_dir/functions" ]]; then
    fpath=("$_antidote_dir/functions" $fpath)
    autoload -Uz antidote
  fi
  unset _antidote_dir
fi
```

**Location:** `/Users/nathan.heaps/src/nsheaps/dotfiles/_home/zshrc:36-43`

**Result:** FIXED - Works on both Apple Silicon and Intel Macs

### 4. [NEW] Bash Sources Zsh File - Causes Errors

**Location:** `~/.bashrc:2`
**Issue:** The deployed `~/.bashrc` contains:
```bash
#!/usr/bin/env bash
\. "$HOME/.zshrc"
```

This sources `.zshrc` from Bash, which causes errors because `.zshrc` uses zsh-specific syntax:
- `setopt interactivecomments` - Zsh builtin, not available in Bash
- `*(.:t)` glob qualifiers - Zsh-only syntax

**Verification Output:**
```
/Users/nathan.heaps/src/nsheaps/dotfiles/_home/zshrc: line 12: setopt: command not found
/Users/nathan.heaps/src/nsheaps/dotfiles/_home/zshrc: line 27: syntax error near unexpected token `('
```

**Impact:** Bash shells will see errors on startup (though the managed section still loads correctly after)

**Recommendation:** Remove the `. "$HOME/.zshrc"` line from `~/.bashrc` since the managed section already handles loading the correct configuration.

### 5. [NEW] Mise Config Drift Between Repo and HOME

**Location:** `/Users/nathan.heaps/src/nsheaps/dotfiles/_home/.config/mise/config.toml` vs `~/.config/mise/config.toml`

**Repository Version:**
```toml
[tools]
bun = "latest"
go = "latest"
node = "lts"
python = "latest"

[hooks]
preinstall = "echo 'I am about to install tools'"
postinstall = "echo 'I just installed tools'"

[settings]
verbose = true
jobs = 4
```

**HOME Version:**
```toml
[tools]
bun = "latest"
go = "latest"
node = "lts"
"npm:happy-coder" = "latest"
pipx = "latest"
python = "latest"
```

**Issue:** The symlink in repo root (`mise_config.toml -> ~/.config/mise/config.toml`) means HOME is the source of truth, but the `_home/.config/mise/config.toml` file in the repo is NOT symlinked - they are separate files.

**Impact:** Changes in HOME are not tracked; repo copy is outdated and missing `npm:happy-coder` and `pipx`.

**Recommendation:** Either:
1. Remove `_home/.config/mise/config.toml` from tracking and use only the symlink, OR
2. Change `bin/wire` to symlink `.config/mise/` to track the repo version

### 6. [NEW] iTerm README Documentation Error

**Location:** `/Users/nathan.heaps/src/nsheaps/dotfiles/_home/.config/iterm2/README.md:32`

**Issue:** States profiles are installed by `_home/update.d/00-iterm-profiles.sh` but the actual script is at `_home/startup.d/00-iterm-profiles.sh`.

**Recommendation:** Update line 32 to reference the correct path.

---

## Opportunities for Improvement

### 1. Zfunctions Autoload Conditional Works Correctly

**Location:** `/Users/nathan.heaps/src/nsheaps/dotfiles/_home/zshrc:24-28`
**Status:** The conditional directory check prevents errors when `~/.zfunctions` doesn't exist. Well implemented.

### 2. Interactive.d TTY Check Works as Designed

**Location:** `/Users/nathan.heaps/src/nsheaps/dotfiles/_home/zshrc:60-64`

The `[[ -t 1 ]]` check ensures interactive.d scripts only run in true TTY sessions:
- Functions like `open-iterm`, `claude`, `cc-tmp` are correctly available in interactive shells
- They are correctly NOT loaded in non-interactive contexts (scripts, cron, etc.)

**Verification:** Using `script -q /dev/null zsh -ic 'type open-iterm'` confirms functions load in interactive mode.

### 3. rc.d/00_setup_symlinks.sh Simplified

**Previous Status:** Had unused `link()` function
**Current Status:** Now just outputs informational message:
```bash
echo "Dotfiles directory loaded. Run 'bin/wire' to set up symlinks."
```

**Assessment:** Simplified appropriately - no dead code.

### 4. Claude Functions Consolidated

**Previous Status:** Multiple files for Claude-related functions
**Current Status:** Single `/Users/nathan.heaps/src/nsheaps/dotfiles/_home/interactive.d/claude.sh` with all functions:
- `claude`, `ccresume`, `cccontinue`, `claude-update` (shorthands)
- `cc-runclaude`, `cc-newsession`, `cc-tmp`, `cc-resume`, `cc-resumesession` (workspace management)

**Assessment:** Good consolidation. Clear organization with section headers.

---

## Workflow Analysis

### Update Flow
**How updates are pulled:**
1. `git pull` in the dotfiles repo
2. Script directory changes (`profile.d/`, `interactive.d/`, etc.) are immediate via symlinks
3. Template changes require re-running `bin/wire`
4. New shell sessions pick up changes automatically

**Assessment:** Efficient. The symlink approach means most changes are live immediately.

### Push Flow
**How changes are committed:**
1. Edit files in `_home/` directory
2. Standard git workflow: `git add`, `git commit`, `git push`
3. No special tooling required

**Assessment:** Simple and standard.

### Discovery
**How users know where to edit:**
- README clearly documents `_home/` as the canonical location
- Documentation updated to reflect wire-based architecture
- `.claude/rules/architecture.md` accurately describes the system

**Potential Confusion:**
- Repo-root symlinks (`zshrc`, `zprofile`, `zshenv`) point to HOME, not `_home/`
- `mise_config.toml` symlink points to HOME, which diverges from pattern

**Assessment:** Mostly clear, but the two different symlink patterns could confuse users.

### Modularity
**Assessment of shareability:**
- Script directories are well-modularized (one function/feature per file)
- Each interactive.d script is self-contained
- Path dependencies are minimal (uses `$DOTFILES_DIR` environment variable)
- Could be shared to other machines with minimal adaptation

### Environment Impact
**Effect on other repositories:**
- `.envrc` only affects the dotfiles directory itself
- No direnv pollution in other repos
- Mise shims work globally via `.zprofile` activation
- iTerm profile switching is based on directory path, non-invasive

**Assessment:** Clean separation. No unexpected side effects.

---

## Architectural Concerns

### 1. Two Symlink Patterns Coexist

The repository has two different approaches to file management:

| Pattern | Example | Source of Truth |
|---------|---------|-----------------|
| Managed Section | `~/.zshrc` sources `_home/zshrc` | Repo (`_home/`) |
| Convenience Symlink | `./mise_config.toml` -> `~/.config/mise/config.toml` | HOME |
| Convenience Symlink | `./zshrc` -> `~/.zshrc` | HOME (which sources repo) |

This creates cognitive overhead. Users might expect all canonical files to be in `_home/`, but mise config is tracked differently.

**Recommendation:** Document this explicitly in the README or consider unifying the approach.

### 2. iTerm Profile Installation Location

The `00-iterm-profiles.sh` script is in `startup.d/` (run at login) which is appropriate. However:
- It copies files rather than symlinking
- Uses a marker prefix (`dotfiles-managed-`) for cleanup

This is a reasonable approach since iTerm may not handle symlinked dynamic profiles well.

### 3. Claude Function Complexity

The `_home/interactive.d/claude.sh` file is 167 lines with complex workspace management logic. While well-organized, it might benefit from:
- Separating core shorthands from workspace management
- Adding unit tests for the workspace functions

This is a minor concern - the current implementation works.

---

## Comparison: Repository vs Deployed State

| Component | Repository | HOME | Status |
|-----------|-----------|------|--------|
| ~/.zshrc | `_home/zshrc` | Contains managed section | OK |
| ~/.zprofile | `_home/zprofile` | Contains managed section | OK |
| ~/.zshenv | `_home/zshenv` | Contains managed section | OK |
| ~/.bashrc | `_home/bashrc` | Contains managed section + zsh source | **ISSUE** |
| ~/.bash_profile | `_home/bash_profile` | Contains managed section | OK |
| ~/.dotfiles | Created by `bin/wire` | Symlink to repo | OK |
| ~/.profile.d | Symlink target | Symlink to repo | OK |
| ~/.interactive.d | Symlink target | Symlink to repo | OK |
| ~/.startup.d | Symlink target | Symlink to repo | OK |
| ~/.update.d | Symlink target | Symlink to repo | OK |
| ~/.config/mise/config.toml | Different content | Has extra tools | **DRIFT** |
| ~/Library/.../DynamicProfiles/ | Source profiles | Copied with prefix | OK |

---

## Previous Critical Issues - Resolution Status

| Issue | Previous Status | Current Status |
|-------|----------------|----------------|
| Missing ~/.dotfiles symlink | BROKEN | FIXED |
| Bash files reference deleted bin/dotfiles | BROKEN | FIXED |
| Hardcoded Homebrew path for antidote | BROKEN on Intel | FIXED |
| Documentation references old eval pattern | OUTDATED | FIXED |
| Orphaned link() function in rc.d/ | DEAD CODE | REMOVED |
| Duplicate Claude functions | CONFUSING | CONSOLIDATED |

---

## Remaining Work

Based on the stated goals and current implementation:

1. **Remove stray zsh source from ~/.bashrc** - The line `\. "$HOME/.zshrc"` in the deployed `~/.bashrc` should be removed as it causes errors. This appears to be a pre-existing line that wasn't cleaned up during wiring.

2. **Reconcile mise config drift** - Either sync `_home/.config/mise/config.toml` with HOME, or change the tracking approach to use symlinks consistently.

3. **Fix iTerm README path** - Update `_home/.config/iterm2/README.md:32` to reference `startup.d/` instead of `update.d/`.

---

## Summary

The refactoring has achieved its core goals:
- Clean managed-sections approach replaces eval-based init
- Symlinks for script directories work correctly
- Antidote plugin loading is properly configured with dynamic Homebrew detection
- Claude functions are consolidated
- iTerm profile management is functional

**Critical issues from previous review are resolved.** The remaining issues are minor:
- Bash/Zsh source conflict in deployed ~/.bashrc (user-specific cleanup needed)
- Configuration drift in mise config
- Minor documentation error in iTerm README

The implementation is solid and maintainable. The architecture is clear and well-documented.
