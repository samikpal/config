#!/bin/bash

# Test Setup Script
# Tests if all components are properly installed and configured

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

print_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

print_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

test_command() {
    local cmd="$1"
    local description="$2"
    
    if command_exists "$cmd"; then
        print_pass "$description"
        return 0
    else
        print_fail "$description"
        return 1
    fi
}

test_file() {
    local file="$1"
    local description="$2"
    
    if [[ -f "$file" ]]; then
        print_pass "$description"
        return 0
    else
        print_fail "$description"
        return 1
    fi
}

test_directory() {
    local dir="$1"
    local description="$2"
    
    if [[ -d "$dir" ]]; then
        print_pass "$description"
        return 0
    else
        print_fail "$description"
        return 1
    fi
}

main() {
    echo -e "${BLUE}=== Development Environment Test ===${NC}"
    echo "Testing installation and configuration..."
    echo ""
    
    local total_tests=0
    local passed_tests=0
    
    # Test essential commands
    print_test "Testing essential commands..."
    
    tests=(
        "git:Git version control"
        "zsh:Zsh shell"
        "tmux:Tmux terminal multiplexer"
        "nvim:Neovim editor"
        "curl:Curl download tool"
        "tree:Tree directory listing"
    )
    
    for test_item in "${tests[@]}"; do
        IFS=':' read -r cmd desc <<< "$test_item"
        total_tests=$((total_tests + 1))
        if test_command "$cmd" "$desc"; then
            passed_tests=$((passed_tests + 1))
        fi
    done
    
    echo ""
    print_test "Testing configuration files..."
    
    # Test configuration files
    config_tests=(
        "$HOME/.zshrc:Zsh configuration"
        "$HOME/.p10k.zsh:Powerlevel10k configuration"
        "$HOME/.tmux.conf:Tmux configuration"
        "$HOME/.gitconfig:Git configuration"
        "$HOME/.config/nvim/init.lua:Neovim configuration"
    )
    
    for test_item in "${config_tests[@]}"; do
        IFS=':' read -r file desc <<< "$test_item"
        total_tests=$((total_tests + 1))
        if test_file "$file" "$desc"; then
            passed_tests=$((passed_tests + 1))
        fi
    done
    
    echo ""
    print_test "Testing directories and installations..."
    
    # Test directories
    dir_tests=(
        "$HOME/.oh-my-zsh:Oh My Zsh installation"
        "$HOME/powerlevel10k:Powerlevel10k installation"
        "$HOME/.tmux/plugins/tpm:Tmux Plugin Manager"
        "$HOME/.config/nvim:Neovim configuration directory"
    )
    
    for test_item in "${dir_tests[@]}"; do
        IFS=':' read -r dir desc <<< "$test_item"
        total_tests=$((total_tests + 1))
        if test_directory "$dir" "$desc"; then
            passed_tests=$((passed_tests + 1))
        fi
    done
    
    echo ""
    print_test "Testing shell configuration..."
    
    # Test shell
    total_tests=$((total_tests + 1))
    if [[ "$SHELL" == *"zsh"* ]]; then
        print_pass "Zsh is default shell"
        passed_tests=$((passed_tests + 1))
    else
        print_warn "Zsh is not the default shell (may require terminal restart)"
    fi
    
    # Test git configuration
    total_tests=$((total_tests + 1))
    if git config --global user.name >/dev/null 2>&1 && git config --global user.email >/dev/null 2>&1; then
        print_pass "Git user configuration"
        passed_tests=$((passed_tests + 1))
    else
        print_warn "Git user configuration incomplete (run git config --global user.name/email)"
    fi
    
    echo ""
    echo -e "${BLUE}=== Test Results ===${NC}"
    echo "Passed: $passed_tests/$total_tests tests"
    
    if [[ $passed_tests -eq $total_tests ]]; then
        print_pass "All tests passed! Your development environment is ready."
        exit 0
    elif [[ $passed_tests -gt $((total_tests * 3 / 4)) ]]; then
        print_warn "Most tests passed. Check failed items above."
        exit 0
    else
        print_fail "Several tests failed. Please review the setup."
        exit 1
    fi
}

main "$@"
