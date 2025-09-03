#!/bin/bash

# Git Setup Script
# Sets up Git configuration and useful aliases

set -e

SCRIPT_DIR="$1"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[GIT]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[GIT]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[GIT]${NC} $1"
}

backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        print_warning "Backing up existing $file to $backup"
        mv "$file" "$backup"
    fi
}

setup_git_config() {
    print_status "Setting up Git configuration..."
    
    # Backup existing .gitconfig
    backup_file "$HOME/.gitconfig"
    
    # Copy new .gitconfig
    cp "$SCRIPT_DIR/git/.gitconfig" "$HOME/.gitconfig"
    
    print_success "Git configuration file copied"
}

setup_git_aliases() {
    print_status "Setting up Git aliases..."
    
    # Add useful Git aliases
    git config --global alias.st status
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.ci commit
    git config --global alias.unstage 'reset HEAD --'
    git config --global alias.last 'log -1 HEAD'
    git config --global alias.visual '!gitk'
    git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
    git config --global alias.tree "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all"
    git config --global alias.amend 'commit --amend --no-edit'
    git config --global alias.pushf 'push --force-with-lease'
    git config --global alias.undo 'reset --soft HEAD~1'
    
    print_success "Git aliases configured"
}

setup_git_settings() {
    print_status "Setting up Git global settings..."
    
    # Set up better defaults
    git config --global init.defaultBranch main
    git config --global pull.rebase false
    git config --global push.default simple
    git config --global core.autocrlf input
    git config --global core.editor nvim
    
    # Set up diff and merge tools
    git config --global diff.tool vimdiff
    git config --global merge.tool vimdiff
    git config --global difftool.prompt false
    
    # Set up colors
    git config --global color.ui auto
    git config --global color.branch auto
    git config --global color.diff auto
    git config --global color.status auto
    
    # Set up helpful settings
    git config --global help.autocorrect 1
    git config --global rerere.enabled true
    
    print_success "Git global settings configured"
}

prompt_user_info() {
    print_status "Checking Git user configuration..."
    
    local current_name=$(git config --global user.name 2>/dev/null || echo "")
    local current_email=$(git config --global user.email 2>/dev/null || echo "")
    
    if [[ -z "$current_name" || -z "$current_email" ]]; then
        print_warning "Git user information not configured or incomplete"
        echo ""
        echo "Current configuration:"
        echo "  Name: ${current_name:-'(not set)'}"
        echo "  Email: ${current_email:-'(not set)'}"
        echo ""
        echo "You can configure your Git user information later by running:"
        echo "  git config --global user.name \"Your Name\""
        echo "  git config --global user.email \"your.email@example.com\""
    else
        print_success "Git user information already configured:"
        echo "  Name: $current_name"
        echo "  Email: $current_email"
    fi
}

create_git_scripts() {
    print_status "Creating Git helper scripts..."
    
    # Create a script for common Git operations
    cat > "$HOME/.git-helpers.sh" << 'EOF'
#!/bin/bash
# Git helper functions

# Quick commit with message
qcommit() {
    if [[ -z "$1" ]]; then
        echo "Usage: qcommit \"commit message\""
        return 1
    fi
    git add -A && git commit -m "$1"
}

# Quick push to current branch
qpush() {
    local branch=$(git branch --show-current)
    git push origin "$branch"
}

# Create and switch to new branch
newbranch() {
    if [[ -z "$1" ]]; then
        echo "Usage: newbranch branch-name"
        return 1
    fi
    git checkout -b "$1"
}

# Delete local and remote branch
delbranch() {
    if [[ -z "$1" ]]; then
        echo "Usage: delbranch branch-name"
        return 1
    fi
    git branch -d "$1"
    git push origin --delete "$1"
}

# Show Git status with a nice format
gstatus() {
    echo "=== Git Status ==="
    git status --short --branch
    echo ""
    echo "=== Recent Commits ==="
    git log --oneline -5
}

# Export functions
export -f qcommit qpush newbranch delbranch gstatus
EOF
    
    chmod +x "$HOME/.git-helpers.sh"
    
    # Add to shell configuration
    if [[ -f "$HOME/.zshrc" ]]; then
        if ! grep -q ".git-helpers.sh" "$HOME/.zshrc"; then
            echo "" >> "$HOME/.zshrc"
            echo "# Git helper functions" >> "$HOME/.zshrc"
            echo "source ~/.git-helpers.sh" >> "$HOME/.zshrc"
        fi
    fi
    
    print_success "Git helper scripts created and added to shell configuration"
}

# Main function
main() {
    print_status "Setting up Git environment..."
    
    # Setup configuration file
    setup_git_config
    
    # Setup aliases
    setup_git_aliases
    
    # Setup global settings
    setup_git_settings
    
    # Check user information
    prompt_user_info
    
    # Create helper scripts
    create_git_scripts
    
    print_success "Git setup completed!"
    echo ""
    print_status "Useful Git aliases added:"
    echo "  git st       - status"
    echo "  git co       - checkout"
    echo "  git br       - branch"
    echo "  git ci       - commit"
    echo "  git lg       - pretty log"
    echo "  git tree     - branch tree"
    echo "  git amend    - amend last commit"
    echo "  git undo     - undo last commit"
    echo ""
    print_status "Helper functions available (after restarting shell):"
    echo "  qcommit \"message\"  - quick add and commit"
    echo "  qpush              - quick push to current branch"
    echo "  newbranch name     - create and switch to new branch"
    echo "  delbranch name     - delete local and remote branch"
    echo "  gstatus            - enhanced status display"
}

main "$@"
