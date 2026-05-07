#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"

backup_path() {
  local path="$1"

  if [ -e "$path" ] || [ -L "$path" ]; then
    mv "$path" "${path}.bak.${TIMESTAMP}"
  fi
}

install_packages_macos() {
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew is required on macOS. Install it from https://brew.sh and rerun this script." >&2
    exit 1
  fi

  brew update
  brew install neovim tmux git curl ripgrep fd fzf node rust
}

install_packages_linux() {
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y neovim tmux git curl ripgrep fd-find fzf nodejs npm cargo
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y neovim tmux git curl ripgrep fd-find fzf nodejs npm cargo
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --needed --noconfirm neovim tmux git curl ripgrep fd fzf nodejs npm rust
  elif command -v zypper >/dev/null 2>&1; then
    sudo zypper install -y neovim tmux git curl ripgrep fd fzf nodejs npm cargo
  else
    echo "Unsupported Linux package manager. Install neovim, tmux, git, curl, ripgrep, fd, fzf, node, npm, and cargo manually." >&2
    exit 1
  fi

  if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  fi
}

install_packages() {
  case "$(uname -s)" in
    Darwin)
      install_packages_macos
      ;;
    Linux)
      install_packages_linux
      ;;
    *)
      echo "Unsupported operating system: $(uname -s)" >&2
      exit 1
      ;;
  esac
}

install_tpm() {
  local tpm_dir="$HOME/.tmux/plugins/tpm"

  if [ ! -d "$tpm_dir" ]; then
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
  fi
}

configure_tpm_path() {
  if command -v tmux >/dev/null 2>&1; then
    tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.tmux/plugins" 2>/dev/null || true
  fi
}

install_tmux_config() {
  local tmux_conf="$HOME/.tmux.conf"

  backup_path "$tmux_conf"
  cp "$SCRIPT_DIR/tmux.conf" "$tmux_conf"
}

install_nvim_config() {
  local nvim_dir="$HOME/.config/nvim"

  backup_path "$nvim_dir"
  mkdir -p "$HOME/.config"
  mkdir -p "$nvim_dir"
  cp -R "$SCRIPT_DIR/nvim/." "$nvim_dir/"
}

install_bin_scripts() {
  mkdir -p "$HOME/.local/bin"
  cp "$SCRIPT_DIR/bin/oddconf-tmux" "$HOME/.local/bin/oddconf-tmux"
  chmod +x "$HOME/.local/bin/oddconf-tmux"
}

install_shell_alias() {
  local rc_file

  case "${SHELL:-}" in
    */zsh)
      rc_file="$HOME/.zshrc"
      ;;
    */bash)
      rc_file="$HOME/.bashrc"
      ;;
    *)
      rc_file="$HOME/.profile"
      ;;
  esac

  mkdir -p "$(dirname "$rc_file")"
  touch "$rc_file"

  if ! grep -q "OddConf managed alias" "$rc_file"; then
    cat <<'EOF' >> "$rc_file"

# OddConf managed alias
export PATH="$HOME/.local/bin:$PATH"
alias vim='nvim'
# End OddConf managed alias
EOF
  fi

  if ! grep -q "OddConf managed tmux session" "$rc_file"; then
    cat <<'EOF' >> "$rc_file"

# OddConf managed tmux session
if [ -z "${TMUX:-}" ] && [ -z "${ODDCONF_NO_TMUX:-}" ] && [ -t 1 ] && command -v oddconf-tmux >/dev/null 2>&1; then
  case "$-" in
    *i*) oddconf-tmux ;;
  esac
fi
# End OddConf managed tmux session
EOF
  fi
}

cleanup_stale_lazy_plugins() {
  local lazy_dir="$HOME/.local/share/nvim/lazy"
  local plugin

  for plugin in LuaSnip cmp_luasnip; do
    if [ -d "$lazy_dir/$plugin" ]; then
      rm -rf "$lazy_dir/$plugin"
    fi
  done
}

main() {
  install_packages
  install_tpm
  install_tmux_config
  configure_tpm_path
  install_nvim_config
  install_bin_scripts
  cleanup_stale_lazy_plugins
  install_shell_alias

  if [ -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]; then
    "$HOME/.tmux/plugins/tpm/bin/install_plugins"
  fi

  echo "OddConf installed."
}

main "$@"
