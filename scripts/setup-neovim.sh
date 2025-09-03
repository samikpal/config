#!/bin/bash

# Neovim Setup Script
# Sets up Neovim with Lazy.nvim and all plugins

set -e

SCRIPT_DIR="$1"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[NVIM]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[NVIM]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[NVIM]${NC} $1"
}

backup_file() {
    local file="$1"
    if [[ -f "$file" || -d "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        print_warning "Backing up existing $file to $backup"
        mv "$file" "$backup"
    fi
}

setup_neovim_config() {
    print_status "Setting up Neovim configuration..."
    
    # Create .config directory if it doesn't exist
    mkdir -p "$HOME/.config"
    
    # Backup existing nvim config
    backup_file "$HOME/.config/nvim"
    
    # Copy new nvim configuration
    cp -r "$SCRIPT_DIR/nvim" "$HOME/.config/"
    
    print_success "Neovim configuration files copied"
}

install_lazy_nvim() {
    print_status "Installing Lazy.nvim plugin manager..."
    
    local lazy_path="$HOME/.local/share/nvim/lazy/lazy.nvim"
    
    if [[ ! -d "$lazy_path" ]]; then
        print_status "Cloning Lazy.nvim..."
        git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable "$lazy_path"
    else
        print_status "Lazy.nvim already installed"
    fi
}

install_language_servers() {
    print_status "Installing language servers and tools..."
    
    # Install Node.js packages for LSP servers
    if command -v npm >/dev/null 2>&1; then
        print_status "Installing Node.js language servers..."
        npm install -g \
            typescript-language-server \
            vscode-langservers-extracted \
            bash-language-server \
            yaml-language-server \
            dockerfile-language-server-nodejs
    else
        print_warning "npm not found. Some language servers may not be available."
    fi
    
    # Install Python packages
    if command -v pip3 >/dev/null 2>&1; then
        print_status "Installing Python language server..."
        pip3 install --user python-lsp-server[all] black isort flake8
    else
        print_warning "pip3 not found. Python language server may not be available."
    fi
}

setup_neovim_plugins() {
    print_status "Setting up Neovim plugins..."
    
    if command -v nvim >/dev/null 2>&1; then
        print_status "Installing plugins automatically..."
        
        # Run Neovim headlessly to install plugins
        nvim --headless "+Lazy! sync" +qa
        
        print_success "Neovim plugins installed automatically"
    else
        print_warning "Neovim not found. Plugins will be installed when you first open nvim."
    fi
}

create_neovim_scripts() {
    print_status "Creating Neovim helper scripts..."
    
    # Create a script to update plugins
    cat > "$HOME/.nvim-update-plugins.sh" << 'EOF'
#!/bin/bash
# Script to update Neovim plugins
echo "Updating Neovim plugins..."
nvim --headless "+Lazy! sync" +qa
echo "Plugins updated!"
EOF
    
    chmod +x "$HOME/.nvim-update-plugins.sh"
    
    # Create a script to clean unused plugins
    cat > "$HOME/.nvim-clean-plugins.sh" << 'EOF'
#!/bin/bash
# Script to clean unused Neovim plugins
echo "Cleaning unused Neovim plugins..."
nvim --headless "+Lazy! clean" +qa
echo "Cleanup completed!"
EOF
    
    chmod +x "$HOME/.nvim-clean-plugins.sh"
    
    print_success "Neovim helper scripts created in home directory"
}

# Main function
main() {
    print_status "Setting up Neovim environment..."
    
    # Setup configuration files
    setup_neovim_config
    
    # Install Lazy.nvim
    install_lazy_nvim
    
    # Install language servers
    install_language_servers
    
    # Setup plugins
    setup_neovim_plugins
    
    # Create helper scripts
    create_neovim_scripts
    
    print_success "Neovim setup completed!"
    echo ""
    print_status "Next steps:"
    echo "  1. Open Neovim: nvim"
    echo "  2. Plugins should install automatically on first run"
    echo "  3. Use helper scripts:"
    echo "     - ~/.nvim-update-plugins.sh (update plugins)"
    echo "     - ~/.nvim-clean-plugins.sh (clean unused plugins)"
    echo ""
    print_status "Key bindings (Leader key is Space):"
    echo "  - File explorer: Space + e"
    echo "  - Find files: Space + ff"
    echo "  - Find text: Space + fs"
    echo "  - Git status: Space + gs"
    echo "  - Split vertically: Space + sv"
    echo "  - Split horizontally: Space + sh"
    echo "  - New tab: Space + to"
    echo "  - Exit insert mode: jk"
}

main "$@"
