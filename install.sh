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
    ln -insv "$dotfile" "$HOME"
done


# Settings that separate installation required

# ================ #
#      VSCode      #
# ================ #

# Hint: run command below to update extension list
# code --list-extensions > extensions.txt

if [ "$(uname)" = Darwin ]; then

    if [ -d ~/Library/Application\ Support/Code/User ]; then
        # Only when VSCode installation is found
        cd ~/Library/Application\ Support/Code/User

        mv settings.json settings.json.bak
        mv keybindings.json keybindings.json.bak
        mv snippets snippets.bak

        ln -insv ${DOTFILES}/app/vscode/settings.json
        ln -insv ${DOTFILES}/app/vscode/keybindings.json
        ln -insv ${DOTFILES}/app/vscode/snippets.json

        for extension in `cat ${DOTFILES}/app/vscode/extensions.txt`; do
            code --install-extension $extension
        done
    else
        echo "Skip installing VSCode settings as VSCode is not installed."
    fi

elif [ "$(uname)" = "Linux" ]; then
    if [ -d ~/.config/Code/User ]; then
        # Only when VSCode installation is found
        cd ~/.config/Code/User

        mv settings.json settings.json.bak
        mv keybindings.json keybindings.json.bak
        mv snippets snippets.bak

        ln -insv ${DOTFILES}/app/vscode/settings.json
        ln -insv ${DOTFILES}/app/vscode/keybindings.json
        ln -insv ${DOTFILES}/app/vscode/snippets.json

        for extension in `cat ${DOTFILES}/app/vscode/extensions.txt`; do
            code --install-extension $extension
        done
    else
        echo "Skip installing VSCode settings as VSCode is not installed."
    fi
fi
