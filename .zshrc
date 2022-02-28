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

autoload -U compinit
compinit
_cache_hosts=(`ruby -ne 'if /^Host\s+(.+)$/; print $1.strip, "\n"; end' ~/.ssh/config`) # ssh,scp用ホスト追加
autoload -Uz compinit
compinit -u
if [ -e /usr/local/share/zsh-completions ]; then
  fpath=(/usr/local/share/zsh-completions $fpath)
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


#-----------------------------
# prompt
#-----------------------------

autoload -Uz colors
colors
PROMPT="${fg[cyan]}["$USER"] %1~${reset_color} %# " # PROMPT="%n@%m %1~ %# " # original

#-----------------------------
# tmux
#-----------------------------

tmux source ~/.tmux.conf


echo '.zshrc sourced!'