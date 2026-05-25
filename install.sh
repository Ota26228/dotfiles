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
    waybar rofi
    foot mako tofi swaylock swaybg
    btop htop brightnessctl
    grim slurp wl-clipboard
    fcitx5 fcitx5-mozc fcitx5-gtk fcitx5-qt
    fish starship
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
    mangowm-git
    impala
    wiremix
    blupala
    mpd-mpris
    s-tui
    walker-bin
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
link mango/config.conf    ~/.config/mango/config.conf
link mango/autostart.sh   ~/.config/mango/autostart.sh
link waybar/config.jsonc  ~/.config/waybar/config
link waybar/style.css     ~/.config/waybar/style.css
link wlogout/layout       ~/.config/wlogout/layout
link wlogout/style.css    ~/.config/wlogout/style.css
link fish/config.fish     ~/.config/fish/config.fish
link foot                 ~/.config/foot
link mako                 ~/.config/mako
link tofi                 ~/.config/tofi
link nvim                 ~/.config/nvim
link starship.toml        ~/.config/starship.toml
link btop.conf            ~/.config/btop/btop.conf

# ─── services ───────────────────────────────────────────────────────────────
echo "[services]"
sudo systemctl enable --now bluetooth
systemctl --user enable --now mpd
systemctl --user enable --now mpd-mpris

echo ""
echo "done. mango を起動してください。"
