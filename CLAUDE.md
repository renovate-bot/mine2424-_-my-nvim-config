# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a comprehensive Flutter development environment configuration for Neovim, designed for professional Flutter development with full IDE-like features. The configuration includes:

- **Main Configuration**: `lua/flutter-dev-with-dap.lua` - Full-featured Flutter dev environment with DAP debugging
- **Alternative**: `lua/plugins.lua` - Lightweight configuration (reference only)
- **Core Files**: `init.lua`, `lua/base.lua`, `lua/maps.lua`, `lua/ide-layout.lua`
- **Zsh Configuration**: Modern shell setup based on wasabeef/dotfiles with plugins and aliases
- **Terminal Integration**: Ghostty terminal with modern configuration
- **Shell Enhancement**: Starship prompt with Flutter-specific features
- **Safety Configuration**: Claude Desktop with prohibited command blocking

## Key Architecture

### Configuration Loading Order
1. `init.lua` - Entry point that loads all modules
2. `lua/base.lua` - Basic Vim settings and autocommands  
3. `lua/maps.lua` - Keybinding definitions
4. `lua/plugins.lua` - Plugin management (currently inactive)
5. `lua/ide-layout.lua` - IDE-style layout setup
6. `lua/flutter-dev-with-dap.lua` - Main Flutter development configuration with full plugin ecosystem

### Plugin Management
- Uses **lazy.nvim** as the plugin manager
- All plugins are configured in `lua/flutter-dev-with-dap.lua`
- Plugin auto-installation on first run
- Lazy-loading for performance optimization

### Core Plugin Stack
- **Flutter Tools**: `akinsho/flutter-tools.nvim` for Flutter development
- **LSP**: Mason + lspconfig for language servers (Dart, TypeScript, etc.)
- **Git Integration**: `lewis6991/gitsigns.nvim` with extensive hunk management
- **AI Assistance**: `zbirenbaum/copilot.lua` with cmp integration
- **Debugging**: nvim-dap with Flutter DAP support
- **UI**: lualine, bufferline, nvim-tree, telescope
- **Code Quality**: hlchunk.nvim for visual code structure

## Development Commands

### Setup and Installation
```bash
# Full automated setup
./scripts/setup.sh

# Manual verification
./scripts/verify-setup.sh

# Flutter project creation
./scripts/create-flutter-project.sh <project-name>
```

### Flutter Development Workflow
- **Device Management**: `<leader>fd` (list devices), `<leader>fe` (start emulator)
- **Flutter Commands**: `<leader>fr` (run), `<leader>fh` (hot reload), `<leader>fq` (quit)
- **Debugging**: `<F5>` (start debug), `<F10>` (step over), `<F11>` (step into)
- **LSP Actions**: `<leader>ca` (code actions), `<leader>rn` (rename), `gd` (go to definition)

### Git Operations (gitsigns.nvim)
- **Hunk Navigation**: `]c` (next hunk), `[c` (previous hunk)
- **Hunk Actions**: `<leader>hs` (stage), `<leader>hr` (reset), `<leader>hp` (preview)
- **Blame**: `<leader>hb` (line blame), `<leader>tb` (toggle blame display)

### GitHub Copilot Integration
- **Suggestions**: `Alt+l` (accept), `Alt+]`/`Alt+[` (navigate)
- **Management**: `<leader>cc` (Copilot chat), `<leader>C*` commands for control

## Important File Patterns

### Configuration Files
- `*.lua` files in `lua/` directory are the main configuration
- `init.lua` is the entry point
- `zsh/zshrc` is the main Zsh shell configuration
- `zsh/sheldon/plugins.toml` defines Zsh plugins managed by sheldon
- `ghostty/config` and `starship.toml` are terminal/prompt configurations
- `claude/claude_desktop_config.json` is Claude Desktop safety configuration

### Flutter Development
- Flutter projects should be opened at the project root (where `pubspec.yaml` exists)
- The configuration automatically detects Flutter projects and enables appropriate LSP servers
- VSCode launch.json files are automatically read and integrated

### Documentation Structure
- `*.md` files contain comprehensive guides for different aspects
- `FLUTTER_KEYBINDINGS.md` contains complete keymap reference
- `TROUBLESHOOTING.md` has common issues and solutions

## Testing and Verification

No specific test framework is used for this configuration. Verification is done through:
- Running `./scripts/verify-setup.sh` to check all dependencies
- Opening a Flutter project and testing LSP functionality
- Verifying plugin loading with `:Lazy` command in Neovim

## Shell and Terminal Integration

### Zsh Configuration
The configuration includes a modern Zsh setup based on wasabeef/dotfiles:

#### Shell Features
- **Plugin Manager**: Sheldon for fast plugin management
- **Modern Tools**: Replacements for classic Unix commands (eza→ls, bat→cat, etc.)
- **Smart Aliases**: Comprehensive shortcuts for Git, Flutter, and development workflows
- **Auto-suggestions**: Fish-like autosuggestions and syntax highlighting
- **FZF Integration**: Fuzzy finding for files, history, and commands

#### Sheldon Plugin Configuration
- Configuration file: `zsh/sheldon/plugins.toml`
- Plugins are automatically installed and managed by sheldon
- Syntax highlighting is loaded without deferring for compatibility
- Run `sheldon lock` to regenerate the lock file after changes

#### Development Tools Management
- **mise**: Modern runtime version manager (replaces asdf)
- Automatically manages Flutter, Ruby, Node.js, and other development tools
- Configuration: `mise settings set idiomatic_version_file_enable_tools ruby` to enable version file support

#### Key Aliases
- `ll`, `la`, `lt`: Enhanced directory listings with icons
- `g`, `gs`, `ga`, `gc`: Git shortcuts
- `fl`, `flr`, `flb`: Flutter command shortcuts
- `lg`: Launch lazygit
- `?`, `??`: GitHub Copilot CLI helpers

### Ghostty Terminal Configuration
- **Theme**: Ayu color scheme for comfortable viewing
- **Font**: JetBrainsMonoNL Nerd Font Mono with optimized settings
- **Transparency**: Background opacity at 0.85 with blur for modern aesthetics
- **Window Padding**: Balanced padding for clean appearance
- **Performance**: Hardware-accelerated rendering with linear alpha blending
- **Workflow Integration**: Inherits working directory for seamless navigation

### Terminal Features
- **Visual Comfort**: Disabled font ligatures, thickened fonts for readability
- **Modern UI**: Transparent titlebar with shadow effects (macOS)
- **Cursor**: Block style with 0.7 opacity, no blinking
- **Keybindings**: Custom shift+enter for multiline input
- **Developer Friendly**: Full screen mode, mouse hide while typing

## Claude Desktop Safety Configuration

The configuration includes comprehensive safety features to prevent accidental system damage:

### Prohibited Commands
- Blocks all variations of `rm -rf /` and `rm -rf ~`
- Prevents deletion of entire home directory or system
- Includes sudo variations for additional protection
- Covers multiple command flag combinations (e.g., `-rf`, `-Rf`, `-r -f`, `-fr`)

### Safety Features
- **Destructive Action Confirmation**: Requires user confirmation for potentially dangerous operations
- **System Modification Protection**: Blocks unauthorized system changes
- **Sudo Protection**: Additional layer for privileged commands

### Configuration Location
- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Linux**: `~/.config/claude/claude_desktop_config.json`

## Key Customization Points

- Leader key is set to Space (`<leader> = Space`)
- Uses 2-space indentation for most file types
- Dart/Flutter specific settings in `lua/base.lua` autocmds
- Terminal integration expects zsh as default shell
- True color terminal support required