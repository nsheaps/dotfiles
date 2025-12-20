# Source all profile.d scripts
for file in "$PROFILE_D"/*.sh; do
  [[ -f "$file" ]] && source "$file"
done
