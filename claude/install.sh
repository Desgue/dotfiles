#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../lib/common.sh
. "$SCRIPT_DIR/../lib/common.sh"

CLAUDE_DIR="$HOME/.claude"

# Default action when there is nothing to ask (non-interactive shell) or when
# forced with a flag. "merge" is the safe default: it never removes anything
# that is already there.
MODE=""

usage() {
  cat <<EOF
Usage: ./claude/install.sh [options]

Installs the Claude Code configuration into ~/.claude.

By default it asks what to do with any config that already exists.

Options:
  -m, --merge      Add/overwrite the files from this repo, keep everything else
  -r, --replace    Replace the existing config with this repo's (backed up first)
  -s, --skip       Leave existing config untouched, only install what is missing
  -h, --help       Show this help
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    -m | --merge) MODE="merge" ;;
    -r | --replace) MODE="replace" ;;
    -s | --skip) MODE="skip" ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
  shift
done

# Ask what to do about an existing config. Echoes merge|replace|skip.
# Falls back to the safe option when no one can answer.
ask_mode() {
  local what="$1" answer

  if [ -n "$MODE" ]; then
    echo "$MODE"
    return
  fi

  if [ ! -t 0 ]; then
    echo "merge"
    return
  fi

  while true; do
    # Prompts go to stderr so they are not captured by the caller's $(...).
    {
      echo ""
      echo "$what already exists at ~/.claude."
      echo "  m) Merge  - add this repo's files, keep anything else already there"
      echo "  r) Replace - use this repo's version (a backup is made first)"
      echo "  s) Skip   - leave it exactly as it is"
      printf 'Choose [m]: '
    } >&2

    if ! read -r answer; then
      echo "merge"
      return
    fi

    [ -z "$answer" ] && answer="m"
    case $(echo "$answer" | tr '[:upper:]' '[:lower:]') in
      m | merge)
        echo "merge"
        return
        ;;
      r | replace)
        echo "replace"
        return
        ;;
      s | skip)
        echo "skip"
        return
        ;;
      *) echo "  Please answer m, r or s." >&2 ;;
    esac
  done
}

echo "Installing Claude Code configuration..."

mkdir -p "$CLAUDE_DIR"

# --- Skills ----------------------------------------------------------------

SKILLS_SRC="$SCRIPT_DIR/skills"
SKILLS_DEST="$CLAUDE_DIR/skills"

if [ -d "$SKILLS_SRC" ]; then
  if [ ! -d "$SKILLS_DEST" ]; then
    install_tree "$SKILLS_SRC" "$SKILLS_DEST" "Skills"
  elif dirs_match "$SKILLS_SRC" "$SKILLS_DEST"; then
    say_ok "Skills are already up to date, nothing to do."
  else
    case $(ask_mode "Skills directory") in
      replace) install_tree "$SKILLS_SRC" "$SKILLS_DEST" "Skills" ;;
      merge) merge_tree "$SKILLS_SRC" "$SKILLS_DEST" "Skills" ;;
      skip) say "Left skills untouched." ;;
    esac
  fi
fi

# --- settings.json ---------------------------------------------------------

SETTINGS_SRC="$SCRIPT_DIR/settings.json"
SETTINGS_DEST="$CLAUDE_DIR/settings.json"

if [ -f "$SETTINGS_SRC" ]; then
  if [ ! -f "$SETTINGS_DEST" ]; then
    install_file "$SETTINGS_SRC" "$SETTINGS_DEST" "settings.json"
  elif files_match "$SETTINGS_SRC" "$SETTINGS_DEST"; then
    say_ok "settings.json is already up to date, nothing to do."
  else
    case $(ask_mode "settings.json") in
      replace)
        install_file "$SETTINGS_SRC" "$SETTINGS_DEST" "settings.json"
        ;;
      merge)
        # A plain copy would throw away machine-specific settings (hooks added
        # by other tools, theme, ...), so merge key by key when jq is around.
        if ! command -v jq &>/dev/null; then
          say "jq is not installed, cannot merge settings.json safely."
          say "Left it unchanged. Install jq, or re-run with --replace to overwrite."
        else
          merged="$(make_tempdir)/settings.json"
          # Deep merge, this repo's values win for the keys it defines.
          if ! jq -s '.[0] * .[1]' "$SETTINGS_DEST" "$SETTINGS_SRC" >"$merged"; then
            say "Could not merge settings.json (invalid JSON?), left it unchanged."
          elif files_match "$merged" "$SETTINGS_DEST"; then
            say_ok "settings.json already contains this repo's settings, nothing to do."
          else
            say "settings.json would change."
            backup_existing "$SETTINGS_DEST"
            cp "$merged" "$SETTINGS_DEST"
            say_change "Merged settings.json, your existing keys were kept."
          fi
        fi
        ;;
      skip)
        say "Left settings.json untouched."
        ;;
    esac
  fi
fi

echo "Claude Code configuration installed."
