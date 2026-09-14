#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../lib/common.sh
. "$SCRIPT_DIR/../lib/common.sh"

ARCH=$(uname -m)
OS=$(uname -s)

echo "Detected architecture: $ARCH, OS: $OS"

# Set when Neovim is installed from a tarball into /opt/nvim, so the rest of
# the script knows it has to put that directory on PATH itself.
NVIM_BIN_DIR=""

install_via_brew() {
  if brew list --formula neovim &>/dev/null; then
    echo "Neovim is already installed via Homebrew, checking for updates..."
    brew upgrade neovim || echo "Neovim is already up to date."
  else
    echo "Installing Neovim via Homebrew..."
    brew install neovim
  fi
}

install_via_tarball() {
  local name url tmpdir tarball

  case "$OS/$ARCH" in
    Darwin/arm64) name="nvim-macos-arm64" ;;
    Darwin/x86_64) name="nvim-macos-x86_64" ;;
    Linux/x86_64) name="nvim-linux-x86_64" ;;
    Linux/aarch64 | Linux/arm64) name="nvim-linux-arm64" ;;
    *)
      echo "Unsupported OS/architecture: $OS/$ARCH"
      echo "This script supports macOS (arm64, x86_64) and Linux (x86_64, arm64)."
      exit 1
      ;;
  esac

  url="https://github.com/neovim/neovim/releases/latest/download/${name}.tar.gz"
  tmpdir="$(make_tempdir)"
  tarball="$tmpdir/${name}.tar.gz"

  # Download as the current user into a temp dir: no root-owned leftovers in
  # the repo, and nothing to clean up by hand if this fails.
  #
  # -f makes curl fail on HTTP errors instead of writing the error page to
  # disk; without it a 504 from GitHub's CDN is saved as the "tarball" and
  # only surfaces later as a confusing tar error. --retry then covers the
  # transient 5xx responses that -f now reports.
  echo "Downloading latest Neovim release for $ARCH..."
  if ! curl -fL --retry 5 --retry-delay 3 --connect-timeout 15 -o "$tarball" "$url"; then
    echo "Error: failed to download Neovim from $url"
    echo "GitHub may be temporarily unavailable. Please try again in a moment."
    exit 1
  fi

  # Guard against a well-formed but non-archive response slipping through.
  echo "Verifying downloaded archive..."
  if ! tar -tzf "$tarball" >/dev/null 2>&1; then
    echo "Error: the downloaded file is not a valid tar.gz archive."
    exit 1
  fi

  # Extract to the temp dir first so a bad archive can never leave the machine
  # without a working Neovim. /opt/nvim is only replaced once this succeeds.
  echo "Extracting Neovim tar file..."
  tar -C "$tmpdir" -xzf "$tarball"

  if [ ! -x "$tmpdir/$name/bin/nvim" ]; then
    echo "Error: extracted archive does not contain bin/nvim as expected."
    exit 1
  fi

  echo "Installing Neovim to /opt/nvim..."
  sudo rm -rf /opt/nvim
  sudo mv "$tmpdir/$name" /opt/nvim

  NVIM_BIN_DIR="/opt/nvim/bin"
}

# Prefer Homebrew on macOS: it handles updates, uninstalls and PATH for us.
# Fall back to the official tarball when Homebrew is not available.
if [[ "$OS" == "Darwin" ]] && command -v brew &>/dev/null; then
  install_via_brew
else
  if [[ "$OS" == "Darwin" ]]; then
    echo "Homebrew not found, falling back to the official tarball."
    echo "To use Homebrew instead, install it first:"
    echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
  fi
  install_via_tarball
fi

if [ -n "$NVIM_BIN_DIR" ]; then
  echo "Updating PATH..."
  if ! grep -q "/opt/nvim/bin" ~/.zshrc; then
    echo 'export PATH="/opt/nvim/bin:$PATH"' >>~/.zshrc
  fi
  export PATH="$NVIM_BIN_DIR:$PATH"
fi

NVIM_CONFIG_DIR="${HOME}/.config/nvim"

echo "Setting up Neovim config..."
mkdir -p "${HOME}/.config"

# Stage the config exactly as it should land, minus this installer, so it can
# be compared against what is already installed before anything is touched.
NVIM_STAGED=$(make_tempdir)
cp -R "$SCRIPT_DIR"/. "$NVIM_STAGED"/
rm -f "$NVIM_STAGED/install.sh"

install_tree "$NVIM_STAGED" "$NVIM_CONFIG_DIR" "Neovim config"

echo "Installing plugins via lazy.nvim..."
nvim --headless "+Lazy! sync" +qa

echo "Installation complete!"
echo "👉 Restart your terminal or run: source ~/.zshrc"
