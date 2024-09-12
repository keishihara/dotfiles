#!/usr/bin/env bash

function _detect_shell() { echo ${SHELL##*/}; }
function _unlink() { unlink "$1" >/dev/null 2>&1; return $?; }
function _mkdir() { mkdir "$1" >/dev/null 2>&1; return $?; }
function _mv() { mv "$1" >/dev/null 2>&1; return $?; }

function _echo_header() { printf "\033[37;1m%s\033[m\n" "$*"; }
function _echo_warning() { echo -e "\e[33;1mWARNING: $*\e[m"; }
function _echo_error() { echo -e "\e[31;1mERROR: $*\e[m"; }
function _exists() { type "$1" >/dev/null 2>&1; return $?; }

DOTFILES=~/dotfiles

_unlink ~/.bashrc
_unlink ~/.zshrc
_unlink ~/.gitconfig
_unlink ~/.tmux.conf
_unlink ~/.zshenv

_mkdir backup
_mv ~/.bashrc backup
_mv ~/.zshrc backup
_mv ~/.gitconfig backup
_mv ~/.tmux.conf backup
_mv ~/.zshenv backup

ln -s $DOTFILES/.gitconfig ~
ln -s $DOTFILES/.tmux.conf ~

if [ "$(_detect_shell)" = zsh ]; then
    ln -s $DOTFILES/.zshenv ~
    ln -s $DOTFILES/.zshrc ~
elif [ "$(_detect_shell)" = bash ]; then
    ln -s $DOTFILES/.bashrc ~
else
    _echo_header "zsh and bash are only supported, but detected: $(_detect_shell)"
fi

_echo_header "It is recommended to restart your terminal emulator."

exec $SHELL -l
