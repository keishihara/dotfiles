#!/usr/bin/env bash

unlink ~/.bashrc
unlink ~/.zshenv
unlink ~/.zprofile
unlink ~/.zshrc
unlink ~/.gitconfig
unlink ~/.tmux.conf
unlink ~/.Brewfile
unlink ~/.wezterm.lua
unlink ~/.vimrc

# Re-login to interactive shell
exec $SHELL -l
