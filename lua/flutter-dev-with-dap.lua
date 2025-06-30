-- ===============================================
-- シンプルなVSCode launch.json統合設定
-- ブログ記事: https://astomih.hatenablog.com/entry/2024/03/21/131429
-- ===============================================

-- プラグインマネージャー（lazy.nvim）の自動インストール
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ===============================================
-- 必要最小限のプラグイン設定
-- ===============================================

local plugins = {
  -- nvim-dap (Debug Adapter Protocol)
  {
    'mfussenegger/nvim-dap',
    config = function()
      local dap = require('dap')
      
      -- Dart/Flutterデバッグアダプター設定
      dap.adapters.dart = {
        type = "executable",
        command = "dart",
        args = {"debug_adapter"},
        options = {
          detached = false,
        },
      }
      
      -- デバッグ設定（launch.jsonから自動読み込み）
      dap.configurations.dart = {}
      
      -- launch.json自動読み込み
      require('dap.ext.vscode').load_launchjs(nil, {
        dart = {'dart', 'flutter'},
        flutter = {'dart', 'flutter'}
      })
      
      -- ブログ記事準拠のキーマップ
      vim.keymap.set('n', '<F5>', dap.continue, { desc = "Debug: Start/Continue" })
      vim.keymap.set('n', '<F1>', dap.step_into, { desc = "Debug: Step Into" })
      vim.keymap.set('n', '<F2>', dap.step_over, { desc = "Debug: Step Over" })
      vim.keymap.set('n', '<F3>', dap.step_out, { desc = "Debug: Step Out" })
      vim.keymap.set('n', '<Leader>b', dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
    end,
  },

  -- vs-tasks.nvim (VSCode tasks.json統合)
  {
    'EthanJWright/vs-tasks.nvim',
    dependencies = {
      'nvim-lua/popup.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim'
    },
    config = function()
      require("vstask").setup({
        cache_json_conf = true,
        cache_strategy = "last",
        config_dir = ".vscode",
        use_harpoon = false,
      })
      
      -- VSCode Tasks統合キーマップ
      vim.keymap.set('n', '<Leader>vt', ':VstaskInfo<CR>', { desc = 'VSCode Tasks Info' })
      vim.keymap.set('n', '<Leader>vr', ':VstaskRun<CR>', { desc = 'Run VSCode Task' })
    end,
  },

  -- 必要な依存関係
  {
    'nvim-lua/popup.nvim',
  },
  {
    'nvim-lua/plenary.nvim',
  },
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.4',
    config = function()
      require('telescope').setup({})
    end,
  },
}

-- lazy.nvimでプラグインをセットアップ
require("lazy").setup(plugins, {
  ui = {
    border = "rounded",
  },
})

print("Simple VSCode launch.json integration loaded! 🚀")