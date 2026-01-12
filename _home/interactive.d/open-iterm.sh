#!/usr/bin/env bash
# Opens an iTerm tab in the specified directory

# Get working directory of a process by PID
_get_cwd_for_pid() {
    local pid="$1"
    lsof -a -p "$pid" -d cwd -F n 2>/dev/null | grep '^n' | cut -c2-
}

# Get shell PID for a TTY (finds the login shell, not subprocesses)
_get_shell_pid_for_tty() {
    local tty="$1"
    # Remove /dev/ prefix if present
    tty="${tty#/dev/}"
    # Get the shell process (usually has lowest PID or is parent of others)
    ps -t "$tty" -o pid,ppid,comm 2>/dev/null | awk '
        NR > 1 && ($3 ~ /^-?(bash|zsh|fish|sh)$/ || $3 ~ /bin\/(bash|zsh|fish|sh)$/) {
            print $1
            exit
        }
    '
}

# Get working directory for an iTerm session by its TTY
_get_iterm_session_cwd() {
    local tty="$1"
    local pid
    pid="$(_get_shell_pid_for_tty "$tty")"
    if [[ -n "$pid" ]]; then
        _get_cwd_for_pid "$pid"
    fi
}

# Find an existing iTerm tab with the given working directory
# Returns the tab index and window id if found
_find_iterm_tab_with_cwd() {
    local target_dir="$1"
    osascript <<EOF
tell application "iTerm2"
    repeat with w from 1 to count of windows
        tell window w
            repeat with t from 1 to count of tabs
                tell tab t
                    repeat with s in sessions
                        set sessionTTY to tty of s
                        -- We'll check the TTY externally
                        return w & "," & t & "," & sessionTTY
                    end repeat
                end tell
            end repeat
        end tell
    end repeat
end tell
return ""
EOF
}

# Get all iTerm sessions with their TTYs
_get_all_iterm_sessions() {
    osascript <<EOF
tell application "iTerm2"
    set output to ""
    repeat with w from 1 to count of windows
        tell window w
            repeat with t from 1 to count of tabs
                tell tab t
                    repeat with s in sessions
                        set sessionTTY to tty of s
                        set output to output & w & "," & t & "," & sessionTTY & "
"
                    end repeat
                end tell
            end repeat
        end tell
    end repeat
    return output
end tell
EOF
}

# Select a specific tab in iTerm
_select_iterm_tab() {
    local window_idx="$1"
    local tab_idx="$2"
    osascript <<EOF
tell application "iTerm2"
    activate
    tell window $window_idx
        select tab $tab_idx
    end tell
end tell
EOF
}

# Create a new iTerm tab and cd to directory
_create_iterm_tab() {
    local target_dir="$1"
    osascript <<EOF
tell application "iTerm2"
    activate
    tell current window
        create tab with default profile
        tell current session
            write text "cd '$target_dir' && clear"
        end tell
    end tell
end tell
EOF
}

# Main function
open-iterm() {
    local unique=false
    local target_dir

    # Parse arguments
    if [[ "$1" == "--unique" ]]; then
        unique=true
        shift
    fi

    # Get target directory
    if [[ -n "$1" ]]; then
        # Resolve to absolute path
        if [[ "$1" = /* ]]; then
            target_dir="$1"
        else
            target_dir="$(cd "$1" 2>/dev/null && pwd)"
            if [[ -z "$target_dir" ]]; then
                echo "Error: Directory '$1' does not exist" >&2
                return 1
            fi
        fi
    else
        target_dir="$(pwd)"
    fi

    # Normalize path (resolve symlinks, remove trailing slash)
    target_dir="$(cd "$target_dir" 2>/dev/null && pwd -P)"
    if [[ -z "$target_dir" ]]; then
        echo "Error: Cannot resolve directory" >&2
        return 1
    fi

    if [[ "$unique" == true ]]; then
        # Check existing sessions for matching directory
        local sessions
        sessions="$(_get_all_iterm_sessions)"

        while IFS=',' read -r window_idx tab_idx tty; do
            [[ -z "$tty" ]] && continue
            tty="$(echo "$tty" | tr -d '[:space:]')"

            local session_cwd
            session_cwd="$(_get_iterm_session_cwd "$tty")"

            if [[ "$session_cwd" == "$target_dir" ]]; then
                echo "Found existing tab at $target_dir (window $window_idx, tab $tab_idx)"
                _select_iterm_tab "$window_idx" "$tab_idx"
                return 0
            fi
        done <<< "$sessions"

        echo "No existing tab found for $target_dir, creating new one"
    fi

    _create_iterm_tab "$target_dir"
}

# Shorthand alias
oit() {
    open-iterm "$@"
}

oitu() {
    open-iterm --unique "$@"
}
