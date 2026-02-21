# dotfiles

## Setup

```bash
git clone https://github.com/keishihara/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

This creates symlinks from `$HOME` to the dotfiles in this repository.
Existing files are backed up with a `.backup.<timestamp>` suffix.

## Local overrides

Machine-specific settings go in `*.local` files (git-ignored):

| File                 | Purpose                                           |
|----------------------|---------------------------------------------------|
| `~/.bashrc.local`    | Shell: PATH, module loads, cluster commands, etc. |
| `~/.gitconfig.local` | Git: credential helpers, etc.                     |

Templates are provided as `*.local.example`. To get started:

```bash
cp .bashrc.local.example ~/.bashrc.local
cp .gitconfig.local.example ~/.gitconfig.local
# Edit each file for your environment
```
