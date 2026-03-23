# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="robbyrussell"

# Random theme candidates
ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Enable command auto-correction
ENABLE_CORRECTION="true"

# Plugins
plugins=(
  git
  z
  fzf
  sudo
  docker
  kubectl
  aliases
  copypath
  web-search
)

source $ZSH/oh-my-zsh.sh

# Aliases
alias zshconfig="mate ~/.zshrc"

# PATH
export PATH="/opt/nvim/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
