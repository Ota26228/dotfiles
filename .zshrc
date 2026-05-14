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
ZSH_THEME=""

plugins=(
    git
    zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# ---------------------------------------------------------
# Aliases
# ---------------------------------------------------------
alias vim='nvim'
alias vi='nvim'

alias clip='xclip -selection clipboard'
alias copy='xclip -selection clipboard'
alias paste='xclip -selection clipboard -o'

alias zshconfig='nvim ~/.zshrc'
alias vconfig='nvim ~/.config/nvim/init.lua'

alias music='music_tui'

# ---------------------------------------------------------
# Tool Settings (NVM / Other)
# ---------------------------------------------------------
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# ---------------------------------------------------------
# Starship
# ---------------------------------------------------------
eval "$(starship init zsh)"
