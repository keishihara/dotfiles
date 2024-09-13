#!/usr/bin/env bash

function _unlink() { unlink "$1" >/dev/null 2>&1; return $?; }
function _mkdir() { mkdir "$1" >/dev/null 2>&1; return $?; }
function _mv() { mv "$1" >/dev/null 2>&1; return $?; }

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

_mkdir backup

for dotfile in "${DOTFILES}"/.??* ; do
    [[ "$dotfile" == "${DOTFILES}/.git" ]] && continue
    [[ "$dotfile" == "${DOTFILES}/.gitignore" ]] && continue
    [[ "$dotfile" == "${DOTFILES}/.github" ]] && continue
    [[ "$dotfile" == "${DOTFILES}/.DS_Store" ]] && continue

    filename=$(basename "$dotfile")
    _unlink "$HOME"/"$filename"
    _mv "$HOME"/"$filename" backup
    ln -fnsv "$dotfile" "$HOME"
done

# exec $SHELL -l
