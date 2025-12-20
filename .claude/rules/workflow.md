# Workflow Rules

## Following Hook Reminders

This project uses hooks that provide critical reminders about workflow steps. **These reminders are not optional suggestions - they are required steps.**

When you see a `<CRITICAL>` reminder (especially about using `/commit`):
- **DO NOT ignore it** just because you feel "done" with a task
- Follow through with the action immediately
- Treat hook reminders as part of the task completion criteria

Example: After updating `.ai/scratch/` files (todo.md, questions.md, plan.md), the hook will remind you to use `/commit`. You MUST follow through with the commit before moving on to the next task.

## Making Changes to Dotfiles

When modifying dotfiles:
- Edit files in the `_home/` directory (these are the canonical versions)
- Or edit the symlinks in `$HOME` directly (changes will be reflected in `_home/`)
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

Add plugin declarations to `_home/.zsh_plugins.txt`, then reload:
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
