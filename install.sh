#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "========================================="
echo "  Dotfiles Installer"
echo "========================================="

echo ""
echo "--- Installing Zsh ---"
"$SCRIPT_DIR/zsh/install.sh"

echo ""
echo "--- Installing Neovim ---"
"$SCRIPT_DIR/nvim/install.sh"

echo ""
echo "--- Installing Claude Code ---"
"$SCRIPT_DIR/claude/install.sh"

echo ""
echo "========================================="
echo "  All done!"
echo "========================================="
echo "Restart your terminal or run: source ~/.zshrc"
