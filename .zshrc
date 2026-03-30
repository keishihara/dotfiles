# ~/.zshrc

# --------------------------------------------------
# Plugin manager (zinit)
# --------------------------------------------------
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# --------------------------------------------------
# Completion
# --------------------------------------------------
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
    compinit -C
else
    compinit -C
fi

compdef -d git  # Use fzf instead

zinit light Aloxaf/fzf-tab  # Must be loaded after compinit
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions

# Fish-like history search: pressing Up/Down searches through history
zinit light zsh-users/zsh-history-substring-search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND=''
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND=''
HISTORY_SUBSTRING_SEARCH_FUZZY='true'

# Fish-like autosuggestions (grayed out)
zinit light zsh-users/zsh-autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# Oh-My-Zsh snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::brew

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:*' switch-group '<' '>'

# --------------------------------------------------
# History
# --------------------------------------------------
HISTSIZE=100000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# --------------------------------------------------
# Prompt
# --------------------------------------------------
autoload -Uz vcs_info
setopt prompt_subst

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats ' (%b)'
zstyle ':vcs_info:git:*' actionformats ' (%b|%a)'

precmd() { vcs_info }

PROMPT=''
PROMPT+='%F{135}[%n]%f '
PROMPT+='%F{blue} %~%f'
PROMPT+='%F{cyan}${vcs_info_msg_0_}%f '
PROMPT+=$'\n'
PROMPT+='%(?.%F{green}❯ .%F{red}❯ )%f'

# --------------------------------------------------
# Keybindings
# --------------------------------------------------
bindkey -e
bindkey -s '^[r' 'source ~/.zshrc^M'

# --------------------------------------------------
# Aliases
# --------------------------------------------------
if command -v gls &>/dev/null; then
    alias ls='gls --color=auto'
    alias ll='ls -Flh --group-directories-first --color=auto'
    alias la='ls -Flha --group-directories-first --color=auto'
    alias l='ls -CF1 --group-directories-first --color=auto'
else
    alias ls='ls --color=auto'
    alias ll='ls -Flh --color=auto'
    alias la='ls -Flha --color=auto'
    alias l='ls -CF1 --color=auto'
fi
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias ta='tmux attach'
alias reload='source ~/.zshrc'

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

# Reset terminal mouse tracking mode
fixmouse() {
    printf '\e[?9l\e[?1000l\e[?1002l\e[?1003l\e[?1006l\e[?1015l'
    stty sane
}
fixmouse

# Interactive git log viewer (fzf)
gli() {
    local filter
    if [ -n $@ ] && [ -f $@ ]; then
        filter="-- $@"
    fi
    git log \
        --graph --color=always --abbrev=7 --format='%C(auto)%h %an %C(blue)%s %C(yellow)%cr' $@ | \
        fzf \
            --ansi --no-sort --reverse --tiebreak=index \
            --preview "f() { set -- \$(echo -- \$@ | grep -o '[a-f0-9]\{7\}'); [ \$# -eq 0 ] || git show --color=always \$1 $filter; }; f {}" \
            --bind "ctrl-j:down,ctrl-k:up,alt-j:preview-down,alt-k:preview-up,ctrl-f:preview-page-down,ctrl-b:preview-page-up,q:abort,ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
                FZF-EOF" \
            --preview-window=right:60% \
            --height 80%
}

# MOV -> MP4 helper
# Usage: mov_to_mp4 input.mov [output.mp4]
# Options: -c <int> CRF (default: 20), -y overwrite
mov_to_mp4() {
    local crf=20 overwrite=0
    local OPTIND opt
    while getopts ":c:y" opt; do
        case "$opt" in
            c) crf="$OPTARG" ;;
            y) overwrite=1 ;;
        esac
    done
    shift $((OPTIND-1))

    local in="$1"
    local out="${2:-${in%.*}.mp4}"
    [[ -f "$in" ]] || { echo "Input not found: $in" >&2; return 1; }

    local vcodec acodec
    vcodec="$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name \
             -of default=nw=1:nk=1 "$in")" || return 1
    acodec="$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name \
             -of default=nw=1:nk=1 "$in" 2>/dev/null || echo none)"

    local owflag="-n"; [[ $overwrite -eq 1 ]] && owflag="-y"

    if [[ "$vcodec" == "h264" && "$acodec" == "aac" ]]; then
        ffmpeg $owflag -i "$in" -c copy -movflags +faststart "$out"
    else
        ffmpeg $owflag -i "$in" \
            -c:v libx264 -crf "$crf" -preset veryfast -pix_fmt yuv420p \
            -c:a aac -b:a 192k \
            -movflags +faststart \
            "$out"
    fi
}

mov_to_mp4_all() {
    local f
    for f in *.mov *.MOV; do
        [[ -e "$f" ]] || continue
        mov_to_mp4 "$f" "${f%.*}.mp4"
    done
}

# fzf + fd integration
_fzf_compgen_path() { fd --hidden --exclude .git . "$1"; }
_fzf_compgen_dir() { fd --type=d --hidden --exclude .git . "$1"; }

# --------------------------------------------------
# Tool activation
# --------------------------------------------------
# Homebrew
if [ -x "$(command -v brew)" ]; then
    eval "$(brew shellenv)"
fi

[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"                      # uv
[ -x "$HOME/.local/bin/mise" ] && eval "$("$HOME/.local/bin/mise" activate zsh)" # mise
command -v fzf &>/dev/null && source <(fzf --zsh)
command -v zoxide &>/dev/null && eval "$(zoxide init zsh --hook prompt)"

alias cd="z"

# --------------------------------------------------
# Local overrides
# --------------------------------------------------
[ -f ~/.zshrc.local ] && . ~/.zshrc.local
