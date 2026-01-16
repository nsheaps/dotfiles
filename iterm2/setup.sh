#!/usr/bin/env bash
# iTerm2 Configuration Setup Script
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ITERM_APP_SUPPORT="$HOME/Library/Application Support/iTerm2"
DYNAMIC_PROFILES_DIR="$ITERM_APP_SUPPORT/DynamicProfiles"

echo "🔧 Setting up iTerm2 profiles..."

# Create DynamicProfiles directory if it doesn't exist
if [[ ! -d "$DYNAMIC_PROFILES_DIR" ]]; then
  echo "📁 Creating DynamicProfiles directory..."
  mkdir -p "$DYNAMIC_PROFILES_DIR"
fi

# Copy custom profiles
echo "📋 Installing custom profiles..."
cp "$SCRIPT_DIR/DynamicProfiles/custom-profiles.json" "$DYNAMIC_PROFILES_DIR/"

echo "✅ iTerm2 profiles installed successfully!"
echo ""
echo "The following profiles are now available:"
echo "  • stainless (blue theme, light/dark mode support)"
echo "  • nsheaps (purple theme, light/dark mode support)"
echo ""
echo "Profiles will automatically switch based on your current directory:"
echo "  • */src/stainless-api* or */src/stainless* → stainless profile"
echo "  • */src/nsheaps* → nsheaps profile"
echo ""
echo "Auto-switching is configured in: _home/interactive.d/iterm-auto-profile.sh"
echo ""
echo "If iTerm2 is currently open, restart it or open a new window to see the profiles."
