-- 基本設定
vim.scriptencoding = 'utf-8'
vim.opt.encoding = 'utf-8'
vim.opt.fileencoding = 'utf-8'

-- 表示設定
vim.wo.number = true
vim.opt.title = true
vim.opt.showcmd = true
vim.opt.laststatus = 2

-- インデント設定
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2

-- 検索設定
vim.opt.hlsearch = true
vim.opt.ignorecase = true

-- その他
vim.opt.backup = false
vim.opt.wrap = false
vim.opt.backspace = { 'start', 'eol', 'indent' }
