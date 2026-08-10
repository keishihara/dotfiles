#!/bin/bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/dotfiles.conf"

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
    dst="${entry##*:}"
    mkdir -p "$(dirname "$dst")"
    link_item "$DOTFILES_DIR/${entry%%:*}" "$dst"
done

for entry in "${CONFIG_DIRS[@]}"; do
    dst="${entry##*:}"
    mkdir -p "$(dirname "$dst")"
    link_item "$DOTFILES_DIR/${entry%%:*}" "$dst"
done

python3 "$DOTFILES_DIR/scripts/install-codex-config.py" \
    "$DOTFILES_DIR/codex/config.toml" \
    "$HOME/.codex/config.toml"

# Hint for local overrides
echo ""
case "$(basename "${SHELL:-}")" in
    zsh)  shell_rc="~/.zshrc" ;;
    bash) shell_rc="~/.bashrc" ;;
    *)    shell_rc="" ;;
esac
if [ -n "$shell_rc" ]; then
    echo "HINT: Restart your terminal or run 'source $shell_rc' to apply."
else
    echo "HINT: Restart your terminal (or reload your shell config) to apply."
fi
if [ ! -f "$HOME/.bashrc.local" ]; then
    echo "HINT: ~/.bashrc.local not found. Create one for machine-specific settings."
    echo "  See README.md for details."
fi
