#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
EXT_FILE="$SCRIPT_DIR/extensions.txt"

# Detect CLI: cursor (local) or code (remote)
if command -v cursor &>/dev/null; then
    CLI=cursor
elif command -v code &>/dev/null; then
    CLI=code
else
    echo "ERROR: Neither 'cursor' nor 'code' CLI found in PATH"
    exit 1
fi

echo "Using CLI: $CLI"

while IFS= read -r ext || [ -n "$ext" ]; do
    [ -z "$ext" ] && continue
    [[ "$ext" == \#* ]] && continue
    echo "Installing: $ext"
    "$CLI" --install-extension "$ext" --force 2>/dev/null || echo "  WARN: Failed to install $ext"
done < "$EXT_FILE"

echo "Done."
