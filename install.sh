#!/usr/bin/env bash

function detect_shell() { echo ${SHELL##*/}; }
function echo_header() { printf "\033[37;1m%s\033[m\n" "$*"; }
function is_exists() { type "$1" >/dev/null 2>&1; return $?; }
function _unlink() { unlink "$1" >/dev/null 2>&1; return $?; }
function _mv() { mv "$1" >/dev/null 2>&1; return $?; }
function _mkdir() { mkdir "$1" >/dev/null 2>&1; return $?; }

_unlink ~/.bashrc
_unlink ~/.zshrc
_unlink ~/.gitconfig
_unlink ~/.tmux.conf
_unlink ~/.aliases

_mkdir dotbackup
_mv ~/.bashrc dotbackup
_mv ~/.zshrc dotbackup
_mv ~/.gitconfig dotbackup
_mv ~/.tmux.conf dotbackup
_mv ~/.aliases dotbackup

ln -s ~/dotfiles/.aliases ~
ln -s ~/dotfiles/.gitconfig ~
ln -s ~/dotfiles/.tmux.conf ~

if [ "$(detect_shell)" = zsh ]; then
    ln -s ~/dotfiles/.zshrc ~
    source ~/.zshrc
elif [ "$(detect_shell)" = bash ]; then
    ln -s ~/dotfiles/.bashrc ~
    source ~/.bashrc
else
    echo_header "zsh and bash only supported: $(detect_shell)"
fi
