#!/bin/bash
set -euo pipefail

# Install CLI tools to ~/.local/bin (no sudo required)
# Supports: mise, fzf, ripgrep, delta, lazygit, neovim

INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"

ARCH="$(uname -m)"
case "$ARCH" in
    x86_64)  ARCH_FZF="linux_amd64" ARCH_RG="x86_64-unknown-linux-musl" ARCH_DELTA="x86_64-unknown-linux-musl" ARCH_LG="Linux_x86_64" ARCH_ZO="x86_64-unknown-linux-musl" ;;
    aarch64) ARCH_FZF="linux_arm64" ARCH_RG="aarch64-unknown-linux-gnu" ARCH_DELTA="aarch64-unknown-linux-gnu" ARCH_LG="Linux_arm64" ARCH_ZO="aarch64-unknown-linux-musl" ;;
    *) echo "ERROR: Unsupported architecture: $ARCH"; exit 1 ;;
esac

# Pinned versions
FZF_VERSION="0.61.1"
RG_VERSION="14.1.1"
DELTA_VERSION="0.18.2"
LAZYGIT_VERSION="0.44.1"
NVIM_VERSION="0.11.5"
ZOXIDE_VERSION="0.9.6"

version_ge() {
    [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]
}

get_nvim_version() {
    nvim --version | head -1 | awk '{print $2}' | sed 's/^v//'
}

install_mise() {
    if command -v mise &>/dev/null; then
        echo "OK:   mise $(mise --version | awk '{print $2}')"
        return
    fi
    if [ -x "$INSTALL_DIR/mise" ]; then
        echo "OK:   mise $("$INSTALL_DIR/mise" --version | awk '{print $2}')"
        return
    fi
    echo "Installing mise..."
    sh -c "$(curl -fsSL https://mise.run)"
    if [ ! -x "$INSTALL_DIR/mise" ]; then
        echo "ERROR: mise installation failed (expected $INSTALL_DIR/mise)"
        exit 1
    fi
    echo "DONE: mise $("$INSTALL_DIR/mise" --version | awk '{print $2}') -> $INSTALL_DIR/mise"
}

install_fzf() {
    if command -v fzf &>/dev/null; then
        echo "OK:   fzf $(fzf --version | awk '{print $1}')"
        return
    fi
    echo "Installing fzf $FZF_VERSION..."
    local url="https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}/fzf-${FZF_VERSION}-${ARCH_FZF}.tar.gz"
    local tmp="$(mktemp -d)"
    curl -sL "$url" | tar xz -C "$tmp"
    mv "$tmp/fzf" "$INSTALL_DIR/fzf"
    chmod +x "$INSTALL_DIR/fzf"
    rm -rf "$tmp"
    echo "DONE: fzf $FZF_VERSION -> $INSTALL_DIR/fzf"
}

install_ripgrep() {
    if command -v rg &>/dev/null; then
        echo "OK:   rg $(rg --version | head -1 | awk '{print $2}')"
        return
    fi
    echo "Installing ripgrep $RG_VERSION..."
    local name="ripgrep-${RG_VERSION}-${ARCH_RG}"
    local url="https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/${name}.tar.gz"
    local tmp="$(mktemp -d)"
    curl -sL "$url" | tar xz -C "$tmp"
    mv "$tmp/$name/rg" "$INSTALL_DIR/rg"
    chmod +x "$INSTALL_DIR/rg"
    rm -rf "$tmp"
    echo "DONE: rg $RG_VERSION -> $INSTALL_DIR/rg"
}

install_delta() {
    if command -v delta &>/dev/null; then
        echo "OK:   delta $(delta --version | awk '{print $2}')"
        return
    fi
    echo "Installing delta $DELTA_VERSION..."
    local name="delta-${DELTA_VERSION}-${ARCH_DELTA}"
    local url="https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/${name}.tar.gz"
    local tmp="$(mktemp -d)"
    curl -sL "$url" | tar xz -C "$tmp"
    mv "$tmp/$name/delta" "$INSTALL_DIR/delta"
    chmod +x "$INSTALL_DIR/delta"
    rm -rf "$tmp"
    echo "DONE: delta $DELTA_VERSION -> $INSTALL_DIR/delta"
}

install_lazygit() {
    if command -v lazygit &>/dev/null; then
        echo "OK:   lazygit $(lazygit --version | grep -oP 'version=\K[^,]+')"
        return
    fi
    echo "Installing lazygit $LAZYGIT_VERSION..."
    local url="https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_${ARCH_LG}.tar.gz"
    local tmp="$(mktemp -d)"
    curl -sL "$url" | tar xz -C "$tmp"
    mv "$tmp/lazygit" "$INSTALL_DIR/lazygit"
    chmod +x "$INSTALL_DIR/lazygit"
    rm -rf "$tmp"
    echo "DONE: lazygit $LAZYGIT_VERSION -> $INSTALL_DIR/lazygit"
}

install_neovim() {
    if command -v nvim &>/dev/null; then
        local current_version
        current_version="$(get_nvim_version)"
        if version_ge "$current_version" "$NVIM_VERSION"; then
            echo "OK:   nvim v$current_version"
            return
        fi
        echo "Updating neovim from v$current_version to v$NVIM_VERSION..."
    else
        echo "Installing neovim $NVIM_VERSION..."
    fi
    local nvim_dir="$HOME/.local/nvim"
    local archive="nvim-linux-x86_64"
    if [ "$ARCH" = "aarch64" ]; then archive="nvim-linux-aarch64"; fi
    local url="https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/${archive}.tar.gz"
    local tmp="$(mktemp -d)"
    curl -sL "$url" | tar xz -C "$tmp"
    rm -rf "$nvim_dir"
    mv "$tmp/$archive" "$nvim_dir"
    rm -rf "$tmp"
    ln -sf "$nvim_dir/bin/nvim" "$INSTALL_DIR/nvim"
    echo "DONE: nvim v$NVIM_VERSION -> $nvim_dir"
}

install_zoxide() {
    if command -v zoxide &>/dev/null; then
        echo "OK:   zoxide $(zoxide --version | awk '{print $2}')"
        return
    fi
    echo "Installing zoxide $ZOXIDE_VERSION..."
    local name="zoxide-${ZOXIDE_VERSION}-${ARCH_ZO}"
    local url="https://github.com/ajeetdsouza/zoxide/releases/download/v${ZOXIDE_VERSION}/${name}.tar.gz"
    local tmp="$(mktemp -d)"
    curl -sL "$url" | tar xz -C "$tmp"
    mv "$tmp/zoxide" "$INSTALL_DIR/zoxide"
    chmod +x "$INSTALL_DIR/zoxide"
    rm -rf "$tmp"
    echo "DONE: zoxide $ZOXIDE_VERSION -> $INSTALL_DIR/zoxide"
}

install_mise
install_fzf
install_ripgrep
install_delta
install_lazygit
install_zoxide
install_neovim
