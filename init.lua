-- ===============================================
-- Neovim Configuration Entry Point
-- ===============================================

-- Core settings
require('base')
require('maps')
require('autocmds')

-- Flutter development with DAP (main configuration)
require('flutter-dev-with-dap')

-- IDE layout setup
require('ide-layout').setup()

-- Simple IDE enhancements
require('simple-ide').setup()

-- NOTE: Commented out markdown fixes as they conflict with render-markdown.nvim
-- render-markdown.nvim requires treesitter to be enabled for markdown
-- -- Markdown fix for "can't change language without remark" error
-- require('markdown-fix').setup()

-- -- LSP Markdown fix to prevent changetracking errors
-- require('lsp-markdown-fix').setup()
