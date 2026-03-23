#!/bin/bash

ARCH=$(uname -m)
OS=$(uname -s)
echo "Detected architecture: $ARCH, OS: $OS"

if [[ "$OS" == "Darwin" ]]; then
  DOWNLOAD_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-macos-arm64.tar.gz"
  EXTRACTED_DIR="nvim-macos-arm64"
  TARBALL="nvim-macos-arm64.tar.gz"
elif [[ "$OS" == "Linux" && "$ARCH" == "x86_64" ]]; then
  DOWNLOAD_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
  EXTRACTED_DIR="nvim-linux-x86_64"
  TARBALL="nvim-linux-x86_64.tar.gz"
elif [[ "$OS" == "Linux" && ("$ARCH" == "aarch64" || "$ARCH" == "arm64") ]]; then
  DOWNLOAD_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.tar.gz"
  EXTRACTED_DIR="nvim-linux-arm64"
  TARBALL="nvim-linux-arm64.tar.gz"
else
  echo "Unsupported OS/architecture: $OS/$ARCH"
  echo "This script supports macOS (arm64) and Linux (x86_64, arm64)."
  exit 1
fi

set -e

echo "Downloading latest Neovim release for $ARCH..."
sudo curl -LO "$DOWNLOAD_URL"

echo "Removing old Neovim installation..."
sudo rm -rf /opt/nvim

echo "Extracting Neovim tar file..."
sudo tar -C /opt -xzf "$TARBALL"
sudo mv "/opt/$EXTRACTED_DIR" /opt/nvim

echo "Cleaning installation file..."
sudo rm "$TARBALL"

echo "Updating PATH..."
if ! grep -q "/opt/nvim/bin" ~/.zshrc; then
  echo 'export PATH="/opt/nvim/bin:$PATH"' >>~/.zshrc
fi

echo "Installation complete!"
echo "👉 Restart your terminal or run: source ~/.zshrc"
