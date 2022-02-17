#!/usr/bin/env bash

function detect_shell() { echo ${SHELL##*/}; }
function echo_header() { printf "\033[37;1m%s\033[m\n" "$*"; }
function is_exists() { type "$1" >/dev/null 2>&1; return $?; }

unlink ~/.bashrc
unlink ~/.zshrc
unlink ~/.gitconfig
unlink ~/.tmux.conf
unlink ~/.aliases

mkdir dotbackup
mv ~/.bashrc dotbackup
mv ~/.zshrc dotbackup
mv ~/.gitconfig dotbackup
mv ~/.tmux.conf dotbackup
mv ~/.aliases dotbackup

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

