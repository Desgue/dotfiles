#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OS=$(uname -s)

echo "Detected OS: $OS"

# Install tmux
if ! command -v tmux &>/dev/null; then
  echo "Installing tmux..."
  if [[ "$OS" == "Darwin" ]]; then
    if ! command -v brew &>/dev/null; then
      echo "Error: Homebrew is not installed. Please install it first:"
      echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
      exit 1
    fi
    brew install tmux
  elif [[ "$OS" == "Linux" ]]; then
    if command -v apt &>/dev/null; then
      sudo apt update && sudo apt install -y tmux
    elif command -v dnf &>/dev/null; then
      sudo dnf install -y tmux
    elif command -v yum &>/dev/null; then
      sudo yum install -y tmux
    else
      echo "Unsupported package manager. Please install tmux manually."
      exit 1
    fi
  else
    echo "Unsupported OS: $OS"
    exit 1
  fi
else
  echo "tmux is already installed."
fi

# Copy tmux config
TMUX_TARGET="$HOME/.tmux.conf"

echo "Setting up tmux config..."
if [ -L "$TMUX_TARGET" ]; then
  echo "Removing existing symlink at $TMUX_TARGET"
  rm "$TMUX_TARGET"
elif [ -f "$TMUX_TARGET" ]; then
  echo "Backing up existing .tmux.conf to ${TMUX_TARGET}.bak"
  mv "$TMUX_TARGET" "${TMUX_TARGET}.bak"
fi

cp "$SCRIPT_DIR/.tmux.conf" "$TMUX_TARGET"
echo "Copied tmux config to $TMUX_TARGET"

# Install TPM (Tmux Plugin Manager)
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
  echo "Installing TPM (Tmux Plugin Manager)..."
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
  echo "TPM is already installed."
fi

echo "Tmux setup complete!"
echo "Start a new tmux session and press prefix + I to install plugins."
