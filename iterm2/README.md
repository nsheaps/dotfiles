# iTerm2 Configuration

This directory contains iTerm2 profile configurations that are version-controlled in dotfiles.

## Structure

```
iterm2/
├── DynamicProfiles/
│   └── custom-profiles.json    # Custom profile definitions
├── setup.sh                     # Installation script
└── README.md                    # This file
```

## Profiles

### stainless

- **Light Mode Background**: Light blue (#E3F2FD)
- **Dark Mode Background**: Dark blue (#1E3A5F)
- **Purpose**: Visual indicator for stainless directories
- **Auto-switch**: Activates in directories matching `*/src/stainless-api*` or `*/src/stainless*`

### nsheaps

- **Light Mode Background**: Light purple (#F3E5F5)
- **Dark Mode Background**: Dark purple (#3E2A47)
- **Purpose**: Visual indicator for nsheaps personal directories
- **Auto-switch**: Activates in directories matching `*/src/nsheaps*`

## Installation

Run the setup script to install profiles:

```bash
cd ~/src/nsheaps/dotfiles/iterm2
./setup.sh
```

Or manually:

```bash
# Create DynamicProfiles directory if it doesn't exist
mkdir -p ~/Library/Application\ Support/iTerm2/DynamicProfiles/

# Copy profile configuration
cp DynamicProfiles/custom-profiles.json \
   ~/Library/Application\ Support/iTerm2/DynamicProfiles/
```

iTerm2 will automatically detect and load the profiles.

## Automatic Profile Switching

The automatic profile switching is handled by `_home/interactive.d/iterm-auto-profile.sh`, which:

1. Hooks into shell directory changes (chpwd for zsh, PROMPT_COMMAND for bash)
2. Detects current directory path
3. Sends iTerm2 escape sequences to switch profiles

### Customizing Switch Rules

Edit `_home/interactive.d/iterm-auto-profile.sh` and modify the case statement:

```bash
case "$current_dir" in
  */your-pattern*)
    iterm2_set_profile "YourProfile"
    ;;
esac
```

## Color Reference

Colors are defined using decimal RGB values (0-1 scale):

| Profile   | Mode       | Color       | Hex     | RGB (0-1)        |
| --------- | ---------- | ----------- | ------- | ---------------- |
| stainless | Light Mode | Light Blue  | #E3F2FD | 0.89, 0.95, 0.99 |
| stainless | Dark Mode  | Dark Blue   | #1E3A5F | 0.12, 0.23, 0.37 |
| nsheaps   | Light Mode | Light Purple| #F3E5F5 | 0.95, 0.90, 0.96 |
| nsheaps   | Dark Mode  | Dark Purple | #3E2A47 | 0.24, 0.16, 0.28 |

To convert hex to decimal: `Decimal = Hex / 255`

## Resources

- [iTerm2 Dynamic Profiles Documentation](https://iterm2.com/documentation-dynamic-profiles.html)
- [iTerm2 Automatic Profile Switching](https://iterm2.com/documentation-automatic-profile-switching.html)
