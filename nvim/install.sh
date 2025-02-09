#!/bin/bash
echo "Downloading latest Neovim release..."
sudo curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
echo "Removing old nvim installation..."
sudo rm -rf /opt/nvim
echo "Unziping nvim tar file..."
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
echo "Removing tar file..."
sudo rm nvim-linux-x86_64.tar.gz
echo "Exporting nvim to path..."
echo export PATH="$PATH:/opt/nvim-linux-x86_64/bin" >> ~/.zshrc
