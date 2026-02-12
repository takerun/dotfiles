#!/bin/zsh
set -eu

if type volta &>/dev/null; then
  echo "Setting up Volta..."

  # Install latest LTS Node.js by default if no Node version exists
  if ! volta list all | grep -q "node@"; then
    echo "Installing Node.js LTS..."
    volta install node
  else
    echo "Node.js already installed via Volta"
  fi
else
  echo "Warning: volta is not installed" >&2
fi
