#!/bin/bash
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

echo "=== dotfiles install ==="

# ─── yay ───────────────────────────────────────────────────────────────────
if ! command -v yay &>/dev/null; then
    echo "[yay] installing..."
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
    rm -rf /tmp/yay
fi

# ─── pacman packages ───────────────────────────────────────────────────────
PACMAN_PKGS=(
    sway autotiling i3status-rust
    foot mako tofi swaylock swaybg
    btop brightnessctl
    grim slurp wl-clipboard
    fcitx5 fcitx5-mozc fcitx5-gtk fcitx5-qt
    fish starship
    qutebrowser
    mpd rmpc
    bluez bluez-utils bluez-obex
    polkit-kde-agent xdg-desktop-portal-gtk
    neovim yazi
    xdg-utils
)

echo "[pacman] installing packages..."
sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"

# ─── AUR packages ──────────────────────────────────────────────────────────
AUR_PKGS=(
    impala
    wiremix
    bluetuith
)

echo "[aur] installing packages..."
yay -S --needed --noconfirm "${AUR_PKGS[@]}"

# ─── symlinks ──────────────────────────────────────────────────────────────
link() {
    local src="$DOTFILES/$1"
    local dst="$2"
    mkdir -p "$(dirname "$dst")"
    ln -sf "$src" "$dst"
    echo "  $dst -> $src"
}

echo "[symlinks]"
link sway/config          ~/.config/sway/config
link i3status-rust        ~/.config/i3status-rust
link fish/config.fish     ~/.config/fish/config.fish
link foot                 ~/.config/foot
link mako                 ~/.config/mako
link tofi                 ~/.config/tofi
link qutebrowser          ~/.config/qutebrowser
link nvim                 ~/.config/nvim
link starship.toml        ~/.config/starship.toml
link btop.conf            ~/.config/btop/btop.conf

# ─── fcitx5 環境変数 ────────────────────────────────────────────────────────
FISH_CONF="$DOTFILES/fish/config.fish"
if ! grep -q "GTK_IM_MODULE" "$FISH_CONF"; then
    echo "[fcitx5] adding environment variables..."
    cat >> "$FISH_CONF" << 'EOF'

# fcitx5
set -x GTK_IM_MODULE fcitx
set -x QT_IM_MODULE fcitx
set -x XMODIFIERS @im=fcitx
EOF
fi

# ─── Wallpapers ─────────────────────────────────────────────────────────────
mkdir -p ~/Wallpapers
if [ ! -f ~/Wallpapers/bg2.jpg ]; then
    echo "[wallpaper] ~/Wallpapers/bg2.jpg が見つかりません。手動で配置してください。"
fi

# ─── services ───────────────────────────────────────────────────────────────
echo "[services]"
sudo systemctl enable --now bluetooth
systemctl --user enable --now mpd

echo ""
echo "done. sway を起動してください。"
