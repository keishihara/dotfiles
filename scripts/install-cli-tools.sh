#!/bin/bash
set -euo pipefail

# Install CLI tools to ~/.local/bin (no sudo required)
# Supports: Linux (x86_64, aarch64) and macOS (x86_64, arm64)

INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"

OS="$(uname -s)"
ARCH="$(uname -m)"

case "${OS}_${ARCH}" in
    Linux_x86_64)
        ARCH_FZF="linux_amd64"
        ARCH_RG="x86_64-unknown-linux-musl"
        ARCH_DELTA="x86_64-unknown-linux-musl"
        ARCH_LG="Linux_x86_64"
        ARCH_ZO="x86_64-unknown-linux-musl"
        ARCH_NVIM="nvim-linux-x86_64"
        ARCH_GLOW="Linux_x86_64"
        ARCH_YAZI="x86_64-unknown-linux-musl"
        ARCH_DEB_LIB="x86_64-linux-gnu"
        ;;
    Linux_aarch64)
        ARCH_FZF="linux_arm64"
        ARCH_RG="aarch64-unknown-linux-gnu"
        ARCH_DELTA="aarch64-unknown-linux-gnu"
        ARCH_LG="Linux_arm64"
        ARCH_ZO="aarch64-unknown-linux-musl"
        ARCH_NVIM="nvim-linux-aarch64"
        ARCH_GLOW="Linux_arm64"
        ARCH_YAZI="aarch64-unknown-linux-musl"
        ARCH_DEB_LIB="aarch64-linux-gnu"
        ;;
    Darwin_x86_64)
        ARCH_FZF="darwin_amd64"
        ARCH_RG="x86_64-apple-darwin"
        ARCH_DELTA="x86_64-apple-darwin"
        ARCH_LG="Darwin_x86_64"
        ARCH_ZO="x86_64-apple-darwin"
        ARCH_NVIM="nvim-macos-x86_64"
        ARCH_GLOW="Darwin_x86_64"
        ARCH_YAZI="x86_64-apple-darwin"
        ;;
    Darwin_arm64)
        ARCH_FZF="darwin_arm64"
        ARCH_RG="aarch64-apple-darwin"
        ARCH_DELTA="aarch64-apple-darwin"
        ARCH_LG="Darwin_arm64"
        ARCH_ZO="aarch64-apple-darwin"
        ARCH_NVIM="nvim-macos-arm64"
        ARCH_GLOW="Darwin_arm64"
        ARCH_YAZI="aarch64-apple-darwin"
        ;;
    *)
        echo "ERROR: Unsupported platform: ${OS}_${ARCH}"
        exit 1
        ;;
esac

# Pinned versions
FZF_VERSION="0.61.1"
RG_VERSION="14.1.1"
DELTA_VERSION="0.18.2"
LAZYGIT_VERSION="0.44.1"
NVIM_VERSION="0.11.5"
ZOXIDE_VERSION="0.9.6"
GLOW_VERSION="2.1.2"
YAZI_VERSION="26.5.6"
CHAFA_VERSION="1.18.2"
TMUX_VERSION="3.6b"
NCURSES_VERSION="6.5"
LIBEVENT_VERSION="2.1.12-stable"

version_ge() {
    [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]
}

get_nvim_version() {
    nvim --version | head -1 | awk '{print $2}' | sed 's/^v//'
}

get_chafa_version() {
    chafa --version | head -1 | awk '{print $3}'
}

get_tmux_version() {
    tmux -V | awk '{print $2}'
}

