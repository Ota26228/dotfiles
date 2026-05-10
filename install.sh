#!/bin/bash
set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Colors ────────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()    { echo -e "${GREEN}==>${NC} $1"; }
warning() { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[x]${NC} $1"; exit 1; }

# ── Helper: create symlink (backs up existing files) ─────────────────────────
link() {
    local src="$DOTFILES/$1"
    local dst="$2"

    if [ ! -e "$src" ]; then
        warning "Source not found, skipping: $src"
        return
    fi

    mkdir -p "$(dirname "$dst")"

    if [ -L "$dst" ]; then
        rm "$dst"
    elif [ -e "$dst" ]; then
        warning "Backing up existing: $dst -> ${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi

    ln -s "$src" "$dst"
    info "Linked: $dst"
}

# ── 1. Install paru (AUR helper) ──────────────────────────────────────────────
if ! command -v paru &>/dev/null; then
    info "Installing paru..."
    sudo pacman -S --needed --noconfirm base-devel git
    cd /tmp
    git clone https://aur.archlinux.org/paru.git
    cd paru && makepkg -si --noconfirm
    cd "$DOTFILES"
fi

# ── 2. Install packages ───────────────────────────────────────────────────────
info "Installing packages..."
grep -v '^#' "$DOTFILES/packages.txt" | grep -v '^$' | paru -S --needed --noconfirm -

# ── 3. Create symlinks ────────────────────────────────────────────────────────
info "Creating symlinks..."

link "hypr"          "$HOME/.config/hypr"
link "ags"           "$HOME/.config/ags"
link "alacritty"     "$HOME/.config/alacritty"
link "nvim"          "$HOME/.config/nvim"
link "starship.toml" "$HOME/.config/starship.toml"
link ".zshrc"        "$HOME/.zshrc"
link ".zshenv"       "$HOME/.zshenv"

# ── 4. Install Ollama + model ─────────────────────────────────────────────────
info "Installing Ollama..."
if ! command -v ollama &>/dev/null; then
    curl -fsSL https://ollama.com/install.sh | sh
fi
sudo systemctl enable --now ollama
info "Pulling AI model (qwen2.5-coder:7b, ~4.5GB)..."
ollama pull qwen2.5-coder:7b

# ── 5. Enable services ────────────────────────────────────────────────────────
info "Enabling services..."
sudo systemctl enable --now bluetooth
sudo systemctl enable --now NetworkManager

# ── 6. Set zsh as default shell ───────────────────────────────────────────────
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    info "Setting zsh as default shell..."
    chsh -s /usr/bin/zsh
fi

info "Done! Please reboot or re-login."
