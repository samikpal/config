#!/bin/bash

# Development Environment Setup Script
# This script sets up a complete development environment with zsh, tmux, neovim, and git configurations

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging
LOG_FILE="$HOME/.config-setup.log"
exec 1> >(tee -a "$LOG_FILE")
exec 2> >(tee -a "$LOG_FILE" >&2)

echo -e "${BLUE}=== Development Environment Setup ===${NC}"
echo "Log file: $LOG_FILE"
echo "Started at: $(date)"
echo ""

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to print status messages
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to backup existing files
backup_file() {
    local file="$1"
    if [[ -f "$file" || -d "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        print_warning "Backing up existing $file to $backup"
        mv "$file" "$backup"
    fi
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
    else
        print_error "Unsupported operating system: $OSTYPE"
        exit 1
    fi
    print_status "Detected OS: $OS"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root"
        exit 1
    fi
}

# Main setup function
main() {
    print_status "Starting development environment setup..."
    
    check_root
    detect_os
    
    # Make all scripts executable
    chmod +x "$SCRIPT_DIR"/scripts/*.sh
    
    # Run setup scripts in order
    print_status "Installing dependencies..."
    "$SCRIPT_DIR/scripts/install-dependencies.sh" "$OS"
    
    print_status "Setting up shell configuration..."
    "$SCRIPT_DIR/scripts/setup-shell.sh" "$SCRIPT_DIR"
    
    print_status "Setting up tmux configuration..."
    "$SCRIPT_DIR/scripts/setup-tmux.sh" "$SCRIPT_DIR"
    
    print_status "Setting up neovim configuration..."
    "$SCRIPT_DIR/scripts/setup-neovim.sh" "$SCRIPT_DIR"
    
    print_status "Setting up git configuration..."
    "$SCRIPT_DIR/scripts/setup-git.sh" "$SCRIPT_DIR"
    
    print_success "Setup completed successfully!"
    echo ""
    echo -e "${GREEN}=== Next Steps ===${NC}"
    echo "1. For Neslo Fonts to take effect, change your terminal font to Meslo LG Nerd Font"
    echo "2. Restart your terminal or run: source ~/.zshrc"
    echo "3. Open tmux and install plugins: tmux new-session, then Ctrl+a + I"
    echo "4. Open neovim - plugins will install automatically"
    echo "5. Configure git with your personal details if needed"
    echo ""
    echo -e "${YELLOW}Note: Some changes may require a terminal restart to take effect.${NC}"
}

# Run main function
main "$@"
