# ~/.bashrc

# Non-interactive shell: do nothing
case $- in
    *i*) ;;
      *) return;;
esac

# Prefer a fully specified UTF-8 locale for interactive SSH shells.
# Some remote readline/TUI stacks handle multibyte input more reliably
# with a language locale than with the generic C.UTF-8 default.
if [ -n "${SSH_TTY:-}" ] && locale -a 2>/dev/null | grep -qx 'en_US\.utf8'; then
    case "${LANG:-}" in
        C.UTF-8|C.utf8) export LANG=en_US.utf8 ;;
    esac
    case "${LC_CTYPE:-}" in
        ""|C.UTF-8|C.utf8) export LC_CTYPE=en_US.utf8 ;;
    esac
    case "${LC_ALL:-}" in
        C.UTF-8|C.utf8) export LC_ALL=en_US.utf8 ;;
    esac
fi

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
alias sq='squeue -o "%.6i|%.20j|%.25P|%.20u|%.2t|%.12M|%.12l|%.4D|%.20R"'

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

# --------------------------------------------------
# Tool activation
# --------------------------------------------------
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"  # uv
[ -x "$HOME/.local/bin/mise" ] && eval "$("$HOME/.local/bin/mise" activate bash)"  # mise
command -v fzf &>/dev/null && eval "$(fzf --bash)"
command -v zoxide &>/dev/null && eval "$(zoxide init bash)" && alias cd="z"

# fzf + fd integration
_fzf_compgen_path() { fd --hidden --exclude .git . "$1"; }
_fzf_compgen_dir() { fd --type=d --hidden --exclude .git . "$1"; }

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
# Re-enable iutf8 when supported so multibyte input/editing works correctly.
fixmouse() {
    printf '\e[?9l\e[?1000l\e[?1002l\e[?1003l\e[?1006l\e[?1015l'
    stty sane
    stty -a 2>/dev/null | grep -q 'iutf8' && stty iutf8
}
fixmouse

# --------------------------------------------------
# Local overrides
# --------------------------------------------------
[ -f ~/.bashrc.local ] && . ~/.bashrc.local

# Deduplicate PATH entries
export PATH="$(printf '%s' "$PATH" | awk -v RS=: -v ORS=: '!seen[$0]++' | sed 's/:$//')"
