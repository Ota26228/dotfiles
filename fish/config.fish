# PATH
fish_add_path ~/.local/bin /usr/local/bin
fish_add_path ~/.cargo/bin
fish_add_path ~/.npm-global/bin

# Environment
set -x EDITOR nvim
set -x NIXOS_OZONE_WL 1
set -g fish_greeting ""
set -gx XMODIFIERS @im=fcitx
set -gx GTK_IM_MODULE fcitx
set -gx QT_IM_MODULE fcitx

if status is-interactive
    # Vim keybinds
    fish_vi_key_bindings

    # Aliases
    alias vim nvim
    alias vi nvim
    alias copy 'wl-copy'
    alias paste 'wl-paste'
    alias fishconfig 'nvim ~/.config/fish/config.fish'
    alias vconfig 'nvim ~/.config/nvim/init.lua'
    alias music music_tui

    # Starship
    if command -q starship
        starship init fish | source
    end

    # direnv（プロジェクトの devShell を cd で自動有効化）
    if command -q direnv
        direnv hook fish | source
    end
end
set -x FLYCTL_INSTALL "/home/ota2525/.fly"
set -x PATH "$FLYCTL_INSTALL/bin" $PATH

