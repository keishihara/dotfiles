#!/bin/bash

function __exists() { type "$1" >/dev/null 2>&1; return $?; }


# Xcode
# Check if command line tools are installed
if ! xcode-select --print-path &> /dev/null; then
    # Install command line tools
    echo "Command line tools not found. Installing..."
    xcode-select --install
else
    echo "Command line tools are already installed."
fi


# Homebrew
if ! __exists brew ; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed."
fi


# Open App Store and login with your Apple ID
function open_app_store {
  echo "Please login with your Apple ID"
  sleep 1; echo "Open the App Store."
  sleep 1; open -a App\ Store
}

function login_check {
  while true; do
    echo -n "$* [Y/n]: (default: n) "
    read ANS
    case $ANS in
      [Yy]*)
        return 0
        ;;
      *)
        open_app_store
        ;;
    esac
  done
}

open_app_store

if login_check "Did you login?"; then
    echo "Logged in!"
    brew bundle --global
fi