extract_zip() {
    local archive="$1"
    local dest="$2"

    if command -v unzip &>/dev/null; then
        unzip -q "$archive" -d "$dest"
        return
    fi
    if command -v bsdtar &>/dev/null; then
        bsdtar -xf "$archive" -C "$dest"
        return
    fi

    echo "ERROR: unzip or bsdtar is required to extract $archive"
    exit 1
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
    local url="https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/${ARCH_NVIM}.tar.gz"
    local tmp="$(mktemp -d)"
    curl -sL "$url" | tar xz -C "$tmp"
    rm -rf "$nvim_dir"
    mv "$tmp/$ARCH_NVIM" "$nvim_dir"
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

install_glow() {
    if command -v glow &>/dev/null; then
        echo "OK:   $(glow --version | head -1)"
        return
    fi
    echo "Installing glow $GLOW_VERSION..."
    local name="glow_${GLOW_VERSION}_${ARCH_GLOW}"
    local url="https://github.com/charmbracelet/glow/releases/download/v${GLOW_VERSION}/${name}.tar.gz"
    local tmp="$(mktemp -d)"
    curl -sL "$url" | tar xz -C "$tmp"
    mv "$tmp/$name/glow" "$INSTALL_DIR/glow"
    chmod +x "$INSTALL_DIR/glow"
    rm -rf "$tmp"
    echo "DONE: glow $GLOW_VERSION -> $INSTALL_DIR/glow"
}

install_yazi() {
    local yazi_real="$INSTALL_DIR/yazi.real"
    if command -v yazi &>/dev/null && command -v ya &>/dev/null; then
        if [ ! -x "$yazi_real" ]; then
            mv "$INSTALL_DIR/yazi" "$yazi_real"
            cat >"$INSTALL_DIR/yazi" <<'EOF'
#!/bin/bash
exec env -u TERM_PROGRAM -u TERM_PROGRAM_VERSION "$HOME/.local/bin/yazi.real" "$@"
EOF
            chmod +x "$INSTALL_DIR/yazi"
        fi
        echo "OK:   $(yazi --version | head -1)"
        return
    fi
    echo "Installing yazi $YAZI_VERSION..."
    local name="yazi-${ARCH_YAZI}"
    local url="https://github.com/sxyazi/yazi/releases/download/v${YAZI_VERSION}/${name}.zip"
    local tmp="$(mktemp -d)"
    curl -fsSL "$url" -o "$tmp/$name.zip"
    extract_zip "$tmp/$name.zip" "$tmp"

    local yazi_bin="$tmp/$name/yazi"
    local ya_bin="$tmp/$name/ya"
    if [ ! -f "$yazi_bin" ] || [ ! -f "$ya_bin" ]; then
        echo "ERROR: yazi archive did not contain expected yazi and ya binaries"
        rm -rf "$tmp"
        exit 1
    fi

    mv "$yazi_bin" "$yazi_real"
    mv "$ya_bin" "$INSTALL_DIR/ya"
    cat >"$INSTALL_DIR/yazi" <<'EOF'
#!/bin/bash
exec env -u TERM_PROGRAM -u TERM_PROGRAM_VERSION "$HOME/.local/bin/yazi.real" "$@"
EOF
    chmod +x "$yazi_real" "$INSTALL_DIR/yazi" "$INSTALL_DIR/ya"
    rm -rf "$tmp"
    echo "DONE: yazi $YAZI_VERSION -> $INSTALL_DIR/yazi, $INSTALL_DIR/ya"
}

install_chafa() {
    local chafa_dir="$HOME/.local/opt/chafa"
    local build_id="$CHAFA_VERSION-jpeg"
    if command -v chafa &>/dev/null; then
        local current_version
        current_version="$(get_chafa_version)"
        if version_ge "$current_version" "$CHAFA_VERSION" && [ -f "$chafa_dir/.build-id" ] && [ "$(cat "$chafa_dir/.build-id")" = "$build_id" ]; then
            echo "OK:   chafa $current_version"
            return
        fi
        echo "Updating chafa from $current_version to $CHAFA_VERSION..."
    else
        echo "Installing chafa $CHAFA_VERSION..."
    fi
    local tmp="$(mktemp -d)"
    local jobs
    jobs="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 2)"
    curl -fsSL "https://github.com/hpjansson/chafa/releases/download/${CHAFA_VERSION}/chafa-${CHAFA_VERSION}.tar.xz" -o "$tmp/chafa.tar.xz"
    tar -xf "$tmp/chafa.tar.xz" -C "$tmp"
    if [ "$OS" = "Linux" ]; then
        (
            cd "$tmp"
            apt-get download libjpeg-turbo8-dev >/dev/null
            dpkg-deb -x ./libjpeg-turbo8-dev*.deb deps
        )
    fi
    rm -rf "$chafa_dir"
    (
        cd "$tmp/chafa-$CHAFA_VERSION"
        if [ "$OS" = "Linux" ]; then
            export CPPFLAGS="-I$tmp/deps/usr/include -I$tmp/deps/usr/include/$ARCH_DEB_LIB${CPPFLAGS:+ $CPPFLAGS}"
            export LDFLAGS="-L$tmp/deps/usr/lib/$ARCH_DEB_LIB${LDFLAGS:+ $LDFLAGS}"
            export PKG_CONFIG_PATH="$tmp/deps/usr/lib/$ARCH_DEB_LIB/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
        fi
        ./configure --prefix="$chafa_dir" --disable-shared --enable-static --without-svg --without-webp --disable-dependency-tracking --disable-silent-rules
        make -j"$jobs"
        make install
    )
    echo "$build_id" >"$chafa_dir/.build-id"
    rm -f "$INSTALL_DIR/chafa"
    cat >"$INSTALL_DIR/chafa" <<'EOF'
#!/bin/bash
set -euo pipefail

has_format=0
has_symbols=0
next_is_format=0
for arg in "$@"; do
    case "$arg" in
        -h|--help|--version)
            exec "$HOME/.local/opt/chafa/bin/chafa" "$@"
            ;;
        --symbols|--symbols=*)
            has_symbols=1
            ;;
        -f|--format)
            next_is_format=1
            ;;
        --format=symbols)
            has_format=1
            ;;
        *)
            if [ "$next_is_format" = 1 ]; then
                [ "$arg" = "symbols" ] && has_format=1
                next_is_format=0
            fi
            ;;
    esac
