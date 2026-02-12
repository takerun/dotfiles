#!/bin/zsh
set -eu

echo "Setting up Docker Compose as CLI plugin..."

# Get Homebrew prefix dynamically (Apple Silicon: /opt/homebrew, Intel: /usr/local)
if ! type brew &>/dev/null; then
  echo "Warning: Homebrew is not installed. Cannot set up docker-compose plugin." >&2
  exit 1
fi

readonly BREW_PREFIX="$(brew --prefix)"
readonly DOCKER_COMPOSE_SRC="${BREW_PREFIX}/bin/docker-compose"
readonly DOCKER_CLI_PLUGINS_DIR="${HOME}/.docker/cli-plugins"
readonly DOCKER_COMPOSE_PLUGIN="${DOCKER_CLI_PLUGINS_DIR}/docker-compose"

# Check if docker-compose is installed
if [[ ! -x "${DOCKER_COMPOSE_SRC}" ]]; then
  echo "Warning: docker-compose is not installed at ${DOCKER_COMPOSE_SRC}" >&2
  echo "Please run 'brew install docker-compose' first." >&2
  exit 1
fi

# Create CLI plugins directory if it doesn't exist
mkdir -p "${DOCKER_CLI_PLUGINS_DIR}"

# Check if symlink already exists and is valid
if [[ -L "${DOCKER_COMPOSE_PLUGIN}" ]]; then
  # Symlink exists - check if it's valid
  if [[ -e "${DOCKER_COMPOSE_PLUGIN}" ]]; then
    # Symlink is valid - check target
    readonly current_target="$(readlink "${DOCKER_COMPOSE_PLUGIN}")"
    if [[ "${current_target}" == "${DOCKER_COMPOSE_SRC}" ]]; then
      echo "Docker Compose CLI plugin is already configured correctly"
      exit 0
    else
      echo "Updating Docker Compose CLI plugin symlink..."
      rm "${DOCKER_COMPOSE_PLUGIN}"
    fi
  else
    # Symlink is broken
    echo "Removing broken Docker Compose CLI plugin symlink..."
    rm "${DOCKER_COMPOSE_PLUGIN}"
  fi
elif [[ -e "${DOCKER_COMPOSE_PLUGIN}" ]]; then
  # File exists but is not a symlink
  echo "Warning: ${DOCKER_COMPOSE_PLUGIN} exists but is not a symlink" >&2
  echo "Please remove it manually and re-run this script." >&2
  exit 1
fi

# Create symlink
echo "Creating Docker Compose CLI plugin symlink..."
ln -s "${DOCKER_COMPOSE_SRC}" "${DOCKER_COMPOSE_PLUGIN}"

echo "Docker Compose CLI plugin setup complete"
echo "You can now use: docker compose <command>"
