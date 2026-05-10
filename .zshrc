# ---------------------------------------------------------
# Path / Environment Variables
# ---------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"
export EDITOR='nvim'

# ---------------------------------------------------------
# Oh My Zsh Settings
# ---------------------------------------------------------
# テーマ設定
ZSH_THEME="agnoster"

# プラグイン設定
# git: Gitステータス表示
# zsh-autosuggestions: 予測補完 (今回追加)
plugins=(
    git
    zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# ---------------------------------------------------------
# Aliases
# ---------------------------------------------------------
# Editor
alias vim='nvim'
alias vi='nvim'

# Clipboard (xclip)
alias clip='xclip -selection clipboard'
alias copy='xclip -selection clipboard'
alias paste='xclip -selection clipboard -o'

# Quick Config Access
alias zshconfig='nvim ~/.zshrc'
alias vconfig='nvim ~/.config/nvim/init.lua'

alias music='music_tui'
# ---------------------------------------------------------
# Tool Settings (NVM / Other)
# ---------------------------------------------------------
# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# ---------------------------------------------------------
# Custom Script / Fixes
# ---------------------------------------------------------
# もし予測変換の色が薄すぎて見えない場合は、以下を有効にしてください
# ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'
. $HOME/export-esp.sh
