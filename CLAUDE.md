# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a comprehensive Flutter development environment configuration for Neovim, designed for professional Flutter development with full IDE-like features. The configuration includes:

- **Main Configuration**: `lua/flutter-dev-with-dap.lua` - Full-featured Flutter dev environment with DAP debugging
- **Alternative**: `lua/plugins.lua` - Lightweight configuration (reference only)
- **Core Files**: `init.lua`, `lua/base.lua`, `lua/maps.lua`, `lua/ide-layout.lua`, `lua/simple-ide.lua`
- **3-Panel IDE Layout**: Simplified IDE with file tree | editor | editor split
- **Zsh Configuration**: Modern shell setup based on wasabeef/dotfiles with plugins and aliases
- **Terminal Integration**: Ghostty terminal with modern configuration
- **Shell Enhancement**: Starship prompt with Flutter-specific features
- **Safety Configuration**: Claude Desktop with prohibited command blocking
- **Claude Code Safety**: Command deny list with preToolUse hooks for safe execution
- **MCP Integration**: Model Context Protocol servers for GitHub, Context7, and Playwright

## Key Architecture

### Configuration Loading Order
1. `init.lua` - Entry point that loads all modules
2. `lua/base.lua` - Basic Vim settings and autocommands  
3. `lua/maps.lua` - Keybinding definitions (includes new IDE exit shortcuts)
4. `lua/plugins.lua` - Plugin management (currently inactive)
5. `lua/ide-layout.lua` - IDE-style layout setup (includes 3-panel layout)
6. `lua/simple-ide.lua` - Simplified IDE configuration with auto-layout
7. `lua/flutter-dev-with-dap.lua` - Main Flutter development configuration with full plugin ecosystem

### Plugin Management
- Uses **lazy.nvim** as the plugin manager
- All plugins are configured in `lua/flutter-dev-with-dap.lua`
- Plugin auto-installation on first run
- Lazy-loading for performance optimization

### Core Plugin Stack
- **Flutter Tools**: `akinsho/flutter-tools.nvim` for Flutter development
- **LSP**: Mason + lspconfig for language servers (Dart, TypeScript, JavaScript, etc.)
  - **Dart**: `dartls` for Flutter/Dart development
  - **TypeScript/JavaScript**: `tsserver` with inlay hints support
  - **ESLint**: `eslint` for linting with auto-fix on save
- **Git Integration**: `lewis6991/gitsigns.nvim` with extensive hunk management
- **AI Assistance**: `zbirenbaum/copilot.lua` with cmp integration
- **Debugging**: nvim-dap with Flutter DAP support
- **UI**: lualine, nvim-tree, telescope (bufferline disabled for simplicity)
- **Code Quality**: hlchunk.nvim for visual code structure
- **Search Enhancement**: `folke/flash.nvim` for advanced search and navigation
- **Claude Code Integration**: `sivchari/claude-code.nvim` for Neovim-Claude Code integration
- **Syntax Highlighting**: `nvim-treesitter` with text objects support
- **Fuzzy Finding**: `telescope-fzf-native` for performance
- **File Explorer**: `nvim-tree` with git integration

## Three-Panel IDE Layout

The configuration includes a simplified 3-panel IDE layout that provides an efficient development environment:

### Layout Structure
```
[File Tree | Main Editor | Secondary Editor]
   30 cols      Equal          Equal
```

### IDE Management
- **Start IDE**: `<leader>is` or `:StartSimpleIDE` (auto-starts on empty Neovim)
- **Window Navigation**: 
  - `<leader>w1` - Jump to file tree
  - `<leader>w2` - Jump to main editor
  - `<leader>w3` - Jump to secondary editor
- **Window Management**:
  - `<leader>w=` - Rebalance windows (keeps file tree at 30 columns)
  - `<leader>wd` - Duplicate current buffer to right window
- **Quick Exit**:
  - `<leader>qq` - Exit all windows and quit Neovim
  - `<leader>qa` - Force quit without saving
  - `<leader>wqa` - Save all and quit

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
- **Debugging**: `<F5>` (start debug), `<F1>` (step into), `<F2>` (step over), `<F3>` (step out)
- **LSP Actions**: `<leader>ca` (code actions), `<leader>rn` (rename), `gd` (go to definition)

### Git Operations (gitsigns.nvim)
- **Hunk Navigation**: `]c` (next hunk), `[c` (previous hunk)
- **Hunk Actions**: `<leader>hs` (stage), `<leader>hr` (reset), `<leader>hp` (preview)
- **Blame**: `<leader>hb` (line blame), `<leader>tb` (toggle blame display)

### GitHub Copilot Integration
- **Suggestions**: `Alt+l` (accept), `Alt+]`/`Alt+[` (navigate)
- **Management**: `<leader>cc` (Copilot chat), `<leader>C*` commands for control

### Search and Navigation
- **Basic Search**: `/` (forward), `?` (backward), `n`/`N` (next/previous)
- **Flash Jump**: `s` (2-char jump), `S` (treesitter jump)
- **Enhanced f/F/t/T**: Single-char search with Flash labels
- **Word Search**: `*`/`#` (search word under cursor without jumping)
- **Clear Highlight**: `<ESC><ESC>` (clear search highlights)
- **Telescope**: `<leader>ff` (files), `<leader>fg` (grep), `<leader>fb` (buffers), `<leader>fd` (diagnostics)

