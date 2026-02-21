# dotfiles

## Setup

```bash
git clone https://github.com/keishihara/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
./scripts/install-cli-tools.sh  # fzf, ripgrep, delta
```

This creates symlinks from `$HOME` (and `~/.config/`) to the dotfiles in this repository.
Existing files are backed up with a `.backup.<timestamp>` suffix.

## Managed files


| Path               | Description            |
| ------------------ | ---------------------- |
| `.bashrc`          | Bash config (portable) |
| `.gitconfig`       | Git config (portable)  |
| `.tmux.conf`       | tmux config            |
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

## Scripts


| Script                                 | Description                                                  |
| -------------------------------------- | ------------------------------------------------------------ |
| `scripts/install-cli-tools.sh`         | Install fzf, ripgrep, delta, lazygit to `~/.local/bin` (no sudo) |
| `scripts/install-cursor-extensions.sh` | Install Cursor/VSCode extensions from `cursor-extensions.txt` |


