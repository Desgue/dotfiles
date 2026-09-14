#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../lib/common.sh
. "$SCRIPT_DIR/../lib/common.sh"

OS=$(uname -s)

echo "Detected OS: $OS"

# Homebrew is only used on macOS here. The other modules install their packages
# with apt/dnf/yum on Linux, so there is nothing to do and this is not a failure.
if [[ "$OS" != "Darwin" ]]; then
  echo "Homebrew is only set up on macOS, skipping on $OS."
  exit 0
fi

# Install Homebrew
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# A fresh install is not on PATH yet: Homebrew drops /etc/paths.d/homebrew, which
# only takes effect in new shells. Point this one at brew directly so the rest of
# the script works without reopening the terminal.
if ! command -v brew &>/dev/null; then
  for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [ -x "$candidate" ]; then
      eval "$("$candidate" shellenv)"
      break
    fi
  done
fi

if ! command -v brew &>/dev/null; then
  echo "Error: Homebrew was installed but brew is still not on PATH."
  echo "  Open a new terminal and run this script again."
  exit 1
fi

say_ok "Homebrew is ready at $(brew --prefix)."

# Install the packages
BREWFILE="$SCRIPT_DIR/Brewfile"

echo "Installing packages from Brewfile..."
brew bundle --file="$BREWFILE"

echo "Homebrew setup complete!"