done

if [ "$has_format" = 1 ]; then
    if [ "$has_symbols" = 0 ]; then
        exec "$HOME/.local/opt/chafa/bin/chafa" --symbols=block+border+space-wide "$@"
    fi
    exec "$HOME/.local/opt/chafa/bin/chafa" "$@"
fi

exec "$HOME/.local/opt/chafa/bin/chafa" --format=symbols --symbols=block+border+space-wide --passthrough=none --probe=off "$@"
EOF
    chmod +x "$INSTALL_DIR/chafa"
    rm -rf "$tmp"
    echo "DONE: chafa $CHAFA_VERSION -> $INSTALL_DIR/chafa"
}

install_tmux() {
    local tmux_dir="$HOME/.local/opt/tmux"
    local deps_dir="$HOME/.local/opt/tmux-deps"
    local build_id="$TMUX_VERSION-ncurses-$NCURSES_VERSION-libevent-$LIBEVENT_VERSION"
    if command -v tmux &>/dev/null; then
        local current_version
        current_version="$(get_tmux_version)"
        if version_ge "$current_version" "$TMUX_VERSION" && [ -f "$tmux_dir/.build-id" ] && [ "$(cat "$tmux_dir/.build-id")" = "$build_id" ]; then
            echo "OK:   tmux $current_version"
            return
        fi
        echo "Updating tmux from $current_version to $TMUX_VERSION..."
    else
        echo "Installing tmux $TMUX_VERSION..."
    fi

    local tmp="$(mktemp -d)"
    local jobs
    jobs="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 2)"
    curl -fsSL "https://ftp.gnu.org/pub/gnu/ncurses/ncurses-${NCURSES_VERSION}.tar.gz" -o "$tmp/ncurses.tar.gz"
    curl -fsSL "https://github.com/libevent/libevent/releases/download/release-${LIBEVENT_VERSION}/libevent-${LIBEVENT_VERSION}.tar.gz" -o "$tmp/libevent.tar.gz"
    curl -fsSL "https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz" -o "$tmp/tmux.tar.gz"
    tar -xf "$tmp/ncurses.tar.gz" -C "$tmp"
    tar -xf "$tmp/libevent.tar.gz" -C "$tmp"
    tar -xf "$tmp/tmux.tar.gz" -C "$tmp"

    rm -rf "$tmux_dir" "$deps_dir"
    mkdir -p "$deps_dir"
    (
        cd "$tmp/ncurses-$NCURSES_VERSION"
        ./configure --prefix="$deps_dir" --enable-widec --with-shared --without-debug --without-ada --without-manpages --enable-pc-files --with-pkg-config-libdir="$deps_dir/lib/pkgconfig"
        make -j"$jobs"
        make install
    )
    (
        cd "$tmp/libevent-$LIBEVENT_VERSION"
        ./configure --prefix="$deps_dir" --disable-openssl --disable-samples
        make -j"$jobs"
        make install
    )
    (
        cd "$tmp/tmux-$TMUX_VERSION"
        CPPFLAGS="-I$deps_dir/include -I$deps_dir/include/ncursesw${CPPFLAGS:+ $CPPFLAGS}" \
            LDFLAGS="-L$deps_dir/lib -Wl,-rpath,$deps_dir/lib${LDFLAGS:+ $LDFLAGS}" \
            PKG_CONFIG_PATH="$deps_dir/lib/pkgconfig" \
            PKG_CONFIG_LIBDIR="$deps_dir/lib/pkgconfig" \
            ./configure --prefix="$tmux_dir"
        make -j"$jobs"
        make install
    )

    echo "$build_id" >"$tmux_dir/.build-id"
    cat >"$INSTALL_DIR/tmux" <<'EOF'
#!/bin/bash
if [ "$(uname -s)" = "Darwin" ]; then
    export DYLD_LIBRARY_PATH="$HOME/.local/opt/tmux-deps/lib${DYLD_LIBRARY_PATH:+:$DYLD_LIBRARY_PATH}"
else
    export LD_LIBRARY_PATH="$HOME/.local/opt/tmux-deps/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
fi
exec "$HOME/.local/opt/tmux/bin/tmux" "$@"
EOF
    chmod +x "$INSTALL_DIR/tmux"
    rm -rf "$tmp"
    echo "DONE: tmux $TMUX_VERSION -> $INSTALL_DIR/tmux"
}

install_mise
install_fzf
install_ripgrep
install_delta
install_lazygit
install_zoxide
install_glow
install_yazi
install_chafa
install_tmux
install_neovim
