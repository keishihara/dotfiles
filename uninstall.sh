#!/usr/bin/env bash

unlink ~/.bashrc
unlink ~/.zshrc
unlink ~/.gitconfig
unlink ~/.tmux.conf
unlink ~/.aliases

# Re-login to interactive shell
exec $SHELL -l
