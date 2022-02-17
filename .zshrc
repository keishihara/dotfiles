export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

if [ -f ~/.aliases ]; then
    source ~/.aliases
fi

if [ -f ~/.aliases_local ]; then
    source ~/.aliases_local
fi


autoload -Uz colors
colors
PROMPT="${fg[cyan]}["$USER"] %1~${reset_color} %# " # PROMPT="%n@%m %1~ %# " # original


echo '.zshrc sourced!'
