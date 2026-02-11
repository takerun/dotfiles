#!/bin/zsh
set -ue

CURRENT_DIR=$(cd "$(dirname "$0")"; pwd)

echo "Setting iTerm2 preferences..."
ln -fs "${CURRENT_DIR}/com.googlecode.iterm2.plist" "${HOME}/Library/Preferences"
