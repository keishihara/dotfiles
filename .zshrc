# Order of zsh-related config files loaded in **login shell**
# 1. /etc/zshenv
# 2. {$ZDOTDIR:-$HOME}/.zshenv <- where ZDOTDIR could be defined
# 3. /etc/zprofile
# 4. {$ZDOTDIR:-$HOME}/.zprofile
# 5. /etc/zshrc
# 6. {$ZDOTDIR:-$HOME}/.zshrc
# 7. /etc/zlogin
# 8. {$ZDOTDIR:-$HOME}/.zlogin


function __echo_header() { printf "\033[37;1m%s\033[m\n" "$*"; }
function __echo_warning() { echo -e "\e[33;1mWARNING: $*\e[m"; }
function __echo_error() { echo -e "\e[31;1mERROR: $*\e[m"; }
function __exists() { type "$1" >/dev/null 2>&1; return $?; }
function __pathadd() { export PATH="$1:$PATH" }


# ==================== #
#    Plugin manager    #
# ==================== #

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"


# ==================== #
#    Plugins list      #
# ==================== #

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light Aloxaf/fzf-tab

# Fish-like history search pt. 1: pressing ↑ will search through history
zinit light zsh-users/zsh-history-substring-search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND=''
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND=''
HISTORY_SUBSTRING_SEARCH_FUZZY='true'

# Fish-like history search pt. 2: the grayed out part
zinit light zsh-users/zsh-autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::brew

# Load completions
autoload -U compinit && compinit

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
# zstyle ':completion:*' menu select
zstyle ':completion:*:setopt:*' menu true select
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'


# Keybindings
bindkey -e # disable vi keybindings
bindkey -s "®" 'source ~/.zshrc^M' # option + r to run `source ~/.zshrc`


# History
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


# ==================== #
#        Prompt        #
# ==================== #

# Enable substitution in the prompt.
autoload -U colors && colors
setopt prompt_subst

source ${DOTFILES:-$HOME/dotfiles}/common/git_info.rc
source ${DOTFILES:-$HOME/dotfiles}/common/prompt.rc

# Note: a one liner for displaying available colors
# $ for c in {000..255}; do echo -n "\e[38;5;${c}m $c" ; [ $(($c%16)) -eq 15 ] && echo;done;echo

PROMPT=''
# PROMPT+='%F{189}%K{000}[%n@%m]%f%k ' # Display the username followed by @ and hostname in yellow
PROMPT+='%F{099}[%n]%f ' # Display the username followed by @ and hostname in yellow
PROMPT+='%F{blue} $(__shorten_path)%f' # Display the current working directory in blue
PROMPT+='%F{cyan}$(__git_info)%f ' # Display the vcs info in red
PROMPT+='%(?.%F{green}❯ .%F{red}❯ )' # Display a green prompt if the last command succeeded, or red if it failed
PROMPT+='%f' # Reset the text color

# ======================== #
#   Integrations and vars  #
# ======================== #

# Shell integrations
source <(fzf --zsh) # enable fuzzy find
eval "$(zoxide init zsh --hook prompt )" # enable zoxide

# Homebrew (assuming installed at /opt/homebrew)
if [ "$(uname)" = Darwin ] && [ -f /opt/homebrew/bin/brew ]; then
    eval $(/opt/homebrew/bin/brew shellenv)
else
    __echo_error Homebrew installation does not exist.
fi

# CUDA
if [ -L /usr/local/cuda ] || [ -d /usr/local/cuda ]; then
    export PATH="/usr/local/cuda/bin:$PATH"
    export LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"
else
    if [ ! "$(uname)" = Darwin ]; then
        __echo_error "CUDA installation not found."
    fi
fi

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if __exists pyenv; then
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
else
    __echo_error "pyenv not found."
fi

export PYTHONDONTWRITEBYTECODE=1 # do not create __pychache__

typeset -U path PATH # delete dups in PATH


# =========== #
#   Aliases   #
# =========== #

alias cd="z"
source $DOTFILES/common/aliases.rc
