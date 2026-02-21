#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Symlink targets: "repo_file:link_path"
FILES=(
    ".bashrc:$HOME/.bashrc"
    ".gitconfig:$HOME/.gitconfig"
    ".tmux.conf:$HOME/.tmux.conf"
)

for entry in "${FILES[@]}"; do
    src="$DOTFILES_DIR/${entry%%:*}"
    dst="${entry##*:}"

    if [ ! -f "$src" ]; then
        echo "SKIP: $src does not exist"
        continue
    fi

    # Already correctly linked
    if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
        echo "OK:   $dst -> $src"
        continue
    fi

    # Back up existing file
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        backup="${dst}.backup.$(date +%Y%m%d%H%M%S)"
        mv "$dst" "$backup"
        echo "BACK: $dst -> $backup"
    fi

    ln -s "$src" "$dst"
    echo "LINK: $dst -> $src"
done

# Hint for local overrides
if [ ! -f "$HOME/.bashrc.local" ]; then
    echo ""
    echo "HINT: ~/.bashrc.local not found. Create one from the example:"
    echo "  cp $DOTFILES_DIR/.bashrc.local.example $HOME/.bashrc.local"
fi
