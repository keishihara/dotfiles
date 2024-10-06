# dotfiles

### Quick Start

This assumes you have already completed the initial setup of your machine (e.g., you have Xcode, Homebrew, etc. installed). Run the following commands to symlink the dotfiles to `$HOME` directory:

```bash
git clone https://github.com/keishihara/dotfiles ~/dotfiles
cd ~/dotfiles && ./install.sh
```

### Bootstrap and Install

If this is the first time setting up your machine after purchasing it, you should start with this section. Here is a list of steps you may need to follow (adjust what to install based on your platform):

- Update the OS
- Update Xcode by running: `$ xcode-select --install` - this will trigger a setup window.
- Install Homebrew
- Change the default shell if needed

Then, run the following shell script, which installs the necessary packages and desktop applications:

```bash
git clone https://github.com/keishihara/dotfiles ~/dotfiles
cd ~/dotfiles && ./init.sh
```

Also, deploy the dotfiles to your `$HOME` directory:

```bash
cd ~/dotfiles && ./install.sh
```

Afterward, restart your terminal app, or run the following command to apply the changes:

```bash
exec $SHELL -l
```

Then, install the Tmux Plugin Manager and (re)start the tmux session:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
tmux kill-server
tmux
```

Inside the tmux session, press the following keybindings to install tmux plugins:

1. `prefix` + `I` (capital I to fetch the plugins)
2. `prefix` + `r` (to reload the `~/.tmux.conf`)

For more information about the tpm, please refer to the [official repository](https://github.com/tmux-plugins/tpm/tree/master).


### Inspired by

- https://github.com/josean-dev/dev-environment-files?tab=readme-ov-file
- https://github.com/tarneaux/.f

### Troubleshooting

- How to share the tmux clipboard with your system: https://www.seanh.cc/2020/12/27/copy-and-paste-in-tmux/
- pyenv: Unable to install Python 3.8.0 on macOS: https://github.com/pyenv/pyenv/issues/1740#issuecomment-738749988
