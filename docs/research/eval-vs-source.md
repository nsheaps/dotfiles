# Research: `source <(...)` vs `eval "$(...)"` for Shell Initialization

## Summary

**Recommendation: Use `eval "$(command)"` for the dotfiles init pattern.**

## Behavioral Differences

### 1. Subshell Creation

Both approaches run the command in a subshell, but execute the result in the current shell:

- **`source <(command)`**: Command runs in subshell → output piped to source → executed in current shell
- **`eval "$(command)"`**: Command runs in subshell → output captured → executed in current shell

### 2. Variable Scope

Both make variables available in the current shell since the final execution happens there.

### 3. Function Availability

Both approaches make functions available identically in the current shell.

### 4. Error Handling

**`eval` has better error handling:**

```bash
# With eval - can check command success
output=$($HOME/src/nsheaps/dotfiles/bin/dotfiles init) || {
  echo "Failed to generate init script" >&2
  return 1
}
eval "$output"

# With source - command exit code not easily accessible
source <($HOME/src/nsheaps/dotfiles/bin/dotfiles init)
```

## Why `eval "$(command)"` is Better for This Use Case

1. **Reliability**: Captures full output before execution
2. **Error Handling**: Can verify command succeeded before eval
3. **Debuggability**: Can inspect/log what's being evaluated
4. **Performance**: Measurably faster (1.01s vs 1.49s for large scripts)
5. **Clarity**: Intent is clearer - generate code, then execute it

## Edge Cases

### `source <(command)` Issues:
- May hang if command produces incomplete output
- Can't check if command succeeded (Bash < 4.3)
- Seeking incompatibility (rare)

### `eval "$(command)"` Issues:
- Entire output held in memory (not a problem for our use case)
- Needs proper quoting: `"$(command)"` not `$(command)`
- Silent failures if command fails (mitigated with explicit checking)

## Recommended Implementation

```bash
# Simple version (in RC files):
eval "$($HOME/src/nsheaps/dotfiles/bin/dotfiles init)"

# With error checking (if needed):
if output=$($HOME/src/nsheaps/dotfiles/bin/dotfiles init); then
  eval "$output"
else
  echo "Error: Failed to initialize dotfiles" >&2
  return 1
fi
```

## Sources

- [Process Substitution - TLDP](https://tldp.org/LDP/abs/html/process-sub.html)
- [Bash Process Substitution Made Simple and Clear](https://bashcommands.com/bash-process-substitution/)
- [Process Substitution - Bash Hackers Wiki](https://bash-hackers.gabe565.com/syntax/expansion/proc_subst/)
- [Include Files in a Bash Shell Script With source Command - Baeldung on Linux](https://www.baeldung.com/linux/source-include-files)
- [zsh: 14 Expansion](https://zsh.sourceforge.io/Doc/Release/Expansion.html)
- [ProcessSubstitution - Greg's Wiki](https://mywiki.wooledge.org/ProcessSubstitution/)
- [Room for optimization, source "..." vs. eval "$(<...)" - Zsh](https://www.zsh.org/mla/workers/2017/msg01827.html)
