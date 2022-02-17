export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

if [ -f ~/.aliases ]; then
    source ~/.aliases
    echo 'aliases deploied'
fi

if [ -f ~/.aliases_local ]; then
    source ~/.aliases_local
fi

