# Terminal keys: making Shift+Enter reach a TUI over SSH + tmux

Getting `Shift+Enter` (insert a newline instead of submitting) to work in a TUI such as
Codex CLI, when running inside tmux over SSH from the Cursor/VS Code integrated terminal.

## Why it does not work out of the box

A terminal sends the same single byte (`CR`, `0x0D`) for both `Enter` and `Shift+Enter`.
Telling them apart requires an extended-key encoding — the kitty keyboard protocol
(`CSI 13;2u` for Shift+Enter) or `modifyOtherKeys`.

Three layers must all cooperate. If any one of them drops the sequence, the key is dead:

1. **Terminal emulator** — must send the extended-key sequence at all.
2. **tmux** — must forward it to the pane instead of collapsing it back to `CR`.
3. **The TUI** — must have an action bound to that key.

## 1. Cursor / VS Code (local machine)

The integrated terminal does not send an extended-key sequence for `Shift+Enter` by
default. Add this to `keybindings.json`
(Command Palette → *Preferences: Open Keyboard Shortcuts (JSON)*):

```json
{
  "key": "shift+enter",
  "command": "workbench.action.terminal.sendSequence",
  "args": { "text": "\u001b[13;2u" },
  "when": "terminalFocus"
}
```

This file lives on the **local** machine, not on the remote host, so it is not managed by
this repo. On macOS it is at
`~/Library/Application Support/Cursor/User/keybindings.json`.

## 2. tmux (remote host) — `always`, not `on`

In `.tmux.conf`:

```tmux
set -s extended-keys always
set -as terminal-features 'xterm*:extkeys'
```

`extended-keys on` is **not** enough. With `on`, tmux forwards extended keys only when the
application has asked for them, and tmux 3.4 does not recognize the kitty protocol request
(`CSI > 7 u`) that Codex and other crossterm-based TUIs send — so it silently swallows the
sequence. Measured on tmux 3.4 by injecting `ESC[13;2u` into an attached client:

| setting | what the pane received |
| --- | --- |
| `extended-keys on` | *(nothing — dropped)* |
| `extended-keys always` | `\x1b[13;2u` |

`extended-keys` is a **server** option, so changes need `tmux kill-server` (or a fresh
server) to take effect — sourcing the config into a running server is not always enough.

Caveat: `always` makes tmux use the extended format for every key that has one, even for
applications that never asked. TUIs that do not understand `CSI u` could in principle see
garbage for modified keys. Not observed in practice with vim/nvim/codex.

## 3. Codex CLI (remote host)

In `~/.codex/config.toml`:

```toml
[tui.keymap.editor]
insert_newline = ["shift-enter", "ctrl-j"]
```

Codex refuses to start if a binding collides with a default, with an error like:

```
Error: Invalid `tui.keymap` configuration: Ambiguous `tui.keymap.editor` bindings:
`insert_newline` and `move_down` use the same key.
```

Keys checked against Codex 0.145.0 defaults:

| key | usable for `insert_newline` |
| --- | --- |
| `shift-enter` | yes |
| `ctrl-j` | yes |
| `alt-enter` | yes (but see below) |
| `ctrl-n` | **no** — collides with `move_down` |
| `ctrl-o` | **no** — collides with `copy` |

## What actually ends up working

| | Shift+Enter | Ctrl+J | Alt+Enter |
| --- | --- | --- | --- |
| inside tmux | yes | no | no |
| no tmux | yes | yes | no |

- `Ctrl+J` is consumed inside tmux by `vim-tmux-navigator`, which binds `C-h/j/k/l` in the
  root key table for pane navigation. It only reaches the pane when the pane is running
  vim. To free it for other TUIs, the plugin's `is_vim` check would have to be overridden
  after the plugin loads.
- `Alt+Enter` never arrives on macOS — window management apps grab it system-wide before
  the terminal sees it.

So `Shift+Enter` is the only one that works everywhere, and `Ctrl+J` is a useful fallback
outside tmux.

## Debugging recipe

To see what a pane actually receives, run a program in raw mode that enables the kitty
protocol (`ESC[>7u`) and dumps stdin, then inject bytes into an attached tmux client from a
pty. Comparing "what was injected" against "what the pane read" isolates which of the three
layers is dropping the key.
