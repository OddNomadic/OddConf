# OddConf
OddConf is my personal bootstrap for a consistent Neovim + tmux dev environment.

It is now set up for macOS and Linux first. Windows is not a primary target yet, but WSL should be a reasonable path if I add it later.

## What It Installs
- Neovim config from the `nvim/` directory in this repo
- `tmux.conf`
- tmux plugin manager
- A `vim` alias that points to `nvim` in your shell config

## Supported Systems
- macOS with Homebrew
- Linux with `apt`, `dnf`, `pacman`, or `zypper`

## Install
```bash
./install.sh
```

If Homebrew is not installed on macOS, install it first from https://brew.sh.
