#!/bin/bash

DOTFILES=$HOME/dotfiles

if [ "$(uname)" = "Darwin" ]; then
    echo "macOS is detected."
    /bin/bash $DOTFILES/bootstrap/mac.sh

elif [ "$(uname)" = "Linux" ]; then
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [ "$ID" = "ubuntu" ]; then
            echo "Ubuntu is detected."
            /bin/bash $DOTFILES/bootstrap/ubuntu.sh
        else
            echo "Unsupported Linux distribution: $ID"
        fi
    else
        echo "Unable to detect Linux distribution."
    fi

else
    echo "Unsupported OS: $(uname)"
fi
