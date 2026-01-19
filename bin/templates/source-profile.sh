# Source all profile.d scripts
# Uses same pattern as bin/source-scripts.sh --output
if [[ -d "$PROFILE_D" ]]; then
  for __source_script in $(find -L "$PROFILE_D" -maxdepth 1 -type f -name '*.sh' 2>/dev/null | sort); do
    [[ -f "$__source_script" ]] && source "$__source_script"
  done
  unset __source_script
fi
