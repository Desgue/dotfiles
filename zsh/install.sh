#!/bin/bash

set -e

OS=$(uname -s)
echo "Detected OS: $OS"

# Install zsh if not already installed
if ! command -v zsh &>/dev/null; then
  echo "Installing zsh..."
  if [[ "$OS" == "Darwin" ]]; then
    echo "zsh is included with macOS, skipping install."
  elif [[ "$OS" == "Linux" ]]; then
    if command -v apt &>/dev/null; then
      sudo apt update && sudo apt install -y zsh
    elif command -v dnf &>/dev/null; then
      sudo dnf install -y zsh
    elif command -v yum &>/dev/null; then
      sudo yum install -y zsh
    else
      echo "Unsupported package manager. Please install zsh manually."
      exit 1
    fi
  else
    echo "Unsupported OS: $OS"
    exit 1
  fi
else
  echo "zsh is already installed."
fi

# Install Oh My Zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "Oh My Zsh is already installed."
fi

# Copy .zshrc
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../lib/common.sh
. "$SCRIPT_DIR/../lib/common.sh"

ZSHRC_SOURCE="$SCRIPT_DIR/.zshrc"
ZSHRC_TARGET="$HOME/.zshrc"

echo "Setting up .zshrc..."
install_file "$ZSHRC_SOURCE" "$ZSHRC_TARGET" ".zshrc"

echo "Zsh setup complete!"
