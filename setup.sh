#!/bin/zsh
set -eu

# --- Colors ---
# 太字(Bold)などの装飾を組み合わせると視認性が上がります
BOLD_GREEN='\033[1;32m'
BOLD_YELLOW='\033[1;33m'
BOLD_CYAN='\033[1;36m'
NC='\033[0m' # No Color (リセット用)

# env
CURRENT_DIR=$(cd "$(dirname "$0")"; pwd)

# --- Xcode Command Line Tools ---
# upgrade command: sudo rm -rf /Library/Developer/CommandLineTools
echo "Checking Xcode Command Line Tools..."
if ! xcode-select -p &> /dev/null; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install

    # Wait until the installation is complete (Required)
    echo "${BOLD_YELLOW}--------------------------------------------------------"
    echo "  ATTENTION: A software update window has opened."
    echo "  Please click 'Install' on that screen to proceed."
    echo "--------------------------------------------------------${NC}"
    
    # Loop and wait until the tools become available
    # Using a subtle dot animation to keep the focus on the GUI instructions
    while ! xcode-select -p &> /dev/null; do
        for i in {1..3}; do
            printf "\rWaiting for GUI instructions to complete$(printf '%.0s.' $(seq 1 $i))   "
            sleep 1
            # Re-check inside the inner loop for faster exit
            if xcode-select -p &> /dev/null; then break 2; fi
        done
        printf "\rWaiting for GUI instructions to complete" # Clear dots
    done
    
    printf "\r${BOLD_GREEN}[+] Xcode Command Line Tools installed successfully.${NC}\n"
else
    echo "Xcode Command Line Tools are already installed."
fi

# --- Homebrew ---
if ! type brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# --- Brewfile ---
if [[ -f "${CURRENT_DIR}/Brewfile" ]]; then
  echo "Installing Homebrew packages..."
  brew bundle cleanup -v --file="${CURRENT_DIR}/Brewfile" --force
  brew bundle -v --file="${CURRENT_DIR}/Brewfile"
else
    echo "Warning: Brewfile not found at ${CURRENT_DIR}/Brewfile"
fi

# --- Symbolic linking for dotfiles ---
echo "Creating symbolic links..."
if [[ -d "${CURRENT_DIR}/dotfile" ]]; then
    find "${CURRENT_DIR}/dotfile" -maxdepth 1 -type f -name ".*" | while read -r f; do
        [[ "${f:t}" == ".DS_Store" ]] && continue
        echo "Linking: ${f:t}"
        ln -sf "$f" "${HOME}/"
    done
fi

# --- Setup Directories ---
mkdir -p "${HOME}/.local/completion"

# --- Run package-specific init scripts ---
for f in $(find "${CURRENT_DIR}/package" -type f -name "init.sh" 2>/dev/null); do
    echo "Running init: $f"
    zsh "$f"
done

# --- Finalize ---
echo "--------------------------------------------------------"
echo "  Setup complete!"
echo "  Please restart your terminal or run: ${BOLD_CYAN}source ~/.zshrc${NC}"
echo "--------------------------------------------------------"