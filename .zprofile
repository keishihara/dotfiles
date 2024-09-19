function __exists() { type "$1" >/dev/null 2>&1; return $?; }

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if __exists pyenv; then
    eval "$(pyenv init --path)"
fi

# Python
export PYTHONDONTWRITEBYTECODE=1 # do not create __pychache__

# CUDA
if [ -L /usr/local/cuda ] || [ -d /usr/local/cuda ]; then
    export PATH="/usr/local/cuda/bin:$PATH"
    export LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"
else
    if [ ! "$(uname)" = Darwin ]; then
        __echo_error "CUDA installation not found."
    fi
fi

# fzf
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Delete dups in PATH
typeset -U path PATH
