# ~/.bashrc

# Non-interactive shell: do nothing
case $- in
    *i*) ;;
      *) return;;
esac

# --------------------------------------------------
# History
# --------------------------------------------------
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend
shopt -s checkwinsize

# --------------------------------------------------
# Prompt
# --------------------------------------------------
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [ "$color_prompt" = yes ]; then
    PS1='\[\033[01;36m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[33m\]$(__git_ps1 " (%s)")\[\033[00m\]\$ '
else
    PS1='\u@\h:\w$(__git_ps1 " (%s)")\$ '
fi
unset color_prompt

case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;\u@\h: \w\a\]$PS1"
    ;;
esac

# --------------------------------------------------
# Aliases
# --------------------------------------------------
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
fi

alias ll='ls -alFh --group-directories-first'
alias la='ls -Ah --group-directories-first'
alias l='ls -CF1 --group-directories-first'
alias ..='cd ..'
alias ...='cd ../..'
alias ta='tmux attach'
alias smi='nvidia-smi'
alias reload='source ~/.bashrc'

# --------------------------------------------------
# Completion
# --------------------------------------------------
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# --------------------------------------------------
# PATH
# --------------------------------------------------
export PATH="$HOME/.local/bin:$PATH"
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"  # uv

# --------------------------------------------------
# Functions
# --------------------------------------------------
activate() {
    if [ -d ".venv" ]; then
        source .venv/bin/activate
    elif [ -d ".env" ]; then
        source .env/bin/activate
    else
        echo "No virtual environment found (.venv or .env)"
    fi
}

# Reset terminal mouse tracking mode (fix after abnormal exit of tmux, etc.)
fixmouse() { printf '\e[?9l\e[?1000l\e[?1002l\e[?1003l\e[?1006l\e[?1015l'; stty sane; }
fixmouse

# --------------------------------------------------
# Local overrides
# --------------------------------------------------
[ -f ~/.bashrc.local ] && . ~/.bashrc.local

# Deduplicate PATH entries
export PATH="$(printf '%s' "$PATH" | awk -v RS=: -v ORS=: '!seen[$0]++' | sed 's/:$//')"
