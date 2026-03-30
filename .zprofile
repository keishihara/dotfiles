# ~/.zprofile — login shell

# PATH
export PATH="$HOME/.local/bin:$PATH"

# Python
export PYTHONDONTWRITEBYTECODE=1

# fzf (use fd if available)
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Deduplicate PATH
typeset -U path PATH
