#!/bin/bash

# No `set -e` here on purpose: each module is run independently so that one
# failing installer (a flaky download, a missing package manager) does not
# stop the others from installing. Failures are collected and reported at the
# end, and the script still exits non-zero if anything went wrong.
#
# Written for bash 3.2 (the version macOS ships), so no associative arrays.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Parallel arrays: MODULE_KEYS[i] / MODULE_NAMES[i] / MODULE_PATHS[i]
MODULE_KEYS=(homebrew zsh nvim tmux claude)
MODULE_NAMES=("Homebrew" "Zsh" "Neovim" "Tmux" "Claude Code")
MODULE_PATHS=("homebrew/install.sh" "zsh/install.sh" "nvim/install.sh" "tmux/install.sh" "claude/install.sh")

SELECTED=()
FAILED=()
ASSUME_ALL=false

usage() {
  cat <<EOF
Usage: ./install.sh [options] [module...]

Installs the dotfiles configs. With no arguments it asks which ones to install.

Options:
  -a, --all      Install everything without asking
  -h, --help     Show this help

Modules: ${MODULE_KEYS[*]}

Examples:
  ./install.sh              # interactive menu
  ./install.sh --all        # everything, no prompts
  ./install.sh zsh tmux     # just these two
EOF
}

# Look up a module index by its key. Prints the index, or nothing if unknown.
index_of() {
  local key="$1" i=0
  while [ $i -lt ${#MODULE_KEYS[@]} ]; do
    if [ "${MODULE_KEYS[$i]}" = "$key" ]; then
      echo "$i"
      return 0
    fi
    i=$((i + 1))
  done
  return 1
}

select_all() {
  local i=0
  SELECTED=()
  while [ $i -lt ${#MODULE_KEYS[@]} ]; do
    SELECTED+=("$i")
    i=$((i + 1))
  done
}

prompt_for_modules() {
  local i choice token idx picked

  echo ""
  echo "What would you like to install?"
  echo ""
  i=0
  while [ $i -lt ${#MODULE_NAMES[@]} ]; do
    echo "  $((i + 1))) ${MODULE_NAMES[$i]}"
    i=$((i + 1))
  done
  echo ""
  echo "  a) All of them"
  echo "  q) Quit without installing anything"
  echo ""

  while true; do
    printf 'Select (e.g. "1 3", or a module name) [a]: '
    if ! read -r choice; then
      # EOF (ctrl-D): treat it as "I do not want to pick anything".
      echo ""
      SELECTED=()
      return 0
    fi

    # Default to "all" on a bare Enter.
    [ -z "$choice" ] && choice="a"
    choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

    case "$choice" in
      q | quit | n | none)
        SELECTED=()
        return 0
        ;;
      a | all)
        select_all
        return 0
        ;;
    esac

    picked=()
    for token in $choice; do
      idx=""
      case "$token" in
        # A number from the menu.
        [0-9]*)
          if [ "$token" -ge 1 ] 2>/dev/null && [ "$token" -le ${#MODULE_KEYS[@]} ]; then
            idx=$((token - 1))
          fi
          ;;
        # Or the module name itself.
        *)
          idx=$(index_of "$token") || idx=""
          ;;
      esac

      if [ -z "$idx" ]; then
        echo "  Not a valid option: $token"
        picked=()
        break
      fi
      picked+=("$idx")
    done

    if [ ${#picked[@]} -gt 0 ]; then
      SELECTED=("${picked[@]}")
      return 0
    fi
  done
}

run_module() {
  local idx="$1"
  local name="${MODULE_NAMES[$idx]}"
  local script="$SCRIPT_DIR/${MODULE_PATHS[$idx]}"

  echo ""
  echo "--- Installing $name ---"
  if "$script"; then
    return 0
  fi

  echo "!!! $name installation failed, continuing with the rest."
  FAILED+=("$name")
}

# --- Parse arguments -------------------------------------------------------

CLI_SELECTION=()
while [ $# -gt 0 ]; do
  case "$1" in
    -a | --all)
      ASSUME_ALL=true
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    -*)
      echo "Unknown option: $1"
      usage
      exit 1
      ;;
    *)
      idx=$(index_of "$1") || {
        echo "Unknown module: $1"
        usage
        exit 1
      }
      CLI_SELECTION+=("$idx")
      ;;
  esac
  shift
done

echo "========================================="
echo "  Dotfiles Installer"
echo "========================================="

# --- Decide what to install ------------------------------------------------

if [ ${#CLI_SELECTION[@]} -gt 0 ]; then
  SELECTED=("${CLI_SELECTION[@]}")
elif [ "$ASSUME_ALL" = true ]; then
  select_all
elif [ ! -t 0 ]; then
  # Nobody can answer a prompt here. Refuse rather than guess: silently
  # installing everything is a surprising thing to do to someone's machine.
  echo ""
  echo "Non-interactive shell: cannot show the menu."
  echo "Re-run with --all, or name the modules you want:"
  echo "  ./install.sh --all"
  echo "  ./install.sh ${MODULE_KEYS[*]}"
  exit 1
else
  prompt_for_modules
fi

if [ ${#SELECTED[@]} -eq 0 ]; then
  echo ""
  echo "Nothing selected, exiting."
  exit 0
fi

echo ""
echo "Will install:"
for idx in "${SELECTED[@]}"; do
  echo "  - ${MODULE_NAMES[$idx]}"
done

# --- Run -------------------------------------------------------------------

for idx in "${SELECTED[@]}"; do
  run_module "$idx"
done

echo ""
echo "========================================="
if [ ${#FAILED[@]} -eq 0 ]; then
  echo "  All done!"
  echo "========================================="
  echo "Restart your terminal or run: source ~/.zshrc"
else
  echo "  Finished with errors"
  echo "========================================="
  echo "The following installers failed:"
  for name in "${FAILED[@]}"; do
    echo "  - $name"
  done
  echo ""
  echo "Everything else was installed. Re-run this script to retry."
  exit 1
fi
