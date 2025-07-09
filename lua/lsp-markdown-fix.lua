-- ===============================================
-- LSP Markdown Fix - Prevent LSP errors for markdown files
-- ===============================================

local M = {}

-- markdownファイルでLSPを完全に無効化
function M.setup()
  -- グローバルな設定でmarkdownを除外
  local original_start_client = vim.lsp.start_client
  vim.lsp.start_client = function(config)
    -- configがnilの場合は早期リターン
    if not config then
      return original_start_client(config)
    end
    
    -- filetypesにmarkdownが含まれている場合は起動をスキップ
    if config.filetypes and vim.tbl_contains(config.filetypes, "markdown") then
      return nil
    end
    
    return original_start_client(config)
  end
  
  -- 既存のLSPクライアントからmarkdownを除外
  vim.api.nvim_create_autocmd("BufEnter", {
    pattern = {"*.md", "*.markdown"},
    callback = function(ev)
      -- 少し遅延させてからLSPを停止
      vim.defer_fn(function()
        local clients = vim.lsp.get_active_clients({ bufnr = ev.buf })
        for _, client in ipairs(clients) do
          -- markdownバッファからクライアントを安全にデタッチ
          pcall(function()
            vim.lsp.buf_detach_client(ev.buf, client.id)
          end)
        end
      end, 100)
    end,
    desc = "Detach LSP clients from markdown files"
  })
  
  -- BufReadPreでも早期にLSPを無効化
  vim.api.nvim_create_autocmd("BufReadPre", {
    pattern = {"*.md", "*.markdown"},
    callback = function()
      vim.b.lsp_disabled = true
    end,
    desc = "Mark buffer as LSP disabled before reading"
  })
end

return M