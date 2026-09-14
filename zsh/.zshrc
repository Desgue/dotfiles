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
# Prepend Homebrew; macOS path_helper appends it after /usr/bin and shadows it
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="/opt/nvim/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Drop duplicate PATH entries
typeset -U path PATH
