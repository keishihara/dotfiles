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

# Enable cache
zinit ice wait'!0' lucid cache

# Load completions
# if ls ~/.zcompdump* &> /dev/null; then
#     rm ~/.zcompdump*
# fi
# autoload -U compinit
# compinit -C  # skip security checking. Without -C option it'll take so long here
# compinit

autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
	compinit
else
	compinit -C
fi

compdef -d git # Use fzf instead

zinit light Aloxaf/fzf-tab # This should be loaded after compinit and before other pulugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions

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

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# zstyle ':completion:*:setopt:*' menu true select
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# copied from: https://github.com/Aloxaf/fzf-tab?tab=readme-ov-file#configure
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
# NOTE: don't use escape sequences here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'


# ============== #
#    History     #
# ============== #

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

# Define functions for the prompt, which must be defined before starting a worker
source ${DOTFILES:-$HOME/dotfiles}/common/prompt.rc

# Allow prompt substitution
setopt prompt_subst # this allows %(...) command substitution and variable expansion in the prompt.

# Basic prompt
# BASIC_PROMPT=''
# BASIC_PROMPT+='%F{099}[%n]%f '
# BASIC_PROMPT+='%F{blue} %~%f '
# BASIC_PROMPT+='%(?.%F{green}❯ .%F{red}❯ )%f'
# PROMPT=$BASIC_PROMPT

zinit light mafredri/zsh-async
async_init

# Initialize a variable for storing git info
__GIT_PROMPT_INFO=""

# Start a worker for getting git information
async_start_worker git_worker -u -n

_git_info_callback() {
    local job_name="$1"
    local ret_code="$2"
    local output="$3"
    local exec_time="$4"
    local error_output="$5"
    local has_next="$6"

    # Message for debugging
    # echo "Callback called with output: $output" >&2

    if [[ "$job_name" == "[async]" ]]; then
        echo "Async error: $error_output" >&2
    else
        __GIT_PROMPT_INFO="$output"

        # Update the prompt
        zle && zle reset-prompt
    fi

    # Process if there are other results in buffer
    if [[ "$has_next" -eq 1 ]]; then
        async_process_results git_worker _git_info_callback
    fi
}

# Register the callback function
async_register_callback git_worker _git_info_callback

PROMPT=''
PROMPT+='%F{099}[%n]%f '
PROMPT+='%F{blue} $(__shorten_path)%f '
PROMPT+='%F{cyan}${__GIT_PROMPT_INFO}%f '
PROMPT+=$'\n'
PROMPT+='%(?.%F{green}❯ .%F{red}❯ )%f'

RPROMPT='%F{242}%*%f' # Current time on the right prompt

# Executed every time you hit the enter key
precmd() {
    # Process the results of async job
    async_process_results git_worker _git_info_callback

    # Sync worker's current directory to the shell's one
    async_worker_eval git_worker "cd $PWD"

    # Get the git info in async way
    async_job git_worker __update_git_info
}


# ===================== #
#      Keybindings      #
# ===================== #

bindkey -e # disable vi keybindings
bindkey -s '^[r' 'source ~/.zshrc^M' # option + r to run `source ~/.zshrc`


# https://gist.github.com/junegunn/f4fca918e937e6bf5bad?permalink_comment_id=2981199#gistcomment-2981199
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

# https://stackoverflow.com/a/9810485
__git_files () {
    _wanted files expl 'local files' _files
}


# =========== #
#   Aliases   #
# =========== #

source ${DOTFILES:-$HOME/dotfiles}/common/aliases.rc
alias cd="z"


# ======================== #
#   Integrations and vars  #
# ======================== #

# Shell integrations
source <(fzf --zsh) # enable fuzzy find
eval "$(zoxide init zsh --hook prompt )" # enable zoxide

# Homebrew
if [ "$(uname)" = Darwin ]; then
    if [ -x "$(command -v brew)" ]; then
        eval "$(brew shellenv)"
    else
        __echo_error "Homebrew is not installed."
    fi
fi

# Pyenv
if __exists pyenv; then
    eval "$(pyenv init -)"
else
    __echo_error "pyenv not found."
fi

# fzf
# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

# fzf-git
[ -e ~/.config/fzf/fzf-git.sh/fzf-git.sh ] && source ~/.config/fzf/fzf-git.sh/fzf-git.sh || echo fzf-git.sh not found
