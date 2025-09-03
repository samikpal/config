# Development Environment Configuration

This repository contains all the configuration files and setup scripts for replicating my development environment on a new machine.

## What's Included

- **Shell Configuration**: Zsh with Oh My Zsh, Powerlevel10k theme, and useful plugins
- **Terminal Multiplexer**: Tmux with custom key bindings and plugins
- **Text Editor**: Neovim with Lazy.nvim and comprehensive plugin setup
- **Git Configuration**: User settings and aliases
- **Automated Setup**: One-command installation script

## Quick Setup

Run this command on a new machine to set up everything:

```bash
curl -fsSL https://raw.githubusercontent.com/samikpal/config/main/setup.sh | bash
```

Or clone and run manually:

```bash
git clone https://github.com/samikpal/config.git
cd config
chmod +x setup.sh
./setup.sh
```

## Manual Installation

If you prefer to install components individually:

1. **Install dependencies**: `./scripts/install-dependencies.sh`
2. **Setup shell**: `./scripts/setup-shell.sh`
3. **Setup tmux**: `./scripts/setup-tmux.sh`
4. **Setup neovim**: `./scripts/setup-neovim.sh`
5. **Setup git**: `./scripts/setup-git.sh`

## Directory Structure

```
config/
├── README.md
├── setup.sh                 # Main setup script
├── scripts/                 # Individual setup scripts
│   ├── install-dependencies.sh
│   ├── setup-shell.sh
│   ├── setup-tmux.sh
│   ├── setup-neovim.sh
│   └── setup-git.sh
├── shell/                   # Shell configuration
│   ├── .zshrc
│   └── .p10k.zsh
├── tmux/                    # Tmux configuration
│   └── .tmux.conf
├── nvim/                    # Neovim configuration
│   └── (complete .config/nvim structure)
└── git/                     # Git configuration
    └── .gitconfig
```

## Features

### Shell (Zsh + Oh My Zsh + Powerlevel10k)
- Beautiful and informative prompt
- Syntax highlighting
- Auto-suggestions
- Git integration
- Python environment detection

### Tmux
- Custom prefix key (Ctrl+a)
- Vim-style pane navigation
- Session persistence
- Beautiful theme
- Plugin management with TPM

### Neovim
- Modern Lua configuration
- Lazy.nvim plugin manager
- LSP support with Mason
- File explorer with nvim-tree
- Fuzzy finder with Telescope
- Git integration
- Auto-completion
- Syntax highlighting with Treesitter

### Git
- User configuration
- Useful aliases
- Better diff and merge tools

## Customization

Feel free to modify any configuration files to suit your preferences. The setup script will backup any existing configurations before applying new ones.

## Troubleshooting

If you encounter any issues:

1. Check the logs in `~/.config-setup.log`
2. Ensure you have the necessary permissions
3. Run individual setup scripts to isolate issues
4. Check that all dependencies are properly installed

## Requirements

- macOS or Linux
- Internet connection for downloading dependencies
- Sudo access for system-wide installations

## License

MIT License - feel free to use and modify as needed.
