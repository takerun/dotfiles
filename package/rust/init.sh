#!/bin/zsh
set -ue


if ! type rustup &>/dev/null; then
  rustup-init -y --no-modify-path
fi
