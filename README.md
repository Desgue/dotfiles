# dotfiles

My personal setup for Homebrew packages, zsh, Neovim, tmux, and Claude Code. One
command gets a new machine to the same state as the old one.

## Requirements

- macOS (Apple Silicon) or Linux (x86_64 / arm64)
- `git` and `curl`
- An account with `sudo` access, needed by the Homebrew installer on macOS and by
  the Neovim tarball fallback on Linux

Homebrew is not a prerequisite: on macOS `homebrew/install.sh` installs it when it
is missing.

## Install

```bash
git clone https://github.com/Desgue/dotfiles.git
cd dotfiles
./install.sh
```

`install.sh` asks which pieces you want. Pass them directly to skip the menu:

```bash
./install.sh --all         # everything
./install.sh zsh tmux      # just these
```

Then restart your terminal (or run `source ~/.zshrc`).

After the first tmux session starts, press `Ctrl-a` then `I` to download the
tmux plugins.

## What it does

`install.sh` runs the scripts you picked. Each one can also be run on its own:

| Script | What it sets up |
| --- | --- |
| `homebrew/install.sh` | Installs Homebrew if it is missing, then every package in `homebrew/Brewfile`. macOS only |
| `zsh/install.sh` | Installs zsh and Oh My Zsh, then copies `.zshrc` to your home folder |
| `nvim/install.sh` | Installs Neovim with Homebrew, or the latest release into `/opt/nvim` when Homebrew is unavailable, copies the config to `~/.config/nvim`, and installs the plugins |
| `tmux/install.sh` | Installs tmux, copies `.tmux.conf`, and adds the tmux plugin manager |
| `claude/install.sh` | Installs Claude Code settings and skills into `~/.claude` |

Example, if you only want tmux:

```bash
./tmux/install.sh
```

To add or drop a package, edit `homebrew/Brewfile` and run `./install.sh homebrew`
again. Anything already installed is reported as `Using ...` and left alone.

## Your existing files

The scripts copy files into place instead of linking them. A config is only
touched when it actually differs from the one in this repo; when it already
matches, the script says so and moves on. When it does differ, the current
version is saved with a `.bak` ending first, and an existing `.bak` is never
overwritten, so re-running the installer is safe.

`claude/install.sh` asks before changing anything already in `~/.claude`:

- **Merge** (default) adds this repo's skills and settings, keeping your own.
  `settings.json` is merged key by key with `jq`, so machine-specific settings
  survive.
- **Replace** uses this repo's version, after taking a backup.
- **Skip** leaves it alone.

Use `--merge`, `--replace`, or `--skip` to answer up front.

Because files are copied, editing a config in your home folder does not change
this repo. Edit the file here, commit it, and run the matching script again to
apply it.

## Updating

```bash
git pull
./install.sh
```

Anything already up to date is reported as such and left untouched.
