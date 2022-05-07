function detect_shell() { echo ${SHELL##*/}; }
function echo_header() { printf "\033[37;1m%s\033[m\n" "$*"; }
function is_exists() { type "$1" >/dev/null 2>&1; return $?; }
function _unlink() { unlink "$1" >/dev/null 2>&1; return $?; }
function _mv() { mv "$1" >/dev/null 2>&1; return $?; }
function _mkdir() { mkdir "$1" >/dev/null 2>&1; return $?; }