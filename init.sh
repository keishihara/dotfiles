# This script installs:
# - pyenv
# - tmux plagin
# - coreutils (macOS only)
#
# This script depends on:
# - curl
# - git
# - tmux


function detect_shell() { echo ${SHELL##*/}; }
function is_exists() { type "$1" >/dev/null 2>&1; return $?; }

platform='unkonw'
case "$OSTYPE" in
  solaris*) echo "SOLARIS" ;;
  darwin*)  echo "macOS"; platform='macOS' ;;
  linux*)   echo "LINUX"; platform='LINUX' ;;
  bsd*)     echo "BSD" ;;
  msys*)    echo "WINDOWS" ;;
  *)        echo "unknown: $OSTYPE" ;;
esac

echo $platform

# pyenv: https://github.com/pyenv/pyenv-installer#install
if is_exists "pyenv"; then
    echo 'pyenv exists.'
else
    echo 'pyenv does not exist.'
    curl https://pyenv.run | bash
    exec $SHELL
fi


# tmux: https://www.seanh.cc/2020/12/27/copy-and-paste-in-tmux/#:~:text=To%20install%20Tmux%20Plugin%20Manager%20and%20tmux%2Dyank%3A
# git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# tmux source ~/.tmux.conf
# ~/.tmux/plugins/tpm/bin/install_plugins

