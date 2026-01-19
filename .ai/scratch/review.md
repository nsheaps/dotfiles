# Dotfiles Implementation Review

**Branch:** `feat/complete-dotfiles-refactoring`
**Merge Base:** `e485be96936b4f5cbe093c78609316f40733f44c`
**Review Date:** 2026-01-19

## Implementation Summary

This branch introduces a significant architectural refactoring of the dotfiles system, moving from:
- An `eval`-based init script approach (`bin/dotfiles init`)
- To a managed-sections approach with `bin/wire` that injects source commands into RC files

The new system creates symlinks for script directories (`profile.d`, `interactive.d`, `startup.d`, `update.d`) and injects managed sections into shell RC files that source canonical files from the repository.

---

## Critical Findings

### 1. Missing ~/.dotfiles Symlink

**Location:** `bin/wire:47`
**Issue:** The wire script creates `~/.dotfiles` symlink (line 47), but verification shows it does not exist in the deployed state.

```bash
$ ls -la ~/.dotfiles
# No such file or directory
```

The symlink should point to `/Users/nathan.heaps/src/nsheaps/dotfiles` but is missing. This is a **deployment state issue** - either `bin/wire` was not run, or the command failed silently.

**Impact:** Any scripts or documentation referencing `~/.dotfiles` will fail.

### 2. Bash RC Files Reference Deleted Script

**Location:** `_home/bashrc:9`, `_home/bash_profile:13`
**Issue:** Both files contain:
```bash
eval "$($HOME/src/nsheaps/dotfiles/bin/dotfiles init)"
```

But `bin/dotfiles` has been **deleted** in this branch (shown in git diff as `-63 lines`). The bash templates source files correctly, but the canonical bash files in `_home/` still reference the old system.

**Impact:** Bash shells will error when sourcing these files because `bin/dotfiles` no longer exists.

### 3. Inconsistent Documentation References

**Location:** `README.md:100-101`, `README.md:116-118`
**Issue:** The README still documents the old `eval "$(dotfiles init)"` pattern:
```bash
# In ~/.zshrc, ~/.zprofile, etc.:
eval "$($HOME/src/nsheaps/dotfiles/bin/dotfiles init)"
```

But the actual system now uses managed sections with direct source commands. The README needs updating to reflect the new `bin/wire` approach.

### 4. Antidote Plugin Source Missing from HOME

**Location:** `_home/zshrc:32-33`
**Issue:** The zshrc references `${DOTFILES_DIR}/_home/zsh_plugins.txt` as the source, but there is no `~/.zsh_plugins.txt` file:

```bash
$ ls ~/.zsh_plugins.txt
# No such file or directory (only ~/.zsh_plugins.zsh exists)
```

This works because the code reads from `DOTFILES_DIR` directly, but the `.claude/rules/architecture.md` documentation incorrectly states plugins should be in `~/.zsh_plugins.txt`.

---

## Opportunities for Improvement

### 1. Simplify source-scripts.sh --output Mode

**Location:** `bin/source-scripts.sh:66-78`
**Issue:** The `--output` mode generates shell code for eval, but this mode is not used anywhere in the codebase. The zshrc sources scripts directly with a simple for loop.

**Recommendation:** Remove the `--output` mode unless there's a planned use case. It adds complexity without current utility.

### 2. Remove Duplicate Claude CLI Functions

**Location:** `_home/interactive.d/`
**Issue:** Multiple files define similar Claude-related functions:
- `claude-shorthands.sh` - defines `claude()`, `ccresume()`, `cccontinue()`
- `claude-cc-runclaude.sh`, `claude-cc-newsession.sh`, `claude-cc-resume.sh` - likely older implementations

**Recommendation:** Consolidate into a single file to avoid confusion and potential shadowing.

### 3. Hardcoded Homebrew Path

**Location:** `_home/zshrc:36`
```zsh
fpath=(/opt/homebrew/opt/antidote/share/antidote/functions $fpath)
```

**Issue:** This assumes Apple Silicon Mac (`/opt/homebrew`). Intel Macs use `/usr/local`.

**Recommendation:** Use `$(brew --prefix)` or detect dynamically:
```zsh
fpath=("$(brew --prefix antidote)/share/antidote/functions" $fpath)
```

### 4. rc.d/00_setup_symlinks.sh is Orphaned

**Location:** `rc.d/00_setup_symlinks.sh`
**Issue:** This file has a sophisticated `link()` function that's never called. The actual symlinking is done by `bin/wire`. The file only outputs a message: "Dotfiles directory initialized (no auto-linking enabled)"

**Recommendation:** Either enable the link functionality or remove the dead code.

---

## Workflow Analysis

