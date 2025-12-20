# Dotfiles Migration Guide

**Date**: 2025-12-20
**Status**: Ready for migration (with caveats)

## Overview

This migration restructures shell configuration from a scattered approach to an organized, modular system using `profile.d/` and `interactive.d/` directories.

---

## What Changes

### Before (Current ~/):
- `~/.zshrc` - Monolithic file with inline antidote bundles, shellrc.d sourcing
- `~/.zprofile` - Simple file with OrbStack integration
- `~/.bashrc` - Sources .zshrc (zsh-specific, causes issues)
- No organized structure for shell scripts

### After (_home/):
- `_home/zshrc` - Clean file with managed section calling `dotfiles init`
- `_home/zprofile` - Brew, mise, and managed section
- `_home/bashrc` - Proper bash configuration with managed section
- `_home/bash_profile` - Login shell configuration
- `_home/profile.d/` - Environment variables (Java, .NET, NVM)
- `_home/interactive.d/` - Interactive shell functions (Claude workspace tools)
- `bin/dotfiles` - Central init script
- `bin/wire` - Migration/sync script

---

## What Gets Improved

### 1. **Organization**
- ✅ Clear separation: login scripts (profile.d/) vs interactive scripts (interactive.d/)
- ✅ One file per feature/integration (easy to add/remove)
- ✅ Visible files in repo (no hidden dot prefixes)

### 2. **Performance**
- ✅ Static antidote loading (faster shell startup)
- ✅ Scripts only source when needed (login vs interactive)

### 3. **Maintainability**
- ✅ Managed sections clearly marked
- ✅ User customizations separated from automation
- ✅ Easy to see what's automated vs manual

### 4. **Portability**
- ✅ Works for both bash and zsh
- ✅ Dynamic repository path detection
- ✅ Shell-agnostic .sh scripts

### 5. **Features**
- ✅ Claude workspace management functions (cc-tmp, cc-newsession, cc-resume)
- ✅ Better environment variable organization
- ✅ Proper bash support (not just sourcing zshrc)

---

## What Won't Work / Gets Lost

### User Customizations (EXPECTED - Not in Repo)

These are intentionally NOT migrated because they're user-specific:

1. **OrbStack Integration** (`~/.zprofile`)
   - Located in user-customizable section
   - Will continue working if added above managed section

2. **rbenv Integration** (`~/.bashrc`)
   - User-specific Ruby version management
   - Add to user-customizable section if needed

3. **Any other tools you've installed** that auto-modified RC files
   - These belong in the user-customizable sections
   - NOT in the repo (by design)

### Structural Changes (INTENTIONAL)

1. **antidote Loading Method**
   - Old: Dynamic mode (inline bundles at every shell startup)
   - New: Static mode (faster, requires ~/.zsh_plugins.txt file)
   - **Migration**: The zsh_plugins.txt file exists in _home/ and will be synced

