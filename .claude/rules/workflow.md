# Workflow Rules

## Following Hook Reminders

This project uses hooks that provide critical reminders about workflow steps. **These reminders are not optional suggestions - they are required steps.**

When you see a `<CRITICAL>` reminder (especially about using `/commit`):
- **DO NOT ignore it** just because you feel "done" with a task
- Follow through with the action immediately
- Treat hook reminders as part of the task completion criteria

Example: After updating a scratch/planning doc (`plan.md`, `todo.md`, `questions.md`, etc — see "Scratch and Planning Docs" below), the hook will remind you to use `/commit`. You MUST follow through with the commit before moving on to the next task.

## Scratch and Planning Docs

Working docs for a specific piece of work (a plan, a todo list, open questions) live under `docs/<slug>/`, one directory per task or ticket — e.g. `docs/iterm2-profile-sync-automation/plan.md`. Use a short slugified summary of the task as the directory name, or the ticket number if one exists (e.g. `docs/ADX-123/plan.md`). Put whichever of `plan.md`/`todo.md`/`questions.md`/etc are actually relevant to that task in its directory; don't create empty placeholders for the others.

## Making Changes to Dotfiles

When modifying dotfiles:
- Edit files in `internal/` only for dotfiles' own mechanism — the shell rc loaders (`zshrc`/`zprofile`/`zshenv`/`bashrc`/`bash_profile`) and the two machinery drop-ins (`interactive.d/00-antidote.sh`, `interactive.d/staleness-check.sh`). These are always force-wired.
- Edit files in `_home/` for personal content — your plugin list (`zsh_plugins.txt`), personal `profile.d`/`interactive.d`/`startup.d`/`update.d` scripts, and `.config/`/`Library/`/`.local/bin/`. New personal shell scripts go in `_home/interactive.d/` (or `profile.d/`), not `internal/`.
- Or edit the symlinks in `$HOME` directly (changes will be reflected back into `internal/`/`_home/`)
- The `00_setup_symlinks.sh` script will warn if files have diverged and need manual reconciliation

## Testing Changes

After making changes to Zsh configuration:
```bash
source ~/.zshrc  # Or just open a new terminal
```

For direnv changes:
```bash
direnv allow .
```

## Adding New Plugins

Add plugin declarations to `_home/zsh_plugins.txt`, then reload:
```bash
source ~/.zshrc  # Antidote will regenerate ~/.zsh_plugins.zsh
```

## Managing Tool Versions

```bash
# Add a new tool globally
mise use -g <tool>@<version>

# List installed tools
mise ls

# The mise_config.toml symlink tracks ~/.config/mise/config.toml
```
