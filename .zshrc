# .zshrc
#   zshenv
#   -> zprofile (if login shell)
#   -> zshrc (if interactive shell)


#-----------------------------
# pyenv
#-----------------------------

# https://github.com/pyenv/pyenv/issues/1740#issuecomment-738749988
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv init --path)"
export LDFLAGS="-L/usr/local/opt/zlib/lib -L/usr/local/opt/bzip2/lib"
export CPPFLAGS="-I/usr/local/opt/zlib/include -I/usr/local/opt/bzip2/include"

export PATH="$HOME/.pyenv/bin:$PATH"
export PATH="/usr/local/bin:$PATH"


#-----------------------------
# alias
#-----------------------------

if [ -f ~/.aliases ]; then
    source ~/.aliases
fi

if [ -f ~/.aliases_local ]; then
    source ~/.aliases_local
fi


#-----------------------------
# completion
#-----------------------------

# _cache_hosts=(`ruby -ne 'if /^Host\s+(.+)$/; print $1.strip, "\n"; end' ~/.ssh/config`) # ssh,scp用ホスト追加
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  # auto_suggestion
  source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
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

# peco
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
zstyle ':completion:*:default' menu select=2
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
# cdr
if [[ -n $(echo ${^fpath}/chpwd_recent_dirs(N)) && -n $(echo ${^fpath}/cdr(N)) ]]; then
    autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
    add-zsh-hook chpwd chpwd_recent_dirs
    zstyle ':completion:*' recent-dirs-insert both
    zstyle ':chpwd:*' recent-dirs-default true
    zstyle ':chpwd:*' recent-dirs-max 1000
    zstyle ':chpwd:*' recent-dirs-file "$HOME/.cache/chpwd-recent-dirs"
    zstyle ':chpwd:*' recent-dirs-pushd true
    zstyle ':completion:*:*:cdr:*:*' menu selection
fi
function peco-cdr () {
  local selected_dir="$(cdr -l | sed 's/^[0-9]\+ \+//' | peco --prompt="cdr >" --query "$LBUFFER")"
  if [ -n "$selected_dir" ]; then
    BUFFER="cd `echo $selected_dir | awk '{print$2}'`"
    CURSOR=$#BUFFER
    zle reset-prompt
  fi
}
zle -N peco-cdr
bindkey '^G' peco-cdr


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
export PATH="/usr/local/cuda/bin:$PATH"
export LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"


#-----------------------------
# Other
#-----------------------------

# remove duplicate entries
typeset -U PATH
typeset -U precmd_functions # same as : set -A new_array `echo ${old_array[*]} | tr ' ' '\012' | sort -u`


echo '.zshrc sourced!'
