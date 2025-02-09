#!/bin/bash

set -e

echo "Downloading latest Neovim release..."
sudo curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz

echo "Removing old Neovim installation..."
sudo rm -rf /opt/nvim

echo "Extracting Neovim tar file..."
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
sudo mv /opt/nvim-linux-x86_64 /opt/nvim

echo "Cleaning installation file..."
sudo rm nvim-linux-x86_64.tar.gz

echo "Updating PATH..."
if ! grep -q "/opt/nvim/bin" ~/.zshrc; then
    echo 'export PATH="/opt/nvim/bin:$PATH"' >> ~/.zshrc
fi

echo "Installation complete!"
echo "👉 Restart your terminal or run: source ~/.zshrc"
