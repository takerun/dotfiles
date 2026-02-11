# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a macOS dotfiles repository that automates the setup of development environments and system preferences. The architecture follows a modular pattern with a main setup script that orchestrates dotfile installation and package-specific initialization.

## Architecture

### Core Components

- **setup.sh**: Main orchestration script that runs in this order:
  1. Installs Xcode Command Line Tools (with interactive GUI wait loop)
  2. Installs Homebrew if not present
  3. Runs `brew bundle` to install packages from Brewfile
  4. Symlinks all files from `dotfile/` (excluding .DS_Store) to `$HOME/`
  5. Creates `~/.local/completion` directory
  6. Executes all `init.sh` scripts found in `package/` subdirectories

- **dotfile/**: Contains configuration files that get symlinked to home directory
  - .zshrc: Shell configuration with git prompt, volta, Rust paths, and completion setup
  - .vimrc: Vim editor configuration
  - .gitconfig: Git configuration

- **package/**: Modular initialization system
  - Each subdirectory represents a tool/package (iTerm2, volta, rust)
  - Optional `init.sh` in each subdirectory runs during setup
  - Used for tool-specific setup tasks that can't be handled by symlinks alone

- **Brewfile**: Defines Homebrew packages and casks to install
  - CLI tools: zsh-completions, zsh-autosuggestions, wget, tree, git, uv, volta, rustup-init
  - Applications: iTerm2, Claude Code, VS Code, Chrome, Google Drive, Discord, Clipy

- **doc/**: Documentation and guidelines
  - SHELL_STYLE_GUIDE.md: Comprehensive Zsh scripting coding standards
  - TODO.md: Implementation progress tracking for major changes

### Design Pattern

The package system allows modular additions: to add a new tool, create `package/toolname/init.sh` and it will automatically run during setup. Each package's init script should be idempotent (safe to run multiple times).

## Common Commands

### Initial Setup
```zsh
# From a fresh macOS installation
mv Downloads/dotfiles-master ~/dotfiles
zsh dotfiles/setup.sh
# Reboot computer, then verify iTerm2 preferences loaded
defaults read com.googlecode.iterm2
```

### Managing Dotfiles
```zsh
# After modifying files in dotfile/, symlinks update automatically
# No need to re-run setup.sh for dotfile changes

# To add a new dotfile:
# 1. Add the file to dotfile/ directory
# 2. Run setup.sh to create the symlink
```

### Homebrew Package Management
```zsh
# Update Brewfile after installing new packages
brew bundle dump --file=Brewfile --force

# Clean up and reinstall from Brewfile
brew bundle cleanup -v --file=Brewfile --force
brew bundle -v --file=Brewfile

# Update Brewfile.lock.json
brew bundle --file=Brewfile
```

### Testing
```zsh
# Test setup script changes in a clean environment
# (Recommended: use a VM or test macOS installation)
# The script is idempotent and safe to re-run
zsh setup.sh

# Syntax check for shell scripts
zsh -n setup.sh
zsh -n package/*/init.sh

# Test .zshrc loading
zsh -c "source dotfile/.zshrc && echo 'Load successful'"
```

## Coding Standards

All shell scripts in this repository follow the Zsh coding standards defined in [doc/SHELL_STYLE_GUIDE.md](doc/SHELL_STYLE_GUIDE.md).

### Key Rules

1. **Error Handling**: All executable scripts use `set -eu` (not `set -ue`)
2. **Variable Expansion**: Always use `"${var}"` format for consistency and safety
3. **Quoting**: Quote all variable expansions to prevent word splitting
4. **Performance**: Cache expensive command results (e.g., `brew --prefix`)
5. **Conditionals**: Use `[[ ]]` for tests (Zsh-native)
6. **Functions**: Use lowercase with underscores; declare local variables with `local`

### Examples

```zsh
# Good
export CARGO_HOME="${HOME}/.cargo"
if [[ -f "${file}" ]]; then
  echo "File exists: ${file}"
fi

# Bad
export CARGO_HOME=$HOME/.cargo
if [ -f $file ]; then
  echo "File exists: $file"
fi
```

### Before Committing

- Run syntax checks: `zsh -n <script>`
- Verify variable quoting with `"${var}"` format
- Check that functions use `local` for variables
- Ensure `set -eu` is present in executable scripts

## Key Behaviors

- **Symlink Strategy**: Dotfiles use symlinks rather than copies, so changes to files in `dotfile/` immediately affect the system without re-running setup
- **Package Init Scripts**: Must be executable and use `#!/bin/zsh` shebang. Use `set -eu` for error handling (standardized across all init scripts)
- **Setup Script Error Handling**: Uses `set -eu` to exit on errors. Xcode installation includes a blocking wait loop until GUI installation completes
- **Path Precedence**: .zshrc sets up paths in this order: Cargo/Rust bins, Homebrew paths, then system defaults
- **Performance Optimization**: .zshrc caches `brew --prefix` result (reduces 6 calls to 1, saving ~0.5-1s on shell startup)
