#!/bin/bash
#
# Shared helpers for the install scripts.
#
# The rule they all follow: only touch what actually needs touching. If the
# installed file already matches this repo, say so and do nothing. Only make a
# backup when the existing file genuinely differs, and never overwrite a
# backup that is already there.
#
# Written for bash 3.2 (the version macOS ships).

# --- Temp directories ------------------------------------------------------
#
# One EXIT trap for the whole script. Setting `trap ... EXIT` in two different
# places would silently cancel the first one, so scripts register their temp
# directories here instead of installing their own trap.

DOTFILES_TEMPDIRS=()

_dotfiles_cleanup() {
  local d
  for d in "${DOTFILES_TEMPDIRS[@]}"; do
    [ -n "$d" ] && rm -rf "$d"
  done
}
trap _dotfiles_cleanup EXIT

# Create a temp directory that is removed when the script exits.
make_tempdir() {
  local d
  d=$(mktemp -d)
  DOTFILES_TEMPDIRS+=("$d")
  echo "$d"
}

# --- Reporting -------------------------------------------------------------

say() { echo "  $*"; }
say_ok() { echo "  ✓ $*"; }
say_change() { echo "  → $*"; }

# --- Comparison ------------------------------------------------------------

# Do two files have the same content?
files_match() {
  [ -f "$1" ] && [ -f "$2" ] && cmp -s "$1" "$2"
}

# Do two directories have the same content?
dirs_match() {
  [ -d "$1" ] && [ -d "$2" ] && diff -rq "$1" "$2" >/dev/null 2>&1
}

# --- Backups ---------------------------------------------------------------

# Pick a backup path for $1 that does not clobber an existing backup.
# Prefers plain ".bak"; falls back to a timestamped name if that is taken by
# something different.
backup_path_for() {
  local target="$1"
  local plain="${target}.bak"

  if [ ! -e "$plain" ]; then
    echo "$plain"
    return
  fi

  # A backup already exists. If it holds exactly what we are about to save,
  # there is no point writing a second copy of the same thing.
  if [ -f "$target" ] && files_match "$target" "$plain"; then
    echo ""
    return
  fi
  if [ -d "$target" ] && dirs_match "$target" "$plain"; then
    echo ""
    return
  fi

  echo "${target}.bak.$(date +%Y%m%d%H%M%S)"
}

# Back up $1, but only if it is worth doing. Reports what happened.
backup_existing() {
  local target="$1"
  local dest

  dest=$(backup_path_for "$target")

  if [ -z "$dest" ]; then
    say "Existing backup already holds this version, keeping it."
    return 0
  fi

  cp -R "$target" "$dest"
  say_change "Backed up $(basename "$target") -> $(basename "$dest")"
}

# --- Installing ------------------------------------------------------------

# install_file SRC DEST LABEL
# Copies SRC to DEST, backing DEST up first if it differs.
install_file() {
  local src="$1" dest="$2" label="$3"

  if [ -L "$dest" ]; then
    say_change "Removing old symlink at $dest"
    rm "$dest"
  fi

  if [ ! -e "$dest" ]; then
    cp "$src" "$dest"
    say_change "Installed $label"
    return 0
  fi

  if files_match "$src" "$dest"; then
    say_ok "$label is already up to date, nothing to do."
    return 0
  fi

  say "$label differs from this repo's version."
  backup_existing "$dest"
  cp "$src" "$dest"
  say_change "Updated $label"
}

# install_tree SRC DEST LABEL
# Makes DEST match SRC exactly, backing DEST up first if it differs.
install_tree() {
  local src="$1" dest="$2" label="$3"

  if [ -L "$dest" ]; then
    say_change "Removing old symlink at $dest"
    rm "$dest"
  fi

  if [ ! -e "$dest" ]; then
    mkdir -p "$dest"
    cp -R "$src"/. "$dest"/
    say_change "Installed $label"
    return 0
  fi

  if dirs_match "$src" "$dest"; then
    say_ok "$label is already up to date, nothing to do."
    return 0
  fi

  say "$label differs from this repo's version."
  backup_existing "$dest"
  rm -rf "$dest"
  mkdir -p "$dest"
  cp -R "$src"/. "$dest"/
  say_change "Updated $label"
}

# merge_tree SRC DEST LABEL
# Adds SRC's contents to DEST, keeping anything already there that SRC does
# not define. Only backs up when the merge would actually change something.
merge_tree() {
  local src="$1" dest="$2" label="$3"
  local staged

  if [ ! -e "$dest" ]; then
    mkdir -p "$dest"
    cp -R "$src"/. "$dest"/
    say_change "Installed $label"
    return 0
  fi

  # Work out what the merge result would look like before committing to it.
  staged=$(make_tempdir)
  cp -R "$dest"/. "$staged"/
  cp -R "$src"/. "$staged"/

  if dirs_match "$staged" "$dest"; then
    say_ok "$label already contains this repo's version, nothing to do."
    rm -rf "$staged"
    return 0
  fi

  say "$label would change."
  backup_existing "$dest"
  cp -R "$src"/. "$dest"/
  say_change "Merged $label, your own files were kept."
  rm -rf "$staged"
}
