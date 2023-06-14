#!/bin/zsh
set -eu


# env
CURRENT_DIR=$(cd "$(dirname "$0")"; pwd)

# xcode-select
if ! xcode-select -p 1>/dev/null; then
  echo "Installing xcode-select"
  xcode-select --install
fi

# Homebrew
if ! type brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Brewfile
echo "Installing some software & library..."
brew bundle cleanup -v --file=${CURRENT_DIR}/Brewfile --force
brew bundle -v --file=${CURRENT_DIR}/Brewfile

# symbolic linking for dotfiles
for f in $(find ${CURRENT_DIR}/dotfile -maxdepth 1 -type f -name ".*"); do
  [[ $f == *".DS_Store" ]] && continue
  echo "Making symbolic link: $f"
  ln -sf "$f" $HOME/
done

# completion directory
mkdir -p $HOME/.local/completion

# restarting zsh
source $HOME/.zshrc

# package or config installed manually
for f in $(find ${CURRENT_DIR}/package -name "init.sh"); do
  zsh "$f"
done
