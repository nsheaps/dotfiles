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

### stainless-api

- **Background**: Light gray (#EEEEEE)
- **Purpose**: Visual indicator for stainless-api directories
- **Auto-switch**: Activates in directories matching `*/stainless-api*` or `*/stainless/*`

### nsheaps

- **Background**: Light pink (#FFE4E1)
- **Purpose**: Visual indicator for nsheaps personal directories
- **Auto-switch**: Activates in directories matching `*/nsheaps*` or `*/.ai*`

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

| Color      | Hex     | RGB (0-1)         |
| ---------- | ------- | ----------------- |
| Light Gray | #EEEEEE | 0.93, 0.93, 0.93  |
| Light Pink | #FFE4E1 | 1.0, 0.894, 0.882 |

To convert hex to decimal: `Decimal = Hex / 255`

## Resources

- [iTerm2 Dynamic Profiles Documentation](https://iterm2.com/documentation-dynamic-profiles.html)
- [iTerm2 Automatic Profile Switching](https://iterm2.com/documentation-automatic-profile-switching.html)
