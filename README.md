# dotfiles

## Setup

```bash
git clone https://github.com/keishihara/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
./scripts/install-cli-tools.sh  # fzf, ripgrep, delta, lazygit, neovim
```

This creates symlinks from `$HOME` (and `~/.config/`) to the dotfiles in this repository.
Existing files are backed up with a `.backup.<timestamp>` suffix.

## Managed files


| Path               | Description            |
| ------------------ | ---------------------- |
| `.bashrc`          | Bash config (portable) |
| `.gitconfig`       | Git config (portable)  |
| `.tmux.conf`       | tmux config            |
| `.config/nvim/`    | Neovim config          |
| `.config/wezterm/` | WezTerm config         |


## Local overrides

Machine-specific settings go in `*.local` files (git-ignored):


| File                 | Purpose                                           |
| -------------------- | ------------------------------------------------- |
| `~/.bashrc.local`    | Shell: PATH, module loads, cluster commands, etc. |
| `~/.gitconfig.local` | Git: credential helpers, user overrides, etc.     |


Create these files manually on each machine:

```bash
touch ~/.bashrc.local
touch ~/.gitconfig.local
```

## Neovim keybindings

`<leader>` is mapped to `Space`.

### Files and search

| Key | Action | Notes |
| --- | ------ | ----- |
| `Space b` | Toggle file sidebar | Opens/closes Neo-tree on the left |
| `Space e` | Focus file sidebar / return to editor | If Neo-tree is closed, it opens it |
| `Space f f` | File search | Telescope `find_files`, including hidden and ignored files |
| `Space f g` | String search | Telescope `live_grep` |
| `Space f b` | Buffer list | Telescope buffers picker |

### Buffers and LSP

| Key | Action |
| --- | ------ |
| `Space Space` | Switch to previous buffer |
| `Space b p` | Previous buffer |
| `Space b n` | Next buffer |
| `K` | LSP hover |
| `g d` | Go to definition |
| `Space c a` | Code action |

Neo-tree and Telescope prompt windows otherwise use the plugins' default keybindings.

## Scripts


| Script                                 | Description                                                  |
| -------------------------------------- | ------------------------------------------------------------ |
| `scripts/install-cli-tools.sh`         | Install fzf, ripgrep, delta, lazygit, neovim to `~/.local/bin` (no sudo) |
| `scripts/install-cursor-extensions.sh` | Install Cursor/VSCode extensions from `cursor-extensions.txt` |

