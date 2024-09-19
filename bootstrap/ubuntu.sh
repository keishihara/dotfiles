#!/bin/bash

function __exists() { type "$1" >/dev/null 2>&1; return $?; }

# In Ubuntu, some essential commands are installed in this script.
# However, there are stil missing tools and commands,
# which need to be installed manually for now.

if ! __exists fd; then
    echo Installing fd...
    sudo apt install fd-find
else
    echo fd-find is already installed.
fi

if ! __exists fzf; then
    echo Installing fzf...
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.config/fzf
    ~/.config/fzf/install
else
    echo fzf is already installed.
fi

if [ ! -f ~/.config/fzf-git/fzf-git.sh ]; then
    echo Installing fzf-git...
    git clone https://github.com/junegunn/fzf-git.sh.git ~/.config/fzf-git
else
    echo fzf-git is already isntalled.
fi

if ! __exists zoxide; then
    echo Installing zoxide...
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
else
    echo zoxide is already installed.
fi

if ! fc-list | grep -q "MesloLGS"; then
    echo Installing Meslo Nerd Fonts...
    mkdir -p ~/.local/share/fonts
    cd ~/.local/share/fonts
    curl -OL https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Meslo.zip
    unzip Meslo.zip -d Meslo
    fc-cache -v ./Meslo
else
    echo Nerd Fonts are already installed.
fi

if ! __exists lazygit; then
    echo Installing lazygit...
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
    rm lazygit lazygit.tar.gz
else
    echo lazygit is already installed.
fi