### Claude Code Integration (claude-code.nvim)
- **CLI Control**: `<leader>clc` (toggle Claude), `<leader>clo` (open Claude)
- **Session Management**: `<leader>cll` (show sessions), `<leader>clm` (monitor sessions)
- **Worktree**: `<leader>clw` (switch Claude worktree)
- **Features**: Per-worktree session management, real-time monitoring

## Important File Patterns

### Configuration Files
- `*.lua` files in `lua/` directory are the main configuration
- `init.lua` is the entry point
- `zsh/zshrc` is the main Zsh shell configuration
- `zsh/sheldon/plugins.toml` defines Zsh plugins managed by sheldon
- `ghostty/config` and `starship.toml` are terminal/prompt configurations
- `claude/claude_desktop_config.json` is Claude Desktop safety configuration
- `claude/mcp_config.json` and `claude/mcp_servers_detailed.json` are MCP server configurations
- `scripts/setup-mcp.sh` is the MCP setup script

### Flutter Development
- Flutter projects should be opened at the project root (where `pubspec.yaml` exists)
- The configuration automatically detects Flutter projects and enables appropriate LSP servers
- VSCode launch.json files are automatically read and integrated

### Documentation Structure
- `*.md` files contain comprehensive guides for different aspects
- `FLUTTER_KEYBINDINGS.md` contains complete keymap reference
- `TROUBLESHOOTING.md` has common issues and solutions
- `MCP_SETUP.md` contains MCP server configuration and usage guide

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

## Claude Code Safety Configuration

The project includes additional safety features for Claude Code command execution:

### Command Deny List (`~/.claude/settings.json`)
Blocks potentially dangerous commands including:
- **Git Config**: `git config --global` (prevents global git modifications)
- **Package Installation**: `brew install/upgrade`, `npm install -g`, `pip install`, etc.
- **System Commands**: `sudo`, `chmod 777`, `rm -rf`, filesystem operations
- **Service Control**: `systemctl`, `service`, `shutdown`, `reboot`
- **Process Control**: `killall`, `kill -9`
- **Remote Execution**: `curl | bash`, `wget | bash`
- **GitHub Operations**: `gh repo delete`, `gh auth logout`

### Safety Script (`~/.claude/scripts/deny-check.sh`)
- Intercepts bash commands before execution
- Checks against deny patterns
- Provides clear feedback when blocking dangerous commands
- Suggests manual execution for blocked operations

### Setup Integration
The `scripts/setup.sh` automatically installs:
- Claude Desktop configuration
- Claude Code safety settings (`~/.claude/settings.json`)
- Deny check script with proper permissions
- Both configurations are backed up during installation

## MCP (Model Context Protocol) Integration

The project includes MCP server configurations for extending Claude Code capabilities:

### Available MCP Servers
- **GitHub MCP**: Repository operations, issues, PRs, GitHub API access
- **Context7 MCP**: Enhanced context management and memory persistence
- **Playwright MCP**: Web automation, scraping, and browser testing

### MCP Configuration Files
- `claude/mcp_config.json` - Basic MCP server definitions
- `claude/mcp_servers_detailed.json` - Detailed configuration with descriptions
- `scripts/setup-mcp.sh` - Automated MCP setup script

### MCP Setup
The MCP configuration is automatically installed with the main setup script:
```bash
./scripts/setup.sh  # Includes MCP setup
# or
./scripts/setup-mcp.sh  # MCP setup only
```

### GitHub Token Configuration
For GitHub MCP functionality, set your personal access token:
```bash
export GITHUB_PERSONAL_ACCESS_TOKEN='your-token-here'
```

See `MCP_SETUP.md` for detailed configuration and usage instructions.

## Key Customization Points

- Leader key is set to Space (`<leader> = Space`)
- Uses 2-space indentation for most file types
- Dart/Flutter specific settings in `lua/base.lua` autocmds
- Terminal integration expects zsh as default shell
- True color terminal support required

## Recent Updates (Neovim 0.11+ Compatibility)

### LSP Configuration Improvements
- Migrated to LspAttach autocmd for dynamic keybinding setup
- Enhanced diagnostics with floating window borders and styling
- Added inlay hints support with toggle functionality
- Improved hover and signature help with custom handlers
- Document highlight on cursor hold for better code navigation
- **JavaScript/TypeScript Support**: Full LSP support with `tsserver` and `eslint`
  - Inlay hints for parameter names, types, and return values
  - ESLint auto-fix on save for code quality
  - Full IntelliSense, go-to-definition, and refactoring support

### Enhanced Plugin Stack
- **nvim-treesitter**: Syntax highlighting and advanced text objects
- **telescope-fzf-native**: Faster fuzzy searching with native performance
- **nvim-tree**: Modern file explorer with git integration
- **lualine**: Informative and customizable statusline
- **bufferline**: Visual buffer management with tab-like interface

### Keybinding Refactoring
- Resolved conflicts between buffer and tab navigation
- Organized diagnostic keybindings under `<leader>d*` prefix
- Separated LSP formatting (`<leader>f`) from Vim formatting (`<leader>=`)
- Improved quickfix commands under `<leader>q*` prefix
- Buffer commands consolidated under `<leader>b*` prefix