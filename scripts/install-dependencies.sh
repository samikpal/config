#!/bin/bash

# Install Dependencies Script
# Installs all required dependencies for the development environment

set -e

OS="$1"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[DEPS]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[DEPS]${NC} $1"
}

print_error() {
    echo -e "${RED}[DEPS]${NC} $1"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

install_homebrew() {
    if ! command_exists brew; then
        print_status "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ $(uname -m) == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    else
        print_status "Homebrew already installed"
    fi
}

install_macos_deps() {
    print_status "Installing macOS dependencies..."
    
    install_homebrew
    
    # Update Homebrew
    brew update
    
    # Install essential tools
    local packages=(
        "git"
        "zsh"
        "tmux"
        "neovim"
        "curl"
        "wget"
        "tree"
        "ripgrep"
        "fd"
        "fzf"
        "bat"
        "eza"
        "node"
        "python@3.11"
        "pyenv"
    )
    
    for package in "${packages[@]}"; do
        if brew list "$package" &>/dev/null; then
            print_status "$package already installed"
        else
            print_status "Installing $package..."
            brew install "$package"
        fi
    done
    
    # Install fonts
    print_status "Installing Nerd Fonts..."
    brew install --cask font-meslo-lg-nerd-font font-fira-code-nerd-font
    
    # Install colorls via Ruby gem
    if ! command_exists colorls; then
        print_status "Installing colorls via Ruby gem..."
        gem install colorls
    else
        print_status "colorls already installed"
    fi

    print_success "macOS dependencies installed successfully"
}

install_linux_deps() {
    print_status "Installing Linux dependencies..."
    
    # Detect Linux distribution
    if command_exists apt-get; then
        PACKAGE_MANAGER="apt"
    elif command_exists yum; then
        PACKAGE_MANAGER="yum"
    elif command_exists pacman; then
        PACKAGE_MANAGER="pacman"
    else
        print_error "Unsupported Linux distribution"
        exit 1
    fi
    
    case $PACKAGE_MANAGER in
        "apt")
            sudo apt-get update
            sudo apt-get install -y \
                git \
                zsh \
                tmux \
                neovim \
                curl \
                wget \
                tree \
                ripgrep \
                fd-find \
                fzf \
                bat \
                nodejs \
                npm \
                python3 \
                python3-pip \
                build-essential
            ;;
        "yum")
            sudo yum update -y
            sudo yum install -y \
                git \
                zsh \
                tmux \
                neovim \
                curl \
                wget \
                tree \
                ripgrep \
                fd-find \
                fzf \
                bat \
                nodejs \
                npm \
                python3 \
                python3-pip \
                gcc \
                gcc-c++ \
                make
            ;;
        "pacman")
            sudo pacman -Syu --noconfirm
            sudo pacman -S --noconfirm \
                git \
                zsh \
                tmux \
                neovim \
                curl \
                wget \
                tree \
                ripgrep \
                fd \
                fzf \
                bat \
                nodejs \
                npm \
                python \
                python-pip \
                base-devel
            ;;
    esac
    
    # Install pyenv
    if ! command_exists pyenv; then
        print_status "Installing pyenv..."
        curl https://pyenv.run | bash
    fi
    
    # Install colorls (Ruby gem)
    if ! command_exists colorls; then
        print_status "Installing colorls..."
        if command_exists gem; then
            gem install colorls
        else
            print_status "Installing Ruby first..."
            case $PACKAGE_MANAGER in
                "apt") sudo apt-get install -y ruby-full ;;
                "yum") sudo yum install -y ruby ruby-devel ;;
                "pacman") sudo pacman -S --noconfirm ruby ;;
            esac
            gem install colorls
        fi
    fi
    
    print_success "Linux dependencies installed successfully"
}

# Main function
main() {
    print_status "Installing dependencies for $OS..."
    
    case $OS in
        "macos")
            install_macos_deps
            ;;
        "linux")
            install_linux_deps
            ;;
        *)
            print_error "Unsupported OS: $OS"
            exit 1
            ;;
    esac
    
    print_success "All dependencies installed successfully!"
}

main "$@"
