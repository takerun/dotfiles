#!/bin/zsh
set -eu

readonly CURRENT_DIR="$(cd "$(dirname "$0")"; pwd)"
readonly CONFIG_DIR="${HOME}/.config/ghostty"
readonly CONFIG_FILE="${CURRENT_DIR}/config"
readonly CONFIG_LINK="${CONFIG_DIR}/config"

echo "Setting up Ghostty configuration..."

# Create config directory
mkdir -p "${CONFIG_DIR}"

# Create symlink (overwrites if exists)
ln -sf "${CONFIG_FILE}" "${CONFIG_LINK}"

echo "Ghostty configuration linked to ${CONFIG_LINK}"
