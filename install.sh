#!/usr/bin/env bash

source ./scripts/utils.sh

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
