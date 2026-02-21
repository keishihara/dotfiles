#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Symlink targets: "repo_path:link_path"
FILES=(
    ".bashrc:$HOME/.bashrc"
    ".gitconfig:$HOME/.gitconfig"
    ".tmux.conf:$HOME/.tmux.conf"
)

# XDG config directories: "repo_dir:link_path"
CONFIG_DIRS=(
    ".config/wezterm:$HOME/.config/wezterm"
)

link_item() {
    local src="$1" dst="$2"

    if [ ! -e "$src" ]; then
        echo "SKIP: $src does not exist"
        return
    fi

    if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
        echo "OK:   $dst -> $src"
        return
    fi

    if [ -e "$dst" ] || [ -L "$dst" ]; then
        backup="${dst}.backup.$(date +%Y%m%d%H%M%S)"
        mv "$dst" "$backup"
        echo "BACK: $dst -> $backup"
    fi

    ln -s "$src" "$dst"
    echo "LINK: $dst -> $src"
}

for entry in "${FILES[@]}"; do
    link_item "$DOTFILES_DIR/${entry%%:*}" "${entry##*:}"
done

for entry in "${CONFIG_DIRS[@]}"; do
    dst="${entry##*:}"
    mkdir -p "$(dirname "$dst")"
    link_item "$DOTFILES_DIR/${entry%%:*}" "$dst"
done

# Hint for local overrides
if [ ! -f "$HOME/.bashrc.local" ]; then
    echo ""
    echo "HINT: ~/.bashrc.local not found. Create one for machine-specific settings."
    echo "  See README.md for details."
fi
