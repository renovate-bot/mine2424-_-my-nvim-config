-- ===============================================
-- Markdown "can't change language without remark" エラーの修正
-- ===============================================

local M = {}

-- Markdownファイルでのtreesitter無効化と代替設定
function M.setup()
  -- Markdownファイル用のautocmd
  vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter", "BufRead", "BufNewFile"}, {
    pattern = {"*.md", "*.markdown"},
    callback = function(ev)
      local buf = ev.buf
      
      -- LSPクライアントを安全に停止
      local clients = vim.lsp.get_active_clients({ bufnr = buf })
      for _, client in ipairs(clients) do
        pcall(function()
          client.stop()
        end)
      end
      
      -- treesitterのハイライトを無効化
      vim.treesitter.stop(buf)
      
      -- 従来のVim syntaxハイライトを有効化
      vim.cmd([[syntax enable]])
      vim.bo[buf].syntax = 'markdown'
      
      -- treesitter関連の機能を無効化
      vim.b[buf].ts_highlight = false
      
      -- markdownパーサーのエラーを回避
      pcall(function()
        local configs = require('nvim-treesitter.configs')
        if configs and configs.commands then
          configs.commands.TSBufDisable.run(buf, 'highlight')
        end
      end)
    end,
    desc = "Disable treesitter and LSP for markdown files to prevent remark error"
  })
  
  -- グローバルなtreesitter設定でmarkdownを除外
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
      -- treesitterのクエリを無効化
      vim.opt_local.indentexpr = ""
      vim.opt_local.foldmethod = "manual"
      
      -- 従来の構文ハイライトを強制
      vim.cmd([[
        if exists('b:current_syntax')
          unlet b:current_syntax
        endif
        syntax clear
        runtime! syntax/markdown.vim
      ]])
    end,
    desc = "Force traditional syntax for markdown"
  })
  
  -- LSPがmarkdownファイルにアタッチしないように設定
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      local bufnr = args.buf
      
      -- markdownファイルの場合はLSPを停止
      if vim.bo[bufnr].filetype == "markdown" then
        if client then
          -- 即座に停止せず、次のイベントループで停止
          vim.defer_fn(function()
            pcall(function()
              client.stop()
            end)
          end, 0)
        end
      end
    end,
    desc = "Prevent LSP from attaching to markdown files"
  })
end

-- 手動でmarkdownパーサーを修正
function M.fix_parser()
  -- 既存のmarkdownパーサーを削除して再インストール
  vim.cmd([[
    try
      TSUninstall markdown
    catch
    endtry
  ]])
  
  vim.defer_fn(function()
    vim.cmd([[
      try
        TSInstall markdown
      catch
      endtry
    ]])
  end, 1000)
end

-- treesitterの設定を確認して修正
function M.check_config()
  local ok, configs = pcall(require, 'nvim-treesitter.configs')
  if ok then
    local config = configs.get_module('highlight')
    if config and config.disable then
      -- 既存のdisable関数をラップ
      local original_disable = config.disable
      config.disable = function(lang, buf)
        if lang == "markdown" then
          return true
        end
        if type(original_disable) == "function" then
          return original_disable(lang, buf)
        end
        return false
      end
    end
  end
end

-- 初期化時に自動実行（init.luaから呼ばれるため、setup()の重複を避ける）
M.check_config()

return M