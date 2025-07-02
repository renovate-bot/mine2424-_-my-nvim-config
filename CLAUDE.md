# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a comprehensive Flutter development environment configuration for Neovim, designed for professional Flutter development with full IDE-like features. The configuration includes:

- **Main Configuration**: `lua/flutter-dev-with-dap.lua` - Full-featured Flutter dev environment with DAP debugging
- **Alternative**: `lua/plugins.lua` - Lightweight configuration (reference only)
- **Core Files**: `init.lua`, `lua/base.lua`, `lua/maps.lua`, `lua/ide-layout.lua`
- **Terminal Integration**: WezTerm with Claude monitoring system
- **Shell Enhancement**: Starship prompt with Flutter-specific features

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
- `wezterm.lua` and `starship.toml` are terminal/prompt configurations

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

## Terminal Integration

The configuration includes advanced WezTerm integration with:

### Claude Monitoring System
- **Real-time Detection**: Ultra-responsive (0.1s) Claude process monitoring with zero configuration
- **Dual Detection Method**: 
  - Process name scanning (`proc_info.name`)
  - Command line argument analysis (`proc_info.argv`) for `/applications/claude.app`
- **Smart Activity Detection**: CPU usage >1.0% + process state ('R'/'D') = active processing
- **Multi-Instance Support**: Tracks multiple Claude processes across all WezTerm tabs simultaneously
- **Visual Indicators**: 
  - 🤖 (idle) - Claude detected but CPU <1.0%
  - ⚡ (active) - Claude actively processing with CPU >1.0%
- **Integrated Display**: Claude status shown in both individual tab titles and global status bar
- **Stability First**: Based on proven wasabeef implementation for crash-free operation

### Enhanced Features
- **Git Integration**: Real-time Git branch display in status bar with automatic repository detection
- **Process Icon Mapping**: Comprehensive Nerd Font icons for nvim, git, docker, python, node, etc.
- **Tab Title Intelligence**: Displays Git repository names or directory names in tab titles
- **Error Resilience**: Comprehensive error handling prevents WezTerm crashes during monitoring
- **Resource Efficient**: Optimized process scanning with minimal system resource usage
- **Development Workflow**: Seamless integration with Flutter development environment

### Implementation Details
**Completely migrated to [wasabeef's dotfiles](https://github.com/wasabeef/dotfiles/blob/main/dot_wezterm.lua) implementation** for maximum stability and reliability.

#### Core Functions
- `get_claude_status()`: Scans all WezTerm windows/tabs/panes for Claude processes
- `check_process_running()`: Uses `ps -p <pid> -o stat,pcpu` to determine process activity and CPU usage
- `add_claude_status_to_elements()`: Adds appropriate Claude icons to status bar elements
- `process_to_icon()`: Maps process names to corresponding Nerd Font icons
- `get_git_repo_name()`: Extracts Git repository name from current working directory

#### Event Handlers
- `format-tab-title`: Real-time Claude icon display in tab titles with dual detection method
- `update-right-status`: Comprehensive status bar with Git branch, Claude status, and timestamp
- `window-focus-changed`: High-frequency status updates (0.1s) for responsive monitoring

#### Detection Strategy
- **Process Name Detection**: Checks `proc_info.name` for 'claude' substring
- **Command Line Detection**: Scans `proc_info.argv` for Claude app paths (`/applications/claude.app`)
- **Activity Monitoring**: Process state 'R' or 'D' with CPU usage >1.0% indicates active processing
- **Multi-tab Support**: Tracks Claude instances across all WezTerm tabs simultaneously

#### Visual Indicators
- **🤖** (idle) - Claude process detected but CPU usage <1.0%
- **⚡** (active) - Claude process with CPU usage >1.0% (actively processing)
- **Color Coding**: `#FF6B6B` for Claude icons, `#7aa2f7` for Git info, `#9ece6a` for timestamps

#### Architecture Benefits
- **Zero Configuration**: Works out-of-the-box without manual setup
- **Crash Resistant**: Error handling prevents WezTerm crashes during process monitoring
- **Performance Optimized**: Efficient process scanning with minimal system impact
- **Cross-Platform**: Compatible with macOS, Linux, and Windows environments

## Key Customization Points

- Leader key is set to Space (`<leader> = Space`)
- Uses 2-space indentation for most file types
- Dart/Flutter specific settings in `lua/base.lua` autocmds
- Terminal integration expects zsh as default shell
- True color terminal support required