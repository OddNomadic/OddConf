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
  cp "$SCRIPT_DIR/bin/oddconf-tmux" "$SCRIPT_DIR/bin/oddconf-splash" "$HOME/.local/bin/"
  chmod +x "$HOME/.local/bin/oddconf-tmux" "$HOME/.local/bin/oddconf-splash"
}

replace_managed_block() {
  local file="$1"
  local start_marker="$2"
  local end_marker="$3"
  local block="$4"
  local tmp_file

  tmp_file="$(mktemp)"

  awk -v start="$start_marker" -v end="$end_marker" '
    $0 == start { skipping = 1; next }
    $0 == end { skipping = 0; next }
    !skipping { print }
  ' "$file" > "$tmp_file"

  printf '\n%s\n' "$block" >> "$tmp_file"
  mv "$tmp_file" "$file"
}

install_shell_alias() {
  local rc_file
  local alias_block
  local fzf_block
  local tmux_block

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

  alias_block="$(cat <<'EOF'
# OddConf managed alias
export PATH="$HOME/.local/bin:$PATH"
alias vim='nvim'
case "$(uname -s)" in
  Darwin)
    export CLICOLOR=1
    export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"
    alias ls='ls -GFh'
    alias ll='ls -lAhGF'
    alias la='ls -AhGF'
    ;;
  *)
    alias ls='ls --color=auto -Fh'
    alias ll='ls --color=auto -lAhF'
    alias la='ls --color=auto -AhF'
    ;;
esac
# End OddConf managed alias
EOF
)"

  fzf_block="$(cat <<'EOF'
# OddConf managed fzf
if [ -n "${ZSH_VERSION:-}" ] && [[ -o interactive ]] && command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"

  oddconf_fzf_files() {
    local selected
    if command -v fd >/dev/null 2>&1; then
      selected="$(fd --type f --hidden --exclude .git | fzf --height 40% --reverse --prompt='file> ')"
    else
      selected="$(find . -type f -not -path '*/.git/*' | sed 's#^\./##' | fzf --height 40% --reverse --prompt='file> ')"
    fi

    if [ -n "$selected" ]; then
      LBUFFER+="${(q)selected}"
    fi
    zle redisplay
  }

  oddconf_fzf_dirs() {
    local selected
    if command -v fd >/dev/null 2>&1; then
      selected="$(fd --type d --hidden --exclude .git | fzf --height 40% --reverse --prompt='cd> ')"
    else
      selected="$(find . -type d -not -path '*/.git/*' | sed 's#^\./##' | fzf --height 40% --reverse --prompt='cd> ')"
    fi

    if [ -n "$selected" ]; then
      cd "$selected" || return
    fi
    zle reset-prompt
  }

  zle -N oddconf_fzf_files
  zle -N oddconf_fzf_dirs
  bindkey '^[f' oddconf_fzf_files
  bindkey '^[d' oddconf_fzf_dirs
elif [ -n "${BASH_VERSION:-}" ] && [[ $- == *i* ]] && command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --bash)"
fi
# End OddConf managed fzf
EOF
)"

  tmux_block="$(cat <<'EOF'
# OddConf managed tmux session
# Auto-attach to tmux session on interactive shells
if command -v tmux >/dev/null 2>&1; then
  if [ -z "$TMUX" ] && [[ -o interactive ]]; then
    tmux new-session -A -s main
  fi
fi
# End OddConf managed tmux session
EOF
)"

  replace_managed_block "$rc_file" "# OddConf managed alias" "# End OddConf managed alias" "$alias_block"
  replace_managed_block "$rc_file" "# OddConf managed fzf" "# End OddConf managed fzf" "$fzf_block"
  replace_managed_block "$rc_file" "# OddConf managed splash" "# End OddConf managed splash" ""
  replace_managed_block "$rc_file" "# OddConf managed terminal stdio" "# End OddConf managed terminal stdio" ""
  replace_managed_block "$rc_file" "# OddConf managed tmux session" "# End OddConf managed tmux session" "$tmux_block"
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
