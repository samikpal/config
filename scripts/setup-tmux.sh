#!/bin/bash

# Tmux Setup Script
# Sets up tmux with custom configuration and plugins

set -e

SCRIPT_DIR="$1"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[TMUX]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[TMUX]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[TMUX]${NC} $1"
}

backup_file() {
    local file="$1"
    if [[ -f "$file" || -d "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        print_warning "Backing up existing $file to $backup"
        mv "$file" "$backup"
    fi
}

install_tpm() {
    local tpm_dir="$HOME/.tmux/plugins/tpm"
    
    if [[ ! -d "$tpm_dir" ]]; then
        print_status "Installing Tmux Plugin Manager (TPM)..."
        git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
    else
        print_status "TPM already installed"
        print_status "Updating TPM..."
        cd "$tpm_dir" && git pull
    fi
}

setup_tmux_config() {
    print_status "Setting up tmux configuration..."
    
    # Backup existing .tmux.conf
    backup_file "$HOME/.tmux.conf"
    
    # Copy new .tmux.conf
    cp "$SCRIPT_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
    
    print_success "Tmux configuration file copied"
}

install_tmux_plugins() {
    print_status "Installing tmux plugins..."
    
    # Create tmux plugins directory if it doesn't exist
    mkdir -p "$HOME/.tmux/plugins"
    
    # Install TPM first
    install_tpm
    
    # Install plugins automatically if tmux is available
    if command -v tmux >/dev/null 2>&1; then
        print_status "Installing tmux plugins via TPM..."
        
        # Start a detached tmux session and install plugins
        tmux new-session -d -s plugin_install
        tmux send-keys -t plugin_install "~/.tmux/plugins/tpm/scripts/install_plugins.sh" Enter
        sleep 5  # Wait for installation to complete
        tmux kill-session -t plugin_install 2>/dev/null || true
        
        print_success "Tmux plugins installed automatically"
    else
        print_warning "Tmux not found. Plugins will be installed when you first start tmux and press Ctrl+a + I"
    fi
}

create_tmux_scripts() {
    print_status "Creating tmux helper scripts..."
    
    # Create a script to easily install plugins
    cat > "$HOME/.tmux-install-plugins.sh" << 'EOF'
#!/bin/bash
# Script to install tmux plugins
echo "Installing tmux plugins..."
~/.tmux/plugins/tpm/scripts/install_plugins.sh
echo "Plugins installed! Restart tmux to see changes."
EOF
    
    chmod +x "$HOME/.tmux-install-plugins.sh"
    
    # Create a script to update plugins
    cat > "$HOME/.tmux-update-plugins.sh" << 'EOF'
#!/bin/bash
# Script to update tmux plugins
echo "Updating tmux plugins..."
~/.tmux/plugins/tpm/scripts/update_plugin.sh all
echo "Plugins updated!"
EOF
    
    chmod +x "$HOME/.tmux-update-plugins.sh"
    
    print_success "Tmux helper scripts created in home directory"
}

# Main function
main() {
    print_status "Setting up tmux environment..."
    
    # Setup configuration file
    setup_tmux_config
    
    # Install TPM and plugins
    install_tmux_plugins
    
    # Create helper scripts
    create_tmux_scripts
    
    print_success "Tmux setup completed!"
    echo ""
    print_status "Next steps:"
    echo "  1. Start tmux: tmux new-session"
    echo "  2. If plugins didn't install automatically, press: Ctrl+a + I"
    echo "  3. Use helper scripts:"
    echo "     - ~/.tmux-install-plugins.sh (install plugins)"
    echo "     - ~/.tmux-update-plugins.sh (update plugins)"
    echo ""
    print_status "Key bindings:"
    echo "  - Prefix: Ctrl+a (instead of Ctrl+b)"
    echo "  - Split vertically: Ctrl+a + |"
    echo "  - Split horizontally: Ctrl+a + -"
    echo "  - Navigate panes: Ctrl+h/j/k/l"
    echo "  - Reload config: Ctrl+a + r"
    echo "  - Maximize pane: Ctrl+a + m"
}

main "$@"
