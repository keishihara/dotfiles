#!/bin/bash
# Remove symlinks created by install.sh.
# If a .backup.<timestamp> file exists, the most recent one is restored.
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/dotfiles.conf"

unlink_item() {
    local src="$1" dst="$2"

    if [ ! -L "$dst" ]; then
        echo "SKIP: $dst is not a symlink"
        return
    fi

    if [ "$(readlink -f "$dst")" != "$(readlink -f "$src")" ]; then
        echo "SKIP: $dst does not point to $src"
        return
    fi

    rm "$dst"
    echo "RM:   $dst"

    # Restore the most recent backup if one exists
    local latest
    latest="$(ls -t "${dst}.backup."* 2>/dev/null | head -1)" || true
    if [ -n "$latest" ]; then
        mv "$latest" "$dst"
        echo "REST: $dst <- $latest"
    fi
}

for entry in "${FILES[@]}"; do
    unlink_item "$DOTFILES_DIR/${entry%%:*}" "${entry##*:}"
done

for entry in "${CONFIG_DIRS[@]}"; do
    unlink_item "$DOTFILES_DIR/${entry%%:*}" "${entry##*:}"
done
