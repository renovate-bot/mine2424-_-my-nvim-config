-- ===============================================
-- プラグイン設定（プラグインマネージャー不使用版）
-- ===============================================

-- このファイルではプラグインマネージャーを使用せず、
-- 必要最小限の機能を標準機能で実装します

-- ===============================================
-- ファイルタイプ別設定
-- ===============================================

-- 自動コマンドグループ作成
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- プログラミング言語別設定
autocmd('FileType', {
  pattern = { 'javascript', 'typescript', 'json' },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
  end,
  desc = 'JS/TS specific settings'
})

autocmd('FileType', {
  pattern = { 'python' },
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
  end,
  desc = 'Python specific settings'  
})

autocmd('FileType', {
  pattern = { 'dart' },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
  end,
  desc = 'Dart/Flutter specific settings'
})

-- ===============================================
-- 自動保存・読み込み
-- ===============================================

-- ファイル変更時の自動読み込み
autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' }, {
  pattern = '*',
  command = 'if mode() != "c" | checktime | endif',
  desc = 'Auto reload files'
})

-- 保存時に行末空白を削除
autocmd('BufWritePre', {
  pattern = '*',
  command = '%s/\\s\\+$//e',
  desc = 'Remove trailing whitespace on save'
})

-- ===============================================
-- カーソル位置の復元
-- ===============================================

-- ファイルを開いた時に前回のカーソル位置に移動
autocmd('BufReadPost', {
  pattern = '*',
  callback = function()
    local line = vim.fn.line("'\"")
    if line > 1 and line <= vim.fn.line('$') then
      vim.cmd('normal! g`"')
    end
  end,
  desc = 'Restore cursor position'
})

-- ===============================================
-- ハイライト設定
-- ===============================================

-- 検索結果のハイライトを自動的にクリア
autocmd('CmdlineEnter', {
  pattern = { '/', '?' },
  command = 'set hlsearch',
  desc = 'Enable search highlight'
})

-- ===============================================
-- ターミナル設定
-- ===============================================

-- ターミナルモードでの設定
autocmd('TermOpen', {
  pattern = '*',
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = 'no'
  end,
  desc = 'Terminal settings'
})

-- ===============================================
-- ヤンクハイライト
-- ===============================================

-- ヤンク時のハイライト（Neovim 0.5+）
autocmd('TextYankPost', {
  pattern = '*',
  callback = function()
    vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 300 })
  end,
  desc = 'Highlight yanked text'
})

-- ===============================================
-- 開発用ユーティリティ
-- ===============================================

-- Git関連の設定
autocmd('FileType', {
  pattern = 'gitcommit',
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.colorcolumn = '50,72'
  end,
  desc = 'Git commit settings'
})

-- Markdown設定
autocmd('FileType', {
  pattern = 'markdown',
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
    vim.opt_local.conceallevel = 2
  end,
  desc = 'Markdown settings'
})

-- ===============================================
-- 簡易LSP的機能（標準機能を使用）
-- ===============================================

-- タグジャンプの設定（ctagsがある場合）
vim.opt.tags = './tags;,tags;'

-- オムニ補完の設定
autocmd('FileType', {
  pattern = { 'javascript', 'typescript' },
  callback = function()
    vim.opt_local.omnifunc = 'syntaxcomplete#Complete'
  end,
  desc = 'JS/TS omni completion'
})

-- ===============================================
-- カラースキーム設定
-- ===============================================

-- デフォルトカラースキームの設定
vim.cmd.syntax('enable')
if vim.fn.has('termguicolors') == 1 then
  vim.opt.termguicolors = true
end

-- デフォルトテーマの改善（利用可能な場合）
pcall(function()
  vim.cmd.colorscheme('default')
end)

-- ===============================================
-- ステータスライン（簡易版）
-- ===============================================

-- カスタムステータスライン
function _G.custom_statusline()
  local mode_map = {
    n = 'NORMAL',
    i = 'INSERT', 
    v = 'VISUAL',
    V = 'V-LINE',
    c = 'COMMAND',
    t = 'TERMINAL'
  }
  
  local mode = mode_map[vim.api.nvim_get_mode().mode] or 'UNKNOWN'
  local file = vim.fn.expand('%:t')
  local filetype = vim.bo.filetype
  local line = vim.fn.line('.')
  local col = vim.fn.col('.')
  local total = vim.fn.line('$')
  
  -- LSPクライアント情報を追加
  local lsp_clients = {}
  for _, client in pairs(vim.lsp.get_active_clients({ bufnr = 0 })) do
    table.insert(lsp_clients, client.name)
  end
  local lsp_info = #lsp_clients > 0 and ('LSP:' .. table.concat(lsp_clients, ',')) or 'No LSP'
  
  -- 診断情報を追加
  local diagnostics = vim.diagnostic.get(0)
  local errors = #vim.tbl_filter(function(d) return d.severity == vim.diagnostic.severity.ERROR end, diagnostics)
  local warnings = #vim.tbl_filter(function(d) return d.severity == vim.diagnostic.severity.WARN end, diagnostics)
  local diag_info = errors > 0 and ('E:' .. errors) or ''
  diag_info = diag_info .. (warnings > 0 and (diag_info ~= '' and ' W:' or 'W:') .. warnings or '')
  diag_info = diag_info ~= '' and (' | ' .. diag_info) or ''
  
  return string.format(' %s | %s | %s | %s | %d:%d/%d%s ', 
    mode, file, filetype, lsp_info, line, col, total, diag_info)
end

vim.opt.statusline = '%{v:lua.custom_statusline()}'