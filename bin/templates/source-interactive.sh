# Source all interactive.d scripts
for file in "$INTERACTIVE_D"/*.sh; do
  [[ -f "$file" ]] && source "$file"
done
