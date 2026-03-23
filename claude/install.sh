#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing Claude Code configuration..."

# Create ~/.claude if it doesn't exist
mkdir -p "$HOME/.claude"

# Copy skills directory
if [ -d "$SCRIPT_DIR/skills" ]; then
    echo "Copying skills to ~/.claude/skills/"
    # Remove existing skills directory to avoid stale skills
    rm -rf "$HOME/.claude/skills"
    cp -r "$SCRIPT_DIR/skills" "$HOME/.claude/skills"
fi

# Copy settings.json
if [ -f "$SCRIPT_DIR/settings.json" ]; then
    echo "Copying settings.json to ~/.claude/settings.json"
    cp "$SCRIPT_DIR/settings.json" "$HOME/.claude/settings.json"
fi

echo "Claude Code configuration installed."