2. **shellrc.d/ Sourcing**
   - Old: Sources ~/shellrc.d/*.sh (doesn't exist anymore)
   - New: Sources via `dotfiles init`
   - **Impact**: Lines 27-32 in current ~/.zshrc are dead code (will be removed)

---

## Migration Process

### Step 1: Review (DONE)
- ✅ Reviewed current vs new implementation
- ✅ Identified what's intentionally not migrated (user customizations)
- ✅ Fixed critical issue (setopt interactivecomments)

### Step 2: Pre-Migration Checklist

Before running `bin/wire`:

- [ ] Verify all RC files in _home/ are correct
- [ ] Check that zsh_plugins.txt exists and has correct content
- [ ] Review user-customizable sections for any needed additions
- [ ] Backup current ~/ RC files (safety)
  ```bash
  mkdir -p ~/.rc-backup
  cp ~/.zshrc ~/.zprofile ~/.bashrc ~/.zshenv ~/.rc-backup/
  ```

### Step 3: Run Migration

```bash
cd ~/src/nsheaps/dotfiles

# Remove the safety exit from bin/wire
# Edit bin/wire and remove line 7: exit 1

# Run the wiring script
bin/wire
```

This will:
1. Create `~/.profile.d` → `_home/profile.d` symlink
2. Create `~/.interactive.d` → `_home/interactive.d` symlink
3. Copy RC files from `_home/` to `~/` (with dot prefixes added)

### Step 4: Post-Migration

```bash
# Start a new shell to test
zsh

# Verify functions work
cc-tmp --help  # Should explain usage
type cc-newsession  # Should show function definition

# Check environment
echo $JAVA_HOME  # Should show OpenJDK 21 path
echo $NVM_DIR  # Should show ~/.nvm
```

### Step 5: Add User Customizations

If you use OrbStack, rbenv, or other tools, add them to the user-customizable section of `_home/zshrc` or `_home/zprofile`:

```bash
# In _home/zprofile (above ### managed by automation ###):

# OrbStack integration
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# rbenv (if needed)
eval "$(rbenv init - zsh)"
```

Then re-run `bin/wire` to sync to ~/.

---

## Gotchas for End Users

### 1. **Editing the Wrong Files**
❌ **DON'T**: Edit `~/.zshrc` directly
✅ **DO**: Edit `_home/zshrc` in the repo, then run `bin/wire`

**Why**: The bin/wire script copies from _home/ to ~/. Changes to ~/ files will be overwritten.

**Exception**: The user-customizable section (above the managed block) is preserved and won't be overwritten.

### 2. **Antidote Plugins**
❌ **DON'T**: Modify ~/.zshrc to add plugins
✅ **DO**: Edit `_home/zsh_plugins.txt`, then run `bin/wire`

The system uses static plugin loading. Adding plugins via the old inline bundle method won't work.

### 3. **Running bin/wire After Changes**
After editing files in `_home/`, you MUST run `bin/wire` to sync changes to ~/.

**Quick workflow**:
```bash
cd ~/src/nsheaps/dotfiles
# Edit _home/zshrc or other files
git add . && git commit -m "update zshrc"
bin/wire  # Sync to ~/
source ~/.zshrc  # Or open new terminal
```

### 4. **Path Assumptions**
The scripts assume the repo is at `~/src/nsheaps/dotfiles`. If you clone elsewhere, the paths in RC files need updating.

**Mitigation**: Use the dynamic path resolution in bin/dotfiles (already implemented), but the RC files still hardcode the path.

### 5. **NVM and mise Both Managing Node**
Both tools are configured:
- `profile.d/00-env.sh` initializes NVM
- `zprofile` activates mise shims for node@lts

This creates potential conflicts. **Recommendation**: Choose one tool for node management.

### 6. **Auto-Installing gum**
The `cc-resume` function auto-installs `gum` via Homebrew without prompting. This could be unexpected. Consider prompting first.

---

## What Still Needs Work

1. **bin/dotfiles refactoring** - Use cat/files instead of echo strings (cleaner code)
2. **Interactive shell check** - Move from output into script logic
3. **rc.d/00_setup_symlinks.sh** - Update for new architecture
4. **README** - Update documentation

---

## Rollback Plan

If something goes wrong:

```bash
# Restore from backup
cp ~/.rc-backup/.zshrc ~/.zshrc
cp ~/.rc-backup/.zprofile ~/.zprofile
cp ~/.rc-backup/.bashrc ~/.bashrc
cp ~/.rc-backup/.zshenv ~/.zshenv

# Remove new symlinks
rm ~/.profile.d ~/.interactive.d

# Restart shell
exec zsh
```

---

## Key Architectural Decisions

### Why Copy Instead of Symlink RC Files?

The `bin/wire` script **copies** RC files rather than symlinking them. This allows:
- User customizations in the user-customizable section
- Repo contains clean baseline
- Users can override without affecting repo

**Trade-off**: Must remember to run `bin/wire` after repo changes.

### Why Separate profile.d and interactive.d?

- **profile.d**: Login shells (environment variables, paths) - runs once at login
- **interactive.d**: Interactive shells (functions, aliases) - runs at every terminal

This prevents:
- Duplicate PATH entries
- Slower shell startup
- Functions being unavailable in non-interactive contexts

---

## Success Criteria

After migration, verify:

1. ✅ New shell starts without errors
2. ✅ Claude functions work: `cc-tmp`, `cc-newsession`, `cc-resume`
3. ✅ Environment variables set: `$JAVA_HOME`, `$NVM_DIR`, `$DOTNET_ROOT`
4. ✅ Antidote plugins loaded (check with `antidote list`)
5. ✅ User customizations still work (OrbStack, rbenv, etc.)
6. ✅ Both bash and zsh work correctly

---

## Timeline

**Preparation**: 5-10 minutes (backup, review)
**Migration**: 2 minutes (run bin/wire)
**Testing**: 10-15 minutes (verify everything works)
**Fixes**: 5-30 minutes (add back user customizations if needed)

**Total**: 20-60 minutes depending on customizations needed
