# dotfiles

My personal setup for zsh, Neovim, tmux, and Claude Code. One command gets a new
machine to the same state as the old one.

## Requirements

- macOS (Apple Silicon) or Linux (x86_64 / arm64)
- `git` and `curl`
- On macOS: [Homebrew](https://brew.sh)
- An account with `sudo` access (Neovim is installed into `/opt`)

## Install

```bash
git clone https://github.com/Desgue/dotfiles.git
cd dotfiles
./install.sh
```

Then restart your terminal (or run `source ~/.zshrc`).

After the first tmux session starts, press `Ctrl-a` then `I` to download the
tmux plugins.

## What it does

`install.sh` runs four smaller scripts in order. Each one can also be run on its
own if you only want that piece:

| Script | What it sets up |
| --- | --- |
| `zsh/install.sh` | Installs zsh and Oh My Zsh, then copies `.zshrc` to your home folder |
| `nvim/install.sh` | Downloads the latest Neovim into `/opt/nvim`, copies the config to `~/.config/nvim`, and installs the plugins |
| `tmux/install.sh` | Installs tmux, copies `.tmux.conf`, and adds the tmux plugin manager |
| `claude/install.sh` | Copies Claude Code settings and skills into `~/.claude` |

Example, if you only want tmux:

```bash
./tmux/install.sh
```

## Your existing files

The scripts copy files into place instead of linking them. Before overwriting
anything, an existing `~/.zshrc`, `~/.tmux.conf`, or `~/.config/nvim` is renamed
with a `.bak` ending, so nothing is lost.

Two exceptions to be aware of:

- `~/.claude/skills` is replaced outright, not backed up.
- `~/.claude/settings.json` is overwritten.

Because files are copied, editing a config in your home folder does not change
this repo. Edit the file here, commit it, and run the matching script again to
apply it.

## Updating

```bash
git pull
./install.sh
```