### Update Flow
**How updates are pulled:**
1. User runs `git pull` in the dotfiles repo
2. Changes to `_home/` files are immediately reflected via symlinks (for `.profile.d`, `.interactive.d`, etc.)
3. Changes to RC file templates require re-running `bin/wire`

**Assessment:** Partially automatic. Script directory changes propagate instantly, but template changes require manual action.

### Push Flow
**How changes are committed:**
1. Edit files in `_home/` directory
2. Run `git add`, `git commit`, `git push`
3. No special tooling required

**Assessment:** Simple and standard Git workflow. No issues.

### Discovery
**How users know where to edit:**
- Documentation points to `_home/` as the canonical location
- Symlinks in repo root (`zshrc`, `zprofile`, `zshenv`) point to HOME versions
- This creates ambiguity: editing the symlink edits HOME, not the repo

**Assessment:** The bidirectional symlinks could cause confusion. Editing `~/src/nsheaps/dotfiles/zshrc` actually edits `~/.zshrc`, not `_home/zshrc`.

### Modularity
**Assessment of shareability:**
- Script directories (`profile.d`, `interactive.d`) are well-modularized
- Individual scripts can be shared or removed independently
- However, paths are hardcoded to this specific user's directory structure

### Environment Impact
**Effect on other repositories:**
- The `.envrc` sources `rc.d/*.sh` when entering the dotfiles directory
- This creates the `link()` function in the shell environment
- No impact on other repositories since direnv only affects the dotfiles directory

---

## Architectural Concerns

### 1. Two Competing Initialization Systems

The branch contains remnants of two different systems:
1. **Old system:** `bin/dotfiles init` with eval (documented in README, referenced in bash files)
2. **New system:** `bin/wire` with managed sections and symlinks

This creates confusion and potential for errors. The old system references should be completely removed.

### 2. Symlink Direction Inconsistency

- **Script directories:** `~/.profile.d` -> `_home/profile.d` (repo is source of truth)
- **RC files:** `~/.zshrc` <- managed section sources `_home/zshrc` (HOME has the actual file)
- **Repo convenience symlinks:** `./zshrc` -> `~/.zshrc` (points to HOME)
- **mise config:** `./mise_config.toml` -> `~/.config/mise/config.toml` (HOME is source of truth)

This inconsistency makes it unclear which location is canonical for different file types.

### 3. Startup vs Update Separation

The separation between `startup.d` (idempotent, run at login) and `update.d` (risky, run manually) is well-designed but:
- `update.d/` is empty except for a `.gitkeep` with documentation
- No actual update scripts exist yet
- The distinction is documented but not demonstrated

---

## Comparison: Repository vs Deployed State

| Component | Repository | HOME | Status |
|-----------|-----------|------|--------|
| ~/.zshrc | `_home/zshrc` | Contains managed section | OK |
| ~/.zprofile | `_home/zprofile` | Contains managed section | OK |
| ~/.zshenv | `_home/zshenv` | Contains managed section | OK |
| ~/.bashrc | `_home/bashrc` (refs deleted script) | Contains managed section | **MISMATCH** |
| ~/.bash_profile | `_home/bash_profile` (refs deleted script) | Contains managed section | **MISMATCH** |
| ~/.dotfiles | Created by `bin/wire` | Missing | **MISSING** |
| ~/.profile.d | Symlink target | Symlink to repo | OK |
| ~/.interactive.d | Symlink target | Symlink to repo | OK |
| ~/.startup.d | Symlink target | Symlink to repo | OK |
| ~/.update.d | Symlink target | Symlink to repo | OK |
| ~/.zsh_plugins.txt | Not created | Not present | N/A (not needed) |
| ~/.zsh_plugins.zsh | Generated by antidote | Present | OK |

---

## Remaining Work

Based on the stated goals of the refactoring:

1. **Fix `_home/bashrc` and `_home/bash_profile`** - Remove references to deleted `bin/dotfiles`, align with new wire-based system

2. **Re-run `bin/wire`** - Deploy the missing `~/.dotfiles` symlink

3. **Update README.md** - Replace references to `eval "$(dotfiles init)"` with the new managed section pattern

4. **Update `.claude/rules/architecture.md`** - Fix documentation about `~/.zsh_plugins.txt` (it's sourced from DOTFILES_DIR, not HOME)

5. **Clean up rc.d/00_setup_symlinks.sh** - Either use the `link()` function or remove the dead code

---

## Summary

The refactoring achieves its core goals of:
- Moving to a cleaner managed-sections approach
- Creating direct symlinks for script directories
- Consolidating antidote configuration in `_home/`

However, the branch has **incomplete cleanup** of the old system, resulting in broken bash shell initialization and documentation inconsistencies. These issues should be addressed before merging.
