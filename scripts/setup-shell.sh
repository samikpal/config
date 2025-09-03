#!/bin/bash

# Shell Setup Script
# Sets up Zsh with Oh My Zsh and Powerlevel10k theme

set -e

SCRIPT_DIR="$1"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[SHELL]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SHELL]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[SHELL]${NC} $1"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

backup_file() {
    local file="$1"
    if [[ -f "$file" || -d "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        print_warning "Backing up existing $file to $backup"
        mv "$file" "$backup"
    fi
}

install_oh_my_zsh() {
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        print_status "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        print_status "Oh My Zsh already installed"
    fi
}

install_zsh_plugins() {
    local zsh_custom="$HOME/.oh-my-zsh/custom"
    
    # Install zsh-syntax-highlighting
    if [[ ! -d "$zsh_custom/plugins/zsh-syntax-highlighting" ]]; then
        print_status "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$zsh_custom/plugins/zsh-syntax-highlighting"
    else
        print_status "zsh-syntax-highlighting already installed"
    fi
    
    # Install zsh-autosuggestions
    if [[ ! -d "$zsh_custom/plugins/zsh-autosuggestions" ]]; then
        print_status "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$zsh_custom/plugins/zsh-autosuggestions"
    else
        print_status "zsh-autosuggestions already installed"
    fi
}

install_powerlevel10k() {
    local p10k_dir="$HOME/powerlevel10k"
    
    if [[ ! -d "$p10k_dir" ]]; then
        print_status "Installing Powerlevel10k..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
    else
        print_status "Powerlevel10k already installed"
        print_status "Updating Powerlevel10k..."
        cd "$p10k_dir" && git pull
    fi
}

setup_zsh_config() {
    print_status "Setting up Zsh configuration..."
    
    # Backup existing .zshrc
    backup_file "$HOME/.zshrc"
    
    # Copy new .zshrc
    cp "$SCRIPT_DIR/shell/.zshrc" "$HOME/.zshrc"
    
    # Copy Powerlevel10k configuration
    backup_file "$HOME/.p10k.zsh"
    cp "$SCRIPT_DIR/shell/.p10k.zsh" "$HOME/.p10k.zsh"
    
    print_success "Zsh configuration files copied"
}

set_default_shell() {
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        print_status "Setting Zsh as default shell..."
        
        # Add zsh to /etc/shells if not already there
        if ! grep -q "$(which zsh)" /etc/shells; then
            echo "$(which zsh)" | sudo tee -a /etc/shells
        fi
        
        # Change default shell
        chsh -s "$(which zsh)"
        print_success "Default shell changed to Zsh (restart terminal to take effect)"
    else
        print_status "Zsh is already the default shell"
    fi
}

# Main function
main() {
    print_status "Setting up shell environment..."
    
    # Install Oh My Zsh
    install_oh_my_zsh
    
    # Install Zsh plugins
    install_zsh_plugins
    
    # Install Powerlevel10k theme
    install_powerlevel10k
    
    # Setup configuration files
    setup_zsh_config
    
    # Set Zsh as default shell
    set_default_shell
    
    print_success "Shell setup completed!"
    print_status "Please restart your terminal or run 'source ~/.zshrc' to apply changes"
}

main "$@"
