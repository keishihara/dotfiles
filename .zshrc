# .zshrc
#   zshenv
#   -> zprofile (if login shell)
#   -> zshrc (if interactive shell)


#-----------------------------
# utils
#-----------------------------

function detect_shell() { echo ${SHELL##*/}; }
function echo_header() { printf "\033[37;1m%s\033[m\n" "$*"; }
function echo_warning() { echo -e "\e[33;1mWARNING: $*\e[m"; }
function echo_error() { echo -e "\e[31;1mERROR: $*\e[m"; }
function is_exists() { type "$1" >/dev/null 2>&1; return $?; }

# source: https://stackoverflow.com/a/3466183
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac
echo_header Hi $USER from .zshrc on ${machine}@$(hostname)


#-----------------------------
# pyenv
#-----------------------------

if type pyenv &>/dev/null; then
    # https://github.com/pyenv/pyenv/issues/1740#issuecomment-738749988
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    export PATH="/usr/local/bin:$PATH" # need this?

    # Slice an array: https://stackoverflow.com/a/1336245
    pyenv_version=$(pyenv -v)
    pyenv_version=${pyenv_version[@]:6:7}
    pyenv_version=${pyenv_version//./ }
    pyenv_major_version=${pyenv_version[1]}
    pyenv_minor_version=${pyenv_version[3]}
    if [ $pyenv_major_version -eq 1 ]; then
        # if pyenv == 1.x
        eval "$(pyenv init -)"
    else
        eval "$(pyenv init --path)"
    fi
    export LDFLAGS="-L/usr/local/opt/zlib/lib -L/usr/local/opt/bzip2/lib"
    export CPPFLAGS="-I/usr/local/opt/zlib/include -I/usr/local/opt/bzip2/include"
else
    echo_warning "pyenv not found."
fi


#-----------------------------
# alias
#-----------------------------

if [ -f ~/.aliases ]; then
    source ~/.aliases
else
    echo_warning "~/.aliases not found"
fi

if [ -f ~/.aliases_local ]; then
    source ~/.aliases_local
fi


#-----------------------------
# zsh configurations
#-----------------------------

# NOTE: zsh-autosuggestions and zsh-completion look similar, but both installed

# _cache_hosts=(`ruby -ne 'if /^Host\s+(.+)$/; print $1.strip, "\n"; end' ~/.ssh/config`) # ssh,scp用ホスト追加
if type brew &>/dev/null; then # for mac
    # auto completion
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
    # auto_suggestion
    source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    autoload -Uz compinit
    compinit

elif [ ${machine} = Linux ]; then # for ubuntu
    # if not installed, run: git clone https://github.com/zsh-users/zsh-completions.git "${ZDOTDIR:-$HOME}/.zsh-completions"
    autoload predict-on
    predict-on

    # auto completion
    if [ -d ~/.zsh-completions ]; then
        FPATH=${ZDOTDIR:-$HOME}/.zsh-completions/src:$FPATH
    else
        echo_warning "zsh-completions not installed. You might want to run: \n $ git clone https://github.com/zsh-users/zsh-completions.git "${ZDOTDIR:-$HOME}/.zsh-completions""
    fi

    # syntax-highlighting
    if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
        source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    else
        echo_warning "zsh-syntax-highlighting not installed."
    fi

    # history search: https://github.com/zsh-users/zsh-history-substring-search#usage
    if [ -d ~/.zsh-history-substring-search ]; then
        source ${ZDOTDIR:-$HOME}/.zsh-history-substring-search/zsh-history-substring-search.zsh
        bindkey '^[[A' history-substring-search-up
        bindkey '^[[B' history-substring-search-down
    else
        echo_warning "zsh-history-substring-search is not installed. See https://github.com/zsh-users/zsh-history-substring-search"
        # git clone https://github.com/zsh-users/zsh-history-substring-search.git "${ZDOTDIR:-$HOME}/.zsh-history-substring-search"
    fi

    # auto_suggestion
    if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
        source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    else
        echo_warning "zsh-autosuggestions not installed. You might want to run: \n $ sudo apt install -y zsh-autosuggestions"
    fi

    autoload -Uz compinit
    compinit
fi

# 補完で小文字でも大文字にマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# 補完候補一覧をカラー表示
zstyle ':completion:*' list-colors ''
setopt list_packed           # 補完候補を詰めて表示
setopt auto_param_slash      # ディレクトリ名の補完で末尾の / を自動的に付加し、次の補完に備える
setopt list_types            # 補完候補一覧でファイルの種別を識別マーク表示 (訳注:ls -F の記号)
setopt auto_menu             # 補完キー連打で順に補完候補を自動で補完
setopt auto_param_keys       # カッコの対応などを自動的に補完
setopt magic_equal_subst     # コマンドラインの引数で --prefix=/usr などの = 以降でも補完できる
setopt complete_in_word      # 語の途中でもカーソル位置で補完
setopt extended_glob         # 拡張グロブで補完(~とか^とか。例えばless *.txt~memo.txt ならmemo.txt 以外の *.txt にマッチ)
setopt share_history
setopt pushd_ignore_dups # remove dups in pushd

bindkey 'tab' expand-or-complete-prefix
zstyle ':autocomplete:*' widget-style menu-select

# enable cdr
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs
# cdrコマンドで履歴にないディレクトリにも移動可能に
zstyle ":chpwd:*" recent-dirs-default true
zstyle ':chpwd:*' recent-dirs-max 500
zstyle ':chpwd:*' recent-dirs-default true

# change directory without cd command
setopt auto_cd
# cd - to show previsouly visited directories
setopt auto_pushd
# completion at the cursor
setopt complete_in_word
# save 1000 previous command histories
export HISTSIZE=1000
# do not add the same command as one executed right before
setopt hist_ignore_dups

export HISTFILE=${HOME}/.history
HISTSIZE=500000
SAVEHIST=500000
setopt appendhistory
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# zstyle ':completion:*:default' menu select=2
# zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
# cdr自体の設定
if [[ -n $(echo ${^fpath}/chpwd_recent_dirs(N)) && -n $(echo ${^fpath}/cdr(N)) ]]; then
    autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
    add-zsh-hook chpwd chpwd_recent_dirs
    zstyle ':completion:*' recent-dirs-insert fallback
    zstyle ':chpwd:*' recent-dirs-default true
    zstyle ':chpwd:*' recent-dirs-max 1000
    zstyle ':chpwd:*' recent-dirs-file "$HOME/.cache/chpwd-recent-dirs"
    zstyle ':chpwd:*' recent-dirs-pushd true
    zstyle ':completion:*:*:cdr:*:*' menu selection
fi
# peco
if type peco &>/dev/null; then

    function peco-history-selection() {
        if which tac >/dev/null; then
            tac="tac"
        else
        tac="tail -r"
        fi
        BUFFER=`history -n 1 | tac | awk '!a[$0]++' | peco`
        CURSOR=$#BUFFER
        zle reset-prompt
    }
    zle -N peco-history-selection
    bindkey '^r' peco-history-selection

    # ctrl + f で過去に移動したことのあるディレクトリを選択できるようにする。
    function peco-cdr () {
    local selected_dir="$(cdr -l | sed 's/^[0-9]\+ \+//' | peco --prompt="cdr >" --query "$LBUFFER")"
    if [ -n "$selected_dir" ]; then
        BUFFER="cd `echo $selected_dir | awk '{print$2}'`"
        CURSOR=$#BUFFER
        zle reset-prompt
    fi
    }
    zle -N peco-cdr
    bindkey '^f' peco-cdr

else
    echo_warning "peco is not installed."
fi


#-----------------------------
# prompt
#-----------------------------

autoload -Uz colors
colors
# PROMPT="%{${fg[cyan]}%}["$USER"@${HOST}] %~%{${reset_color}%} %# " # older
_precmd() {
  _GIT_BRANCH="$(git branch --show-current 2>/dev/null)"
  [ -n "$_GIT_BRANCH" ] && _GIT_BRANCH=" $_GIT_BRANCH"
}
precmd_functions+=( _precmd )
setopt prompt_subst # substitutes environmental variables in prompt with values
export PROMPT='%F{cyan}%n%f@%F{magenta}%M%f %F{027}%40<..<%~%f%F{#FF8000}${_GIT_BRANCH}%f %F{green}%(!.#.❯)%f '
# NOTE: some of PROMPT syntax:
# - %F{color}SOMETHING%f will change the color of string SOMETHING.
# - %N<..<SOMETHING will truncate SOMETHING if it is longer than N. (sorce: https://unix.stackexchange.com/a/369862)


#-----------------------------
# tmux
#-----------------------------

tmux source ~/.tmux.conf


#-----------------------------
# misc
#-----------------------------

# do not create __pychache__
export PYTHONDONTWRITEBYTECODE=1


#-----------------------------
# CUDA
#-----------------------------

if [ -L /usr/local/cuda ] || [ -d /usr/local/cuda ]; then
    export PATH="/usr/local/cuda/bin:$PATH"
    export LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"
fi


#-----------------------------
# Other
#-----------------------------

# remove duplicate entries
typeset -U PATH
typeset -U precmd_functions # same as : set -A new_array `echo ${old_array[*]} | tr ' ' '\012' | sort -u`


echo '.zshrc sourced!'
