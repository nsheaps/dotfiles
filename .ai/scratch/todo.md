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

## Main Dotfiles Refactoring Tasks
- [ ] Remove shellrc.d sourcing logic from ~/.zshrc (lines 27-32)
- [ ] Create _home/.profile.d/ directory
- [ ] Create _home/.interactive.d/ directory
- [ ] Create bin/dotfiles script with init and sync subcommands
- [ ] Create _home/.profile.d/00-env.sh with environment variables
- [ ] Create interactive.d scripts (claude-*.sh, kpup.sh)
- [ ] Update ~/.zshrc with managed section and header comment
- [ ] Update ~/.zprofile with managed section and header comment
- [ ] Update ~/.bashrc with managed section
- [ ] Update ~/.bash_profile with managed section
- [ ] Create symlinks ~/.profile.d and ~/.interactive.d
- [ ] Test shell initialization in new terminal
- [ ] Clean up unused files (_home/.zshrc.d)
