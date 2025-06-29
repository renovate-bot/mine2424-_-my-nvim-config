-- ===============================================
-- Flutter開発環境設定
-- ===============================================

-- 既存のプラグインマネージャーとの競合を防ぐ
local function safe_require(module)
  local ok, result = pcall(require, module)
  if not ok then
    return nil
  end
  return result
end

-- 既存のpacker設定をクリア
vim.g.loaded_packer = nil
package.loaded.packer = nil
package.loaded['packer.nvim'] = nil

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
-- Flutter開発用プラグイン設定
-- ===============================================

-- デバッグ機能の有効/無効フラグ
local enable_debug = true  -- trueにするとDAPプラグインを有効化（依存関係問題がある場合はfalseにしてください）

-- デバッグ状況をログ出力
if enable_debug then
  print("Debug plugins enabled")
else
  print("Debug plugins disabled - skipping DAP installation")
end

-- プラグインリスト
local plugins = {
  -- Flutter Tools - Flutter開発の核となるプラグイン
  {
    'akinsho/flutter-tools.nvim',
    ft = { "dart" },
    cmd = {
      "FlutterRun", "FlutterDevices", "FlutterEmulators", "FlutterReload",
      "FlutterRestart", "FlutterQuit", "FlutterDevTools"
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'stevearc/dressing.nvim', -- UI改善
    },
    config = function()
      require("flutter-tools").setup {
        ui = {
          border = "rounded",
          notification_style = 'native'
        },
        decorations = {
          statusline = {
            app_version = false,
            device = true,
            project_config = false,
          }
        },
        debugger = {
          enabled = enable_debug,
          run_via_dap = enable_debug,
          exception_breakpoints = {},
        },
        flutter_path = "/opt/homebrew/bin/flutter",
        flutter_lookup_cmd = nil,
        fvm = false,
        widget_guides = {
          enabled = true,
        },
        closing_tags = {
          highlight = "ErrorMsg",
          prefix = ">",
          enabled = true,
        },
        dev_log = {
          enabled = true,
          notify_errors = false,
          open_cmd = "tabedit",
        },
        dev_tools = {
          autostart = false,
          auto_open_browser = false,
        },
        outline = {
          open_cmd = "30vnew",
          auto_open = false,
        },
        lsp = {
          color = {
            enabled = false,
            background = false,
            foreground = false,
            virtual_text = true,
            virtual_text_str = "■",
          },
          on_attach = function(client, bufnr)
            -- LSP用キーマップ
            local opts = { buffer = bufnr }
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
            vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
            vim.keymap.set('n', '<Leader>rn', vim.lsp.buf.rename, opts)
            vim.keymap.set('n', '<Leader>ca', vim.lsp.buf.code_action, opts)
            vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
            vim.keymap.set('n', '<Leader>e', vim.diagnostic.open_float, opts)
            vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
            vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
            
            -- Flutter専用キーマップ
            vim.keymap.set('n', '<Leader>fr', '<cmd>FlutterRun<cr>', opts)
            vim.keymap.set('n', '<Leader>fq', '<cmd>FlutterQuit<cr>', opts)
            vim.keymap.set('n', '<Leader>fR', '<cmd>FlutterRestart<cr>', opts)
            vim.keymap.set('n', '<Leader>fh', '<cmd>FlutterReload<cr>', opts)
            vim.keymap.set('n', '<Leader>fd', '<cmd>FlutterDevices<cr>', opts)
            vim.keymap.set('n', '<Leader>fe', '<cmd>FlutterEmulators<cr>', opts)
            vim.keymap.set('n', '<Leader>fo', '<cmd>FlutterOutlineToggle<cr>', opts)
            vim.keymap.set('n', '<Leader>ft', '<cmd>FlutterDevTools<cr>', opts)
            vim.keymap.set('n', '<Leader>fc', '<cmd>FlutterLogClear<cr>', opts)
            
            -- 診断設定のカスタマイズ
            vim.diagnostic.config({
              virtual_text = {
                prefix = '●',
                spacing = 4,
                source = "if_many",
                format = function(diagnostic)
                  if diagnostic.severity == vim.diagnostic.severity.ERROR then
                    return string.format("🚨 %s", diagnostic.message)
                  elseif diagnostic.severity == vim.diagnostic.severity.WARN then
                    return string.format("⚠️  %s", diagnostic.message)
                  elseif diagnostic.severity == vim.diagnostic.severity.INFO then
                    return string.format("💡 %s", diagnostic.message)
                  else
                    return string.format("💭 %s", diagnostic.message)
                  end
                end,
              },
              float = {
                focusable = false,
                close_events = { "BudLeave", "CursorMoved", "InsertEnter", "FocusLost" },
                border = 'rounded',
                source = 'always',
                prefix = '',
                scope = 'cursor',
              },
              signs = {
                text = {
                  [vim.diagnostic.severity.ERROR] = '🚨',
                  [vim.diagnostic.severity.WARN] = '⚠️',
                  [vim.diagnostic.severity.INFO] = '💡',
                  [vim.diagnostic.severity.HINT] = '💭',
                },
                linehl = {},
                numhl = {},
              },
              underline = true,
              update_in_insert = false,
              severity_sort = true,
            })
          end,
          capabilities = (function()
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            local cmp_ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
            if cmp_ok then
              capabilities = vim.tbl_deep_extend("force", capabilities, cmp_nvim_lsp.default_capabilities())
            end
            return capabilities
          end)(),
          settings = {
            dart = {
              completeFunctionCalls = true,
              showTodos = true,
              lineLength = 120,
              enableSdkFormatter = true,
              analysisExcludedFolders = {
                vim.fn.expand("$HOME/fvm"),
                vim.fn.expand("$HOME/.pub-cache"),
              },
              updateImportsOnRename = true,
              includeDependenciesInWorkspaceSymbols = true,
              enableSnippets = true,
              includeDependenciesInWorkspaceSymbols = true,
              renameFilesWithClasses = "prompt",
            }
          }
        }
      }
    end,
  },

  -- 補完エンジン
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'rafamadriz/friendly-snippets',
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')

      -- friendly-snippetsを読み込み
      require("luasnip.loaders.from_vscode").lazy_load()
      
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        }, {
          { name = 'buffer' },
          { name = 'path' },
        })
      })
    end,
  },

  -- Treesitter - シンタックスハイライト
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = { "dart", "yaml", "json", "markdown", "lua", "vim" },
        auto_install = true,
        sync_install = false,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
        -- Neovim 0.10での競合を回避
        query_linter = {
          enable = true,
          use_virtual_text = true,
          lint_events = {"BufWrite", "CursorHold"},
        },
      }
    end,
  },

  -- Telescope - ファジーファインダー
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.4',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('telescope').setup({
        defaults = {
          mappings = {
            i = {
              ["<C-j>"] = "move_selection_next",
              ["<C-k>"] = "move_selection_previous",
            },
          },
        },
      })
      
      -- Telescopeキーマップ
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<Leader>ff', builtin.find_files, {})
      vim.keymap.set('n', '<Leader>fg', builtin.live_grep, {})
      vim.keymap.set('n', '<Leader>fb', builtin.buffers, {})
      vim.keymap.set('n', '<Leader>fh', builtin.help_tags, {})
      vim.keymap.set('n', '<Leader>fs', builtin.lsp_document_symbols, {})
      vim.keymap.set('n', '<Leader>fw', builtin.lsp_workspace_symbols, {})
    end,
  },


  -- Git統合
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup {
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
        },
        current_line_blame = true,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = 'eol',
          delay = 1000,
        },
      }
    end,
  },

  -- ファイルエクスプローラー
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('nvim-tree').setup {
        view = {
          width = 30,
          side = 'left',
        },
        filters = {
          dotfiles = false,
          custom = { '.git', 'node_modules', '.cache' },
        },
        git = {
          enable = true,
          ignore = false,
        },
      }
      vim.keymap.set('n', '<Leader>e', ':NvimTreeToggle<CR>', {})
    end,
  },

  -- Flutterプロジェクト管理
  {
    'RobertBrunhage/flutter-riverpod-snippets',
    ft = 'dart',
  },

  -- YAML設定ファイル支援
  {
    'stephpy/vim-yaml',
    ft = 'yaml',
  },

  -- フォーマッタ設定
  {
    'stevearc/conform.nvim',
    event = { "BufWritePre" },
    config = function()
      require('conform').setup({
        formatters_by_ft = {
          dart = { 'dart_format' },
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })
    end,
  },

  -- Lint検知強化
  {
    'mfussenegger/nvim-lint',
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require('lint')
      
      -- Dartファイル用のlinter設定
      lint.linters_by_ft = {
        dart = { 'dart_analyze' }
      }
      
      -- カスタムDart Analyzer linter
      lint.linters.dart_analyze = {
        cmd = 'dart',
        stdin = false,
        args = { 'analyze', '--fatal-infos', '.' },
        stream = 'both',
        ignore_exitcode = true,
        parser = function(output, bufnr)
          local diagnostics = {}
          local current_file = vim.api.nvim_buf_get_name(bufnr)
          
          for line in output:gmatch('[^\r\n]+') do
            -- Dart analyzeの出力形式: "  error • message • file:line:col • rule_name"
            local severity, message, file, row, col = line:match('%s*(%w+)%s*•%s*(.-)%s*•%s*([^:]+):(%d+):(%d+)')
            
            if not severity then
              -- 別の形式: "file:line:col - severity - message"
              file, row, col, severity, message = line:match('([^:]+):(%d+):(%d+)%s*-%s*(%w+)%s*-%s*(.+)')
            end
            
            if not severity then
              -- さらに別の形式: "severity at file:line:col • message"
              severity, file, row, col, message = line:match('(%w+)%s+at%s+([^:]+):(%d+):(%d+)%s*•%s*(.+)')
            end
            
            if severity and file and row and col and message and vim.fn.fnamemodify(file, ':p') == current_file then
              local diagnostic_severity = vim.diagnostic.severity.INFO
              local sev_lower = severity:lower()
              if sev_lower == 'error' then
                diagnostic_severity = vim.diagnostic.severity.ERROR
              elseif sev_lower == 'warning' then
                diagnostic_severity = vim.diagnostic.severity.WARN
              elseif sev_lower == 'info' then
                diagnostic_severity = vim.diagnostic.severity.INFO
              elseif sev_lower == 'hint' then
                diagnostic_severity = vim.diagnostic.severity.HINT
              end
              
              table.insert(diagnostics, {
                lnum = tonumber(row) - 1,
                col = tonumber(col) - 1,
                message = message:gsub('^%s+', ''):gsub('%s+$', ''),
                severity = diagnostic_severity,
                source = 'dart_analyze'
              })
            end
          end
          return diagnostics
        end,
      }
      
      -- 自動lint実行の設定
      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        pattern = "*.dart",
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}

-- デバッグ機能が有効な場合のみDAPプラグインを追加
if enable_debug then
  -- nvim-nio (必須依存関係として最優先でインストール)
  table.insert(plugins, {
    'nvim-neotest/nvim-nio',
    lazy = false,
    priority = 1000,
    config = function()
      -- nvim-nioが利用可能であることを確認
      pcall(require, 'nio')
    end,
  })

  -- DAP - デバッグ
  table.insert(plugins, {
    'mfussenegger/nvim-dap',
    lazy = false,
    priority = 900,
    dependencies = {
      'nvim-neotest/nvim-nio',
    },
    config = function()
      local dap = require('dap')
      
      -- デバッグキーマップ
      vim.keymap.set('n', '<F5>', dap.continue, { desc = "Debug: Start/Continue" })
      vim.keymap.set('n', '<F10>', dap.step_over, { desc = "Debug: Step Over" })
      vim.keymap.set('n', '<F11>', dap.step_into, { desc = "Debug: Step Into" })
      vim.keymap.set('n', '<F12>', dap.step_out, { desc = "Debug: Step Out" })
      vim.keymap.set('n', '<Leader>b', dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
      vim.keymap.set('n', '<Leader>B', function()
        dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
      end, { desc = "Debug: Conditional Breakpoint" })
      vim.keymap.set('n', '<Leader>dr', dap.repl.open, { desc = "Debug: Open REPL" })
    end,
  })

  -- DAP UI - デバッグ用UI
  table.insert(plugins, {
    'rcarriga/nvim-dap-ui',
    lazy = false,
    priority = 800,
    dependencies = {
      'mfussenegger/nvim-dap',
      'nvim-neotest/nvim-nio',
    },
    config = function()
      local nio_ok = pcall(require, 'nio')
      if not nio_ok then
        vim.notify("nvim-nio is not available. DAP UI may not work properly.", vim.log.levels.WARN)
        return
      end
      
      local dap = require('dap')
      local dapui = require('dapui')
      
      dapui.setup()
      
      -- DAP UI自動開閉
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
      
      vim.keymap.set('n', '<Leader>du', dapui.toggle, { desc = "Debug: Toggle UI" })
    end,
  })

  -- DAP Virtual Text - デバッグ時の変数表示
  table.insert(plugins, {
    'theHamsta/nvim-dap-virtual-text',
    dependencies = {
      'mfussenegger/nvim-dap',
    },
    config = function()
      require('nvim-dap-virtual-text').setup()
    end,
  })
end

-- lazy.nvimでプラグインをセットアップ
local setup_ok, setup_error = pcall(function()
  require("lazy").setup(plugins, {
    ui = {
      border = "rounded",
    },
  })
end)

if not setup_ok then
  vim.notify("Plugin setup failed: " .. tostring(setup_error), vim.log.levels.ERROR)
  print("Plugin setup failed: " .. tostring(setup_error))
end

-- ===============================================
-- ファイルタイプ検出の追加
-- ===============================================

-- Flutter国際化ファイル(.arb)をJSON形式として認識
vim.filetype.add {
  extension = {
    arb = 'json',
  },
}

-- ===============================================
-- Flutter開発用自動コマンド
-- ===============================================

local flutter_group = vim.api.nvim_create_augroup("FlutterDev", { clear = true })

-- Dartファイル専用設定
vim.api.nvim_create_autocmd("FileType", {
  group = flutter_group,
  pattern = "dart",
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.expandtab = true
    vim.opt_local.colorcolumn = "120"
    
    -- Dart特有のキーマップ
    vim.keymap.set('n', '<Leader>di', ':FlutterRun --verbose<CR>', { buffer = true })
    vim.keymap.set('n', '<Leader>dh', ':FlutterReload<CR>', { buffer = true })
    vim.keymap.set('n', '<Leader>dR', ':FlutterRestart<CR>', { buffer = true })
  end,
})

-- pubspec.yaml用設定
vim.api.nvim_create_autocmd("BufRead", {
  group = flutter_group,
  pattern = "pubspec.yaml",
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.expandtab = true
  end,
})

-- Flutter専用保存時処理
vim.api.nvim_create_autocmd("BufWritePre", {
  group = flutter_group,
  pattern = "*.dart",
  callback = function()
    -- 保存時に自動フォーマット（conform.nvimまたはLSPを使用）
    local conform_ok, conform = pcall(require, 'conform')
    if conform_ok then
      conform.format({ bufnr = 0, timeout_ms = 1000 })
    else
      -- フォールバック: LSPフォーマット
      local clients = vim.lsp.get_clients({ bufnr = 0 })
      if #clients > 0 then
        vim.lsp.buf.format({ 
          timeout_ms = 3000,
          filter = function(client)
            return client.name == "dartls"
          end 
        })
      end
    end
  end,
})

-- 保存後にlint実行
vim.api.nvim_create_autocmd("BufWritePost", {
  group = flutter_group,
  pattern = "*.dart",
  callback = function()
    -- nvim-lintが利用可能な場合にlint実行
    local lint_ok, lint = pcall(require, 'lint')
    if lint_ok then
      lint.try_lint()
    end
    
    -- 診断の再表示
    vim.defer_fn(function()
      vim.diagnostic.show()
    end, 100)
  end,
})

-- ===============================================
-- Flutter開発用ユーティリティ関数
-- ===============================================

-- Flutterプロジェクト検出
function _G.is_flutter_project()
  return vim.fn.filereadable(vim.fn.getcwd() .. '/pubspec.yaml') == 1
end

-- Flutter開発モード切り替え
function _G.toggle_flutter_mode()
  if _G.is_flutter_project() then
    print("Flutter development mode enabled")
    vim.cmd('FlutterRun')
  else
    print("Not a Flutter project")
  end
end

-- クイックFlutter新規プロジェクト作成
function _G.create_flutter_project()
  local project_name = vim.fn.input("Project name: ")
  if project_name ~= "" then
    vim.fn.system("flutter create " .. project_name)
    vim.cmd("cd " .. project_name)
    print("Flutter project '" .. project_name .. "' created")
  end
end

-- Flutter開発用ステータスライン更新
function _G.flutter_statusline()
  local status = ""
  if _G.is_flutter_project() then
    status = status .. "📱 Flutter"
    
    -- Flutterデバイス情報取得
    local device_info = vim.fn.system("flutter devices --machine 2>/dev/null")
    if vim.v.shell_error == 0 and device_info ~= "" then
      status = status .. " | 📲"
    end
  end
  return status
end

-- ===============================================
-- Flutter開発用キーマップ
-- ===============================================

-- グローバルFlutterキーマップ
vim.keymap.set('n', '<Leader>Fn', ':lua _G.create_flutter_project()<CR>', { desc = 'New Flutter project' })
vim.keymap.set('n', '<Leader>Ft', ':lua _G.toggle_flutter_mode()<CR>', { desc = 'Toggle Flutter mode' })
vim.keymap.set('n', '<Leader>Fl', ':FlutterLogToggle<CR>', { desc = 'Toggle Flutter logs' })
vim.keymap.set('n', '<Leader>Fs', ':FlutterSuper<CR>', { desc = 'Flutter super class' })
vim.keymap.set('n', '<Leader>Fw', ':FlutterWrap<CR>', { desc = 'Flutter wrap widget' })

print("Flutter development environment loaded! 🎯")