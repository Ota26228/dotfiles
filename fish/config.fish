# PATH
fish_add_path ~/.local/bin /usr/local/bin
fish_add_path ~/.cargo/bin
fish_add_path ~/.npm-global/bin

# Environment
set -x EDITOR nvim
set -g fish_greeting ""

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
    starship init fish | source
end
