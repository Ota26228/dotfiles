#!/bin/bash
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

echo "=== dotfiles install ==="

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

echo ""
echo "[packages]"
echo "  pacman: sway autotiling i3status-rust foot mako tofi swaylock swaybg"
echo "          btop brightnessctl grim slurp wl-clipboard"
echo "          fcitx5 fcitx5-mozc fcitx5-gtk fcitx5-qt"
echo "          fish starship qutebrowser mpd rmpc"
echo "          bluez bluez-utils bluez-obex"
echo "  aur:    impala wiremix bluetuith"

echo ""
echo "done."
