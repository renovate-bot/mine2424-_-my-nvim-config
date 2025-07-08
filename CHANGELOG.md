# Changelog

All notable changes to this Flutter Neovim configuration will be documented in this file.

## [2025-01-08] - Neovim 0.11+ Compatibility Update

### Fixed (Hotfix)
- Fixed claude-code.nvim API calls:
  - `toggle_claude_cli()` → `toggle()`
  - `show_sessions()` → Command `:ClaudeSessions`
  - `monitor_sessions()` → Command `:ClaudeMonitor`
  - `switch_worktree()` → Command `:ClaudeWorktreeSwitch`
  - Added `<leader>clo` for `open()` function

## [2025-01-08] - Neovim 0.11+ Compatibility Update

### Added
- **Neovim 0.11+ Support**: Full compatibility with latest Neovim features
- **Enhanced LSP Configuration**: 
  - LspAttach autocmd for dynamic keymapping
  - Inlay hints support with toggle functionality
  - Document highlight on cursor hold
  - Improved hover and signature help handlers with borders
- **nvim-treesitter**: Advanced syntax highlighting and text objects
- **telescope-fzf-native**: High-performance fuzzy search extension
- **nvim-tree**: Modern file explorer with git integration
- **lualine.nvim**: Customizable statusline
- **bufferline.nvim**: Tab-like buffer visualization

### Changed
- **Keybinding Refactoring**:
  - `<Tab>`/`<S-Tab>`: Now exclusively for buffer navigation
  - `<leader>q` → `<leader>Q`: Quit command (uppercase Q)
  - `<leader>e` → Dedicated to nvim-tree toggle
  - `<leader>f` → LSP formatting (Vim formatting moved to `<leader>=`)
  - Diagnostic float: `<leader>e` → `<leader>de`
  - Diagnostic loclist: `<leader>q` → `<leader>dl`
  - Buffer commands consolidated under `<leader>b*`
  - Tab commands consolidated under `<leader>t*`
  - QuickFix commands under `<leader>q*`
- **Telescope Enhancements**:
  - Added diagnostic search (`<leader>fd`)
  - Added keymap search (`<leader>fk`)
  - Added resume last search (`<leader>fR`)
  - Theme-specific layouts (dropdown, ivy)
- **DAP Keybindings**:
  - `<F10>` → `<F1>`: Step into
  - `<F11>` → `<F2>`: Step over
  - `<F12>` → `<F3>`: Step out
  - `<F9>` → `<leader>b`: Toggle breakpoint

### Fixed
- Resolved keybinding conflicts between plugins
- Improved LSP attachment reliability
- Enhanced diagnostic display with proper styling

### Documentation
- Updated README.md with latest features
- Enhanced FLUTTER_KEYBINDINGS.md with complete keymap reference
- Expanded DOCS.md with LSP details and new features
- Updated TROUBLESHOOTING.md for Neovim 0.11+ issues
- Updated CLAUDE.md with recent changes

## [Previous Version]

### Initial Release
- Flutter development environment with DAP debugging
- GitHub Copilot integration
- Git integration with gitsigns.nvim
- Basic LSP support
- Flash.nvim for enhanced search
- Claude Code integration