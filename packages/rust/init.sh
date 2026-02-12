#!/bin/zsh
set -eu


if ! type rustup &>/dev/null; then
  echo "Installing Rust..."
  rustup-init -y --no-modify-path
fi
