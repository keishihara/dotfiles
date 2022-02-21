# pyenv
# https://github.com/pyenv/pyenv/issues/1740#issuecomment-738749988
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv init --path)"
export LDFLAGS="-L/usr/local/opt/zlib/lib -L/usr/local/opt/bzip2/lib"
export CPPFLAGS="-I/usr/local/opt/zlib/include -I/usr/local/opt/bzip2/include"

# alias
if [ -f ~/.aliases ]; then
    source ~/.aliases
fi

if [ -f ~/.aliases_local ]; then
    source ~/.aliases_local
fi

# prompt
autoload -Uz colors
colors
PROMPT="${fg[cyan]}["$USER"] %1~${reset_color} %# " # PROMPT="%n@%m %1~ %# " # original

# tmux
tmux source ~/.tmux.conf

echo '.zshrc sourced!'
