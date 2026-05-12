# dotfiles

Personal macOS configuration by emre.

## Overview

| Tool | Role |
|------|------|
| [Paneru](https://github.com/karinushka/paneru) | Sliding tiling window manager |
| [SketchyBar](https://github.com/FelixKratz/SketchyBar) | Custom menu bar |
| [borders](https://github.com/FelixKratz/JankyBorders) | Active window border highlight |
| [fastfetch](https://github.com/fastfetch-cli/fastfetch) | System info on terminal launch |
| Zsh | Shell with custom prompt |

## Preview

> Shell prompt: `user@host ~/path %` in green/white  
> Window border: `#b3e1a7` (green) active, `#3c3836` inactive, 6px rounded  
> Menu bar: transparent, clock + battery + volume + window titles

## Requirements

- macOS
- Internet connection (Homebrew, Xcode Tools, and optionally Rust are fetched automatically)

## Install

```bash
git clone https://github.com/yourusername/dotfiles.git
cd dotfiles
chmod +x install.sh
./install.sh
```

The installer will:

1. Install Homebrew if not present
2. Check for Xcode Command Line Tools
3. Append shell config to `~/.zshrc` (PROMPT, PATH, aliases)
4. Install Paneru — choose between **stable** (brew) or **testing** (built from source, ~5-10 min)
5. Copy `.config/` contents to `~/.config/`
6. Install `borders`, `sketchybar`, and `fastfetch` via Homebrew
7. Open `custom.terminal` for the terminal theme

After the installer finishes, run:

```bash
source ~/.zshrc
paneru install
paneru start
brew services start borders
brew services restart sketchybar
```

> **Note:** Paneru requires Accessibility permissions. A dialog should appear on first launch — if not, go to System Settings → Privacy & Security → Accessibility and add it manually.

## Paneru Keybindings

| Shortcut | Action |
|----------|--------|
| `ctrl + alt + ,` | Focus window west |
| `ctrl + alt + .` | Focus window east |
| `cmd + ctrl + alt + ,` | Swap window west |
| `cmd + ctrl + alt + .` | Swap window east |
| `ctrl + alt + ]` | Resize window wider |
| `ctrl + alt + [` | Resize window narrower |
| `ctrl + alt + '` | Full width |
| `ctrl + alt + ;` | Manage window |
| `ctrl + alt + q` | Quit Paneru |

## Shell

Lines added to `~/.zshrc`:

```zsh
PROMPT='%F{#b3e1a7}%n%f%F{#ffffff}@%f%F{#b3e1a7}%m%f %F{#ffffff}%~ %F{#ffffff}%%%f '
alias matrix='cmatrix -C green'
export PATH="$HOME/.local/bin:$PATH"
```

## Structure

```
dotfiles/
├── .config/
│   ├── paneru/        # paneru.toml
│   ├── sketchybar/    # sketchybarrc + plugins/
│   ├── borders/       # bordersrc
│   └── fastfetch/     # config.jsonc
├── assets/
│   └── wallpaper.jpg
├── custom.terminal
└── install.sh
```
