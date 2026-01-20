# Implementation Plan: `open-iterm` Shell Function

## Overview

A shell function to open iTerm2 tabs with optional directory targeting and unique-tab detection.

**Target file:** `~/_home/interactive.d/open-iterm.sh`
**Status:** Implemented

## Requirements

1. Opens iTerm tab in current directory if no args
2. Takes a relative or absolute path as first arg to open tab there
3. Supports `--unique <dir>` flag: checks if a tab with that directory already exists, and if so, switches to it instead of opening a new one

## Technical Approach

### Challenge

iTerm2's AppleScript API does **not** expose working directory directly. Sessions only expose:
- `tty` - the TTY device (e.g., `/dev/ttys008`)
- `name` - session title (unreliable)
- `unique ID` - internal identifier

### Solution

Use TTY + lsof approach:
1. Get session's TTY from AppleScript
2. Find shell process on that TTY via `ps -t`
3. Get that process's cwd via `lsof -a -p <PID> -d cwd`

This works reliably without requiring shell integration or user configuration.

## Function Structure

```
open-iterm [--unique] [directory]
    |
    +-- Argument parsing
    |     +-- Check for --unique flag
    |     +-- Extract target directory (or use $PWD)
    |
    +-- Path resolution
    |     +-- Convert relative to absolute
    |     +-- Validate directory exists
    |
    +-- Branch: --unique mode
    |     +-- Get all iTerm sessions via AppleScript
    |     +-- For each: get TTY -> find shell PID -> get cwd
    |     +-- If matching tab found: select it
    |     +-- If not found: create new tab
    |
    +-- Branch: normal mode
          +-- Create new tab directly
```

## Helper Functions

| Function | Purpose |
|----------|---------|
| `_get_cwd_for_pid` | Get working directory from PID via lsof |
| `_get_shell_pid_for_tty` | Find shell process running on a TTY |
| `_get_iterm_session_cwd` | Combine above to get session's directory |
| `_get_all_iterm_sessions` | AppleScript to enumerate all sessions with TTYs |
| `_select_iterm_tab` | AppleScript to activate a specific tab |
| `_create_iterm_tab` | AppleScript to create tab and cd |

## Usage Examples

```bash
# Open tab in current directory
open-iterm

# Open tab in specific directory
open-iterm ~/src/myproject

# Open or switch to existing tab
open-iterm --unique ~/src/myproject

# Shorthand aliases
oit ~/src          # Same as open-iterm ~/src
oitu ~/src         # Same as open-iterm --unique ~/src
```

## Edge Cases Handled

| Case | Behavior |
|------|----------|
| Non-existent directory | Error with message, return 1 |
| Relative path | Resolved to absolute before use |
| Path with spaces | Properly quoted in AppleScript |
| No matching tab (--unique) | Creates new tab |
| TTY lookup fails | Skips that session, continues search |

## Known Limitation

If no iTerm windows are open, the `create tab` command will fail. A future enhancement could detect this and create a window first.

## Dependencies

All built into macOS:
- `osascript` - AppleScript execution
- `lsof` - Process file listing
- `ps` - Process status

## References

- [iTerm2 Scripting Documentation](https://iterm2.com/documentation-scripting.html)
- [lsof man page](https://ss64.com/mac/lsof.html)
