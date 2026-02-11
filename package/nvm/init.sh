#!/bin/zsh
set -eu

if [[ ! -d "${HOME}/.nvm" ]]; then
    echo "Setting NVM preferences..."
    mkdir "${HOME}/.nvm"
fi
