#!/bin/sh

# Bootstrap script for dotfiles setup on fresh macOS
# Installs Rust -> Rotz -> Homebrew -> Fish shell
# Should be idempotent and safe to run multiple times

set -eu # Exit on error, undefined vars (pipefail not POSIX)

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() { printf "${GREEN}[INFO]${NC} %s\n" "$1"; }
log_warn() { printf "${YELLOW}[WARN]${NC} %s\n" "$1"; }
log_error() { printf "${RED}[ERROR]${NC} %s\n" "$1"; }

# Generic function to check if command exists and install if missing
install_if_missing() {
  cmd="$1"
  install_cmd="$2"
  description="$3"

  if command -v "$cmd" >/dev/null 2>&1; then
    log_info "$description already installed"
    return 0
  fi

  log_info "Installing $description..."
  if eval "$install_cmd"; then
    log_info "$description installed successfully"
  else
    log_error "Failed to install $description"
    return 1
  fi
}

# Set up Rust environment in current shell session
setup_rust_env() {
  # Check if cargo is already available
  if command -v cargo >/dev/null 2>&1; then
    return 0
  fi

  log_info "Setting up Rust environment..."

  # Try to source the Rust environment script directly
  if [ -f "$HOME/.cargo/env" ]; then
    # shellcheck disable=SC1091
    . "$HOME/.cargo/env"
    return 0
  fi

  # Fall back to shell profiles that might contain Rust setup
  for profile in "$HOME/.zshrc" "$HOME/.bash_profile" "$HOME/.profile"; do
    if [ -f "$profile" ]; then
      # shellcheck disable=SC1090
      . "$profile" 2>/dev/null
      if command -v cargo >/dev/null 2>&1; then
        return 0
      fi
    fi
  done

  # Still no Rust? That sucks
  log_error "Could not set up Rust environment"
  log_error "Try one of these solutions:"
  log_error "  1. Restart your terminal"
  log_error "  2. Run: source ~/.cargo/env"
  log_error "  3. Run: export PATH=\"\$HOME/.cargo/bin:\$PATH\""
  exit 1
}

# Set up Homebrew environment in current shell session
setup_brew_env() {
  # Check if brew is already available
  if command -v brew >/dev/null 2>&1; then
    return 0
  fi

  log_info "Setting up Homebrew environment..."

  # Try known Homebrew install locations and evaluate shellenv
  # Apple Silicon Mac
  if [ -x "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    return 0
  fi

  # Intel Mac
  if [ -x "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
    return 0
  fi

  # Linux (Homebrew on Linux)
  if [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    return 0
  fi

  # Fall back to shell profiles that might contain Homebrew setup
  for profile in "$HOME/.zprofile" "$HOME/.bash_profile" "$HOME/.profile"; do
    if [ -f "$profile" ]; then
      # shellcheck disable=SC1090
      . "$profile" 2>/dev/null
      if command -v brew >/dev/null 2>&1; then
        return 0
      fi
    fi
  done

  # Still no Homebrew? That sucks
  log_error "Could not set up Homebrew environment"
  log_error "Try one of these solutions:"
  log_error "  1. Restart your terminal"
  log_error "  2. Run: eval \"\$(brew shellenv)\""
  log_error "  3. Check that Homebrew installed correctly"
  exit 1
}

main() {
  log_info "Starting dotfiles bootstrap..."

  # Install Rust toolchain (required for Rotz)
  install_if_missing "cargo" \
    "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y" \
    "Rust toolchain"

  # Make Rust available
  setup_rust_env

  # Install Rotz (dotfiles manager)
  install_if_missing "rotz" \
    "cargo install rotz" \
    "Rotz"

  # Install Homebrew (package manager)
  install_if_missing "brew" \
    "curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash" \
    "Homebrew"

  # Make Homebrew available
  setup_brew_env

  # Install Fish shell (for consistent syntax in dotfiles)
  install_if_missing "fish" \
    "brew install fish" \
    "Fish shell"

  log_info "Bootstrap complete - yay!"
  log_info "You can now run \`rotz link\` and \`rotz install\` to set up your dotfiles."
  log_info "You may need to restart your terminal or run \`fish\` to start using the Fish shell."
  log_info "To make Fish your default shell: \`chsh -s \$(which fish)\` (requires restart)"
}

# Run main function
main "$@"
