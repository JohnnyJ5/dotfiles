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
symlink "$DOTFILES/claude/statusline.sh" "$HOME/.claude/statusline.sh"
symlink "$DOTFILES/claude/agents"        "$HOME/.claude/agents"
symlink "$DOTFILES/claude/hooks"         "$HOME/.claude/hooks"
symlink "$DOTFILES/claude/git-hooks"     "$HOME/.claude/git-hooks"
symlink "$DOTFILES/.bashrc"              "$HOME/.bashrc"

symlink "$DOTFILES/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"

echo "Installing global git hooks..."
symlink "$DOTFILES/claude/git-hooks"     "$HOME/.claude/git-hooks"
git config --global core.hooksPath "$HOME/.claude/git-hooks"
echo "  git config --global core.hooksPath ~/.claude/git-hooks"

echo "Done."
