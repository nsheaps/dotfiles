# Todos

## Setup Sidequest (Completed)

- [x] Set up hooks for todo.md sync and questions.md monitoring
  - [feat: add Claude Code hooks for automated workflow management](https://github.com/nsheaps/dotfiles/commit/416779a)
- [x] Create .ai/scratch/ directory and initial files
  - [docs: add project management files for dotfiles refactoring](https://github.com/nsheaps/dotfiles/commit/9639c4e)
- [x] Review Claude Code docs for permissions syntax
- [x] Fix settings.json permissions to use recursive pattern
  - [feat: add Claude Code hooks for automated workflow management](https://github.com/nsheaps/dotfiles/commit/416779a)
- [x] Update TodoWrite hook to use stderr command instead of prompt
  - [feat: add Claude Code hooks for automated workflow management](https://github.com/nsheaps/dotfiles/commit/416779a)
- [x] Answer question in questions.md about readiness to begin
- [x] Commit hook setup and project management files
  - [feat: add Claude Code hooks for automated workflow management](https://github.com/nsheaps/dotfiles/commit/416779a)
  - [docs: add project management files for dotfiles refactoring](https://github.com/nsheaps/dotfiles/commit/9639c4e)
- [x] Update reminder.sh hook to use debounced file-based state (10s)
- [x] Behavior correction: Add "Respecting File Modifications" rule
  - [docs: add rule for respecting file modifications](https://github.com/nsheaps/.ai/commit/bd41e18)
- [x] User fixed hooks: Added <system> tags and exit 2 for stderr visibility
- [x] User added Stop and UserPromptSubmit hooks for check-questions.sh
- [x] Test hooks across all trigger points (PostToolUse, Stop, UserPromptSubmit)
- [x] Create update-hash.sh script to prevent double notifications
- [x] Add hash update hook for Edit/Write on questions.md
- [x] Create todo-reminder.sh script for todo.md updates
- [x] Add todo reminder hook for Edit/Write on todo.md
- [x] Update hook messaging to clarify todo.md vs TodoWrite relationship
- [x] Behavior correction: Add workflow rule about following hook reminders
- [x] Refactor CLAUDE.md into modular .claude/rules/ files
  - [refactor: split CLAUDE.md into modular rules files](https://github.com/nsheaps/dotfiles/commit/f09c68a)
- [x] Commit all hook improvements and push to remote
  - [fix: improve hook visibility with exit 2 and system tags](https://github.com/nsheaps/dotfiles/commit/bfd714a)
  - [feat: add debounced reminders and hash update hooks](https://github.com/nsheaps/dotfiles/commit/1936e19)
  - [feat: configure hooks for Stop, UserPromptSubmit, and SessionEnd](https://github.com/nsheaps/dotfiles/commit/30f2dd0)
  - [refactor: split CLAUDE.md into modular rules files](https://github.com/nsheaps/dotfiles/commit/f09c68a)
  - [docs: update project management files with hook improvements](https://github.com/nsheaps/dotfiles/commit/a8ace21)
- [x] Review plan/todos for accuracy and add clarifying questions
  - [docs: add clarifying questions about refactoring plan](https://github.com/nsheaps/dotfiles/commit/59519cf)
- [x] Behavior correction: Add safe file deletion rule for migrations
  - [docs: add safe file deletion rule for migrations](https://github.com/nsheaps/.ai/commit/f974978)
- [x] Document user answers and recovered shell functions
  - [docs: add user answers and recovered shell functions to questions](https://github.com/nsheaps/dotfiles/commit/fc8e8c2)

## Main Dotfiles Refactoring Tasks
- [x] Review _home/.zshrc.d/00_zshconfig.zsh contents (empty file, can be removed)
- [ ] Remove shellrc.d sourcing logic from ~/.zshrc (lines 27-32)
- [x] Create _home/.profile.d/ directory
- [x] Create _home/.interactive.d/ directory
- [x] Create bin/ directory
- [x] Create bin/dotfiles script with init and sync subcommands
- [x] Create _home/.profile.d/00-env.sh with environment variables
- [x] Create interactive.d scripts (claude-*.sh)
- [x] Refactor to use non-hidden directories (profile.d not .profile.d)
- [x] Update _home/.zshrc with managed section and header comment
- [x] Update _home/.zprofile with managed section and header comment
- [x] Create _home/.bashrc with managed section
- [x] Create _home/.bash_profile with managed section
- [x] Create bin/wire script to sync _home/ files to ~/
  - [feat: add wiring script to sync dotfiles to home directory](https://github.com/nsheaps/dotfiles/commit/136e3b1)
- [x] Fix argument passing in cc-resume wrapper
  - [fix: pass arguments correctly in cc-resume wrapper](https://github.com/nsheaps/dotfiles/commit/826c258)
- [x] Remove empty _home/.zshrc.d/00_zshconfig.zsh file
  - [chore: remove empty zshrc.d configuration file](https://github.com/nsheaps/dotfiles/commit/11119ba)
- [x] Make bin scripts portable using dynamic path resolution
- [x] Remove dot prefix from _home/ RC files for visibility
- [x] Research and choose between source <(...) vs eval "$(...)" → Use eval "$(...)"
  - Research saved to docs/research/eval-vs-source.md
- [x] Comprehensive review completed - review had incorrect assumptions
  - Review saved to .ai/scratch/review.md
  - Only real critical issue: setopt interactivecomments (now fixed)
  - OrbStack/rbenv are user customizations (not repo content)
  - zsh_plugins.txt already exists, zshenv okay to be missing
==== REVIEW COMPLETE - CRITICAL ISSUE FIXED ====
- [x] Fix gitignore to allow _home/zshrc tracking
  - [fix: update gitignore to only ignore root symlinks](https://github.com/nsheaps/dotfiles/commit/9612bd0)
- [x] Add setopt interactivecomments to _home/zshrc
  - [fix: update gitignore to only ignore root symlinks](https://github.com/nsheaps/dotfiles/commit/9612bd0)
- [x] Switch all RC files from source to eval per research findings
  - [refactor: switch from source to eval for dotfiles init](https://github.com/nsheaps/dotfiles/commit/602a6eb)
- [x] Run dotfiles-implementation-reviewer agent
- [x] Create migration guide and correct review.md assumptions
  - [docs: add migration guide and correct review assumptions](https://github.com/nsheaps/dotfiles/commit/d47c55f)
- [x] Create feature branch and draft PR
- [x] Fix security issue: Quote $CLAUDE_ARGS in claude-cc-runclaude.sh
  - [security: fix argument handling in claude-cc-runclaude](https://github.com/nsheaps/dotfiles/commit/f707258)
- [ ] Consider: Resolve NVM vs mise conflict for node management
- [ ] Consider: Prompt before auto-installing gum in cc-resume
- [x] Refactor bin/dotfiles init to use cat/files instead of echo strings
  - [refactor: use cat/templates and move interactive check into script](https://github.com/nsheaps/dotfiles/commit/743c6e6)
- [x] Move interactive shell check into bin/dotfiles script itself
  - [refactor: use cat/templates and move interactive check into script](https://github.com/nsheaps/dotfiles/commit/743c6e6)
- [x] Review rc.d/00_setup_symlinks.sh changes (RC symlinks commented out)

==== PAUSED FOR PR REVIEW ====
PR: https://github.com/nsheaps/dotfiles/pull/1

Recent updates:
- [x] Update rc.d/00_setup_symlinks.sh with new link() function
  - [refactor: update link() function for repo-as-source-of-truth](https://github.com/nsheaps/dotfiles/commit/b4cb0ad)
  - Repo is now source of truth
  - No auto-execution (safe, manual only)
  - RC files explicitly excluded (managed by bin/wire)
- [x] Clean up unused files (_home/.zshrc.d directory) - Already removed
- [x] Update README to reflect new architecture
  - [docs: update README for new modular architecture](https://github.com/nsheaps/dotfiles/commit/f139c91)

Tasks on hold until after review:
- [x] Refactor bin/wire to use symlinks + managed sections (not file copying)
  - Created bin/templates/zsh/{rc,env,profile}.zsh
  - Created bin/templates/bash/{rc,profile}.bash
  - Wire now injects managed sections with `source "$DOTFILES_DIR/_home/..."`
  - Wire creates symlinks for profile.d, interactive.d, startup.d, update.d
- [x] Run bin/wire to activate configuration
- [x] Remove duplicate hardcoded interactive.d sourcing from _home/zshrc
- [x] Simplify run-startup.sh and run-updates.sh (thin wrappers with logging)
- [x] Remove old bin/dotfiles and source-*.sh templates
- [x] Remove broken "managed by automation" sections from _home/zshrc and _home/zprofile
  - [refactor: simplify scripts and remove old dotfiles init system](https://github.com/nsheaps/dotfiles/commit/04ad432)
- [ ] Test shell initialization in new terminal
- [ ] Clean up unused files (_home/.zshrc.d directory)
- [ ] Remove shellrc.d sourcing logic from ~/.zshrc (dead code cleanup)
- [ ] Update README to reflect new architecture
- [ ] Design improvements for hook reminders to prevent duplicate firing (requires Plan agent + claude-code-guide agent to research Claude Code hooks documentation and architect a better design)
- [ ] Note: Use AskUserQuestion when you need to block and wait for user input - it's preferred over questions.md for blocking questions. questions.md is for async communication that doesn't block progress.

## Dynamic iTerm Config and update.d/startup.d Scripts

- [x] Explore current iTerm configuration and directory structure
- [x] Create bin/source-scripts.sh for DRY script sourcing from directories
- [x] Create bin/run-updates.sh for login item usage (runs update.d scripts)
- [x] Create _home/update.d/ folder structure
- [x] Create update.d/00-iterm-profiles.sh for iTerm configuration setup/cleanup
- [x] Refactor bin/dotfiles templates to use new source-scripts.sh pattern
- [x] Test the implementation
- [x] Move iterm2/ to _home/.config/iterm2/ for consistent _home syncing
- [x] Remove old setup.sh (replaced by update.d system)
- [x] Update README and references to new location
- [x] Separate startup.d (safe, automatic) from update.d (prompted, manual)
  - Created _home/startup.d/ for safe login scripts (iTerm profiles)
  - Created bin/run-startup.sh for Mac login items
  - Updated bin/run-updates.sh with oh-my-zsh style prompting
  - update.d now reserved for potentially risky update scripts
