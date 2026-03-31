#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

symlink() {
  local src="$1" dst="$2"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "Backing up existing $dst -> ${dst}.bak"
    mv "$dst" "${dst}.bak"
  fi
  ln -sfn "$src" "$dst"
  echo "  $dst -> $src"
}

echo "Installing Claude user settings..."
symlink "$DOTFILES/claude/settings.json" "$HOME/.claude/settings.json"
symlink "$DOTFILES/claude/agents"        "$HOME/.claude/agents"
symlink "$DOTFILES/.bashrc" "$HOME/.bashrc"

# Uncomment if you add a user-level CLAUDE.md
# symlink "$DOTFILES/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"

echo "Done."
