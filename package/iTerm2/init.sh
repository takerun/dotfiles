#!/bin/zsh
set -ue

CURRENT_DIR=$(cd "$(dirname "$0")"; pwd)

ln -fs "$CURRENT_DIR/com.googlecode.iterm2.plist" $HOME/Library/Preferences
defaults read com.googlecode.iterm2
