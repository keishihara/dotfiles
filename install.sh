#!/usr/bin/env bash

function detect_shell() { echo ${SHELL##*/}; }
function _unlink() { unlink "$1" >/dev/null 2>&1; return $?; }
function _mkdir() { mkdir "$1" >/dev/null 2>&1; return $?; }
function _mv() { mv "$1" >/dev/null 2>&1; return $?; }


_unlink ~/.bashrc
_unlink ~/.zshrc
_unlink ~/.gitconfig
_unlink ~/.tmux.conf
_unlink ~/.aliases
_unlink ~/.utils

_mkdir backup
_mv ~/.bashrc backup
_mv ~/.zshrc backup
_mv ~/.gitconfig backup
_mv ~/.tmux.conf backup
_mv ~/.aliases backup
_mv ~/.utils backup

ln -s ~/dotfiles/.aliases ~
ln -s ~/dotfiles/.utils ~
ln -s ~/dotfiles/.gitconfig ~
ln -s ~/dotfiles/.tmux.conf ~

if [ "$(detect_shell)" = zsh ]; then
    ln -s ~/dotfiles/.zshrc ~
    source ~/.zshrc
elif [ "$(detect_shell)" = bash ]; then
    ln -s ~/dotfiles/.bashrc ~
    source ~/.bashrc
else
    echo_header "zsh and bash are only supported: $(detect_shell)"
fi
