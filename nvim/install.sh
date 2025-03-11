#!/bin/bash

ARCH=$(uname -m)
echo "Detected architecture: $ARCH"

if [[ "$ARCH" == "x86_64" ]]; then
  DOWNLOAD_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
  EXTRACTED_DIR="nvim-linux-x86_64"
  TARBALL="nvim-linux-x86_64.tar.gz"
elif [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
  DOWNLOAD_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.tar.gz"
  EXTRACTED_DIR="nvim-linux-arm64"
  TARBALL="nvim-linux-arm64.tar.gz"
else
  echo "Unsupported architecture: $ARCH"
  echo "This script supports x86_64 and ARM64 (aarch64) architectures."
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
