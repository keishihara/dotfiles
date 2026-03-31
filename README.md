# dotfiles

## Setup

### macOS

```bash
git clone https://github.com/keishihara/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
./scripts/install-cli-tools.sh  # mise, fzf, ripgrep, delta, lazygit, zoxide, neovim
brew bundle --global             # macOS packages and casks from ~/.Brewfile
```

### Linux (remote server)

```bash
git clone https://github.com/keishihara/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
./scripts/install-cli-tools.sh  # mise, fzf, ripgrep, delta, lazygit, zoxide, neovim
```

`install.sh` creates symlinks from `$HOME` (and `~/.config/`) to the dotfiles in this repository.
Existing files are backed up with a `.backup.<timestamp>` suffix.
To remove all symlinks, run `./uninstall.sh` (restores the most recent backup if available).

## Managed files

| Path | Description | Platforms |
| --- | --- | --- |
| `.bashrc` | Bash config | All |
| `.zshrc` | Zsh config | macOS |
| `.zprofile` | Zsh login shell (PATH, env vars) | macOS |
| `.vimrc` | Vim config | All |
| `.gitconfig` | Git config | All |
| `.tmux.conf` | tmux config (TPM + vim-tmux-navigator) | All |
| `.Brewfile` | Homebrew packages | macOS |
| `.config/nvim/` | Neovim config (lazy.nvim) | All |
| `.config/wezterm/` | WezTerm config | All |

## Local overrides

Machine-specific settings go in `*.local` files (git-ignored):

| File | Purpose |
| --- | --- |
| `~/.bashrc.local` | Shell: PATH, module loads, cluster commands, etc. |
| `~/.zshrc.local` | Shell: ssh-agent, machine-specific integrations |
| `~/.gitconfig.local` | Git: credential helpers, user overrides, etc. |

## Neovim keybindings

`<leader>` is mapped to `Space`.

### Files and search

| Key | Action | Notes |
| --- | --- | --- |
| `Space b` | Toggle file sidebar | Opens/closes Neo-tree on the left |
| `Space e` | Focus file sidebar / return to editor | If Neo-tree is closed, it opens it |
| `Space f f` | File search | Telescope `find_files`, including hidden and ignored files |
| `Space f g` | String search | Telescope `live_grep` |
| `Space f b` | Buffer list | Telescope buffers picker |

### Buffers and LSP

| Key | Action |
| --- | --- |
| `Space Space` | Switch to previous buffer |
| `Space b p` | Previous buffer |
| `Space b n` | Next buffer |
| `K` | LSP hover |
| `g d` | Go to definition |
| `Space c a` | Code action |

Neo-tree and Telescope prompt windows otherwise use the plugins' default keybindings.

## Scripts

| Script | Description |
| --- | --- |
| `scripts/install-cli-tools.sh` | Install mise, fzf, ripgrep, delta, lazygit, zoxide, neovim to `~/.local/bin` (no sudo) |
| `scripts/install-cursor-extensions.sh` | Install Cursor/VSCode extensions from `cursor-extensions.txt` |
