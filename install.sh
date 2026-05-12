#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}"
echo "  ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗"
echo "  ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝"
echo "  ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗"
echo "  ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║"
echo "  ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║"
echo "  ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝"
echo -e "${NC}"
echo -e "${GREEN}  emre's dotfiles installer${NC}"
echo ""

# ─── Pre-checks ───────────────────────────────────────────────────────────────

# Homebrew check
if ! command -v brew &>/dev/null; then
    echo -e "${YELLOW}  Homebrew not found, installing...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    echo -e "${GREEN}  ✓ Homebrew installed.${NC}"
else
    echo -e "${GREEN}  ✓ Homebrew found.${NC}"
fi

# Xcode Command Line Tools check
if ! xcode-select -p &>/dev/null; then
    echo -e "${YELLOW}  Xcode Command Line Tools not found, installing...${NC}"
    echo -e "  ${CYAN}Click 'Install' in the dialog that appears, then re-run this script.${NC}"
    xcode-select --install
    echo -e "${RED}  Script paused. Re-run after Xcode Tools installation completes.${NC}"
    exit 1
else
    echo -e "${GREEN}  ✓ Xcode Command Line Tools found.${NC}"
fi

echo ""

# ─── 1. Patch .zshrc ──────────────────────────────────────────────────────────
echo -e "${YELLOW}[1/5] Patching ~/.zshrc...${NC}"

ZSHRC="$HOME/.zshrc"
MARKER="# dotfiles by emre"

if grep -qF "$MARKER" "$ZSHRC" 2>/dev/null; then
    echo -e "${GREEN}      ✓ .zshrc already patched, skipping.${NC}"
else
    # Create .zshrc if it doesn't exist
    touch "$ZSHRC"

    cat >> "$ZSHRC" << 'EOF'

# dotfiles by emre
PROMPT='%F{#b3e1a7}%n%f%F{#ffffff}@%f%F{#b3e1a7}%m%f %F{#ffffff}%~ %F{#ffffff}%%%f '
alias matrix='cmatrix -C green'
export PATH="$HOME/.local/bin:$PATH"
EOF

    echo -e "${GREEN}      ✓ PROMPT, alias and PATH appended to ~/.zshrc${NC}"
fi

# ─── 2. Paneru ────────────────────────────────────────────────────────────────
echo ""
echo -e "${YELLOW}[2/5] Paneru installation${NC}"
echo ""
echo "  Which version would you like to install?"
echo ""
echo -e "  ${CYAN}1)${NC} Stable   — brew install paneru"
echo -e "  ${CYAN}2)${NC} Testing  — build from source (requires Rust/Cargo, ~5-10 min)"
echo ""
read -rp "  Choice [1/2]: " paneru_choice

if [[ "$paneru_choice" == "1" ]]; then
    echo -e "${YELLOW}     Installing Paneru stable...${NC}"
    brew install paneru
    echo -e "${GREEN}     ✓ Paneru stable installed.${NC}"

elif [[ "$paneru_choice" == "2" ]]; then
    if ! command -v cargo &>/dev/null; then
        echo -e "${YELLOW}     Installing Rust and Cargo...${NC}"
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
        echo -e "${GREEN}     ✓ Cargo installed.${NC}"
    else
        echo -e "${GREEN}     ✓ Cargo already present, skipping.${NC}"
        [[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
    fi

    TMP_DIR="$(mktemp -d)"

    cleanup() {
        echo -e "${RED}     An error occurred, cleaning up...${NC}"
        cd "$SCRIPT_DIR"
        rm -rf "$TMP_DIR"
    }
    trap cleanup ERR

    echo -e "${YELLOW}     Cloning Paneru repository...${NC}"
    git clone https://github.com/karinushka/paneru "$TMP_DIR/paneru"
    cd "$TMP_DIR/paneru"

    echo -e "${YELLOW}     Building... (first build may take 5-10 minutes, please wait)${NC}"
    cargo build --release

    echo -e "${YELLOW}     Copying binary to ~/.local/bin...${NC}"
    mkdir -p "$HOME/.local/bin"
    cp "$TMP_DIR/paneru/target/release/paneru" "$HOME/.local/bin/paneru"
    chmod +x "$HOME/.local/bin/paneru"

    trap - ERR
    cd "$SCRIPT_DIR"
    rm -rf "$TMP_DIR"
    echo -e "${GREEN}     ✓ Paneru testing installed → ~/.local/bin/paneru${NC}"

else
    echo -e "${RED}     Invalid choice. Paneru installation skipped.${NC}"
fi

# ─── 3. Copy .config ──────────────────────────────────────────────────────────
echo ""
echo -e "${YELLOW}[3/5] Copying .config files...${NC}"
mkdir -p "$HOME/.config"
cp -r "$SCRIPT_DIR/.config/." "$HOME/.config/"
echo -e "${GREEN}      ✓ .config → ~/.config${NC}"

# ─── 4. borders, sketchybar, fastfetch ────────────────────────────────────────
echo ""
echo -e "${YELLOW}[4/5] Installing borders, sketchybar, fastfetch, cmatrix...${NC}"
brew tap FelixKratz/formulae 2>/dev/null || true
brew install borders sketchybar fastfetch cmatrix
echo -e "${GREEN}      ✓ Tools installed.${NC}"

# ─── 5. Terminal theme ────────────────────────────────────────────────────────
echo ""
echo -e "${YELLOW}[5/5] Loading terminal theme...${NC}"
open "$SCRIPT_DIR/custom.terminal"
echo -e "${GREEN}      ✓ custom.terminal opened.${NC}"
echo -e "      ${CYAN}To set as default: Terminal → Preferences → Profiles → custom → click 'Default'.${NC}"

# ─── Next steps ───────────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ✅ Installation complete!${NC}"
echo ""
echo -e "  Run the following commands to finish setup:"
echo ""
echo -e "  ${CYAN}source ~/.zshrc${NC}"
echo -e "  ${CYAN}paneru install${NC}"
echo -e "  ${CYAN}paneru start${NC}"
echo -e "  ${CYAN}brew services start borders${NC}"
echo -e "  ${CYAN}brew services restart sketchybar${NC}"
echo ""
echo -e "${YELLOW}  ⚠️  IMPORTANT: Paneru requires Accessibility permissions.${NC}"
echo -e "  A dialog may appear on first launch."
echo -e "  If not: System Settings → Privacy & Security → Accessibility"
echo -e "  → Add and enable Paneru manually."
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
