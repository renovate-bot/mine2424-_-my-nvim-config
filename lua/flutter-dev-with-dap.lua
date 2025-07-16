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
  -- gitsigns.nvim (Git差分表示)
  {
    'lewis6991/gitsigns.nvim',
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require('gitsigns').setup({
        signs = {
          add          = { text = '┃' },
          change       = { text = '┃' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
          untracked    = { text = '┆' },
        },
        signs_staged = {
          add          = { text = '┃' },
          change       = { text = '┃' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
          untracked    = { text = '┆' },
        },
        signs_staged_enable = true,
        signcolumn = true,
        numhl = false,
        linehl = false,
        word_diff = false,
        watch_gitdir = {
          follow_files = true
        },
        auto_attach = true,
        attach_to_untracked = false,
        current_line_blame = true,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = 'eol',
          delay = 1000,
          ignore_whitespace = false,
          virt_text_priority = 100,
        },
        current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil,
        max_file_length = 40000,
        preview_config = {
          border = 'single',
          style = 'minimal',
          relative = 'cursor',
          row = 0,
          col = 1
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, {expr=true, desc="Next git hunk"})

          map('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, {expr=true, desc="Previous git hunk"})

          -- Actions
          map('n', '<leader>hs', gs.stage_hunk, {desc="Stage hunk"})
          map('n', '<leader>hr', gs.reset_hunk, {desc="Reset hunk"})
          map('v', '<leader>hs', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end, {desc="Stage selected hunk"})
          map('v', '<leader>hr', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end, {desc="Reset selected hunk"})
          map('n', '<leader>hS', gs.stage_buffer, {desc="Stage buffer"})
          map('n', '<leader>hu', gs.undo_stage_hunk, {desc="Undo stage hunk"})
          map('n', '<leader>hR', gs.reset_buffer, {desc="Reset buffer"})
          map('n', '<leader>hp', gs.preview_hunk, {desc="Preview hunk"})
          map('n', '<leader>hb', function() gs.blame_line{full=true} end, {desc="Blame line"})
          map('n', '<leader>tb', gs.toggle_current_line_blame, {desc="Toggle blame"})
          map('n', '<leader>hd', gs.diffthis, {desc="Diff this"})
          map('n', '<leader>hD', function() gs.diffthis('~') end, {desc="Diff this ~"})
          map('n', '<leader>td', gs.toggle_deleted, {desc="Toggle deleted"})

          -- Text object
          map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', {desc="Select hunk"})
        end
      })
    end,
  },

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

  -- Copilot.lua (GitHub Copilot for Neovim)
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        panel = {
          enabled = true,
          auto_refresh = false,
          keymap = {
            jump_prev = "[[",
            jump_next = "]]",
            accept = "<CR>",
            refresh = "gr",
            open = "<M-CR>"
          },
          layout = {
            position = "bottom",
            ratio = 0.4
          },
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          hide_during_completion = true,
          debounce = 75,
          keymap = {
            accept = "<M-l>",
            accept_word = false,
            accept_line = false,
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        },
        filetypes = {
          yaml = false,
          markdown = false,
          help = false,
          gitcommit = false,
          gitrebase = false,
          hgcommit = false,
          svn = false,
          cvs = false,
          ["."] = false,
        },
        copilot_node_command = 'node',
        server_opts_overrides = {},
      })
    end,
  },

  -- copilot-cmp (nvim-cmp統合)
  {
    "zbirenbaum/copilot-cmp",
    config = function ()
      require("copilot_cmp").setup()
    end
  },

  -- flash.nvim (高度な検索とモーション)
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      labels = "asdfghjklqwertyuiopzxcvbnm",
      search = {
        -- 検索時の設定
        multi_window = true,
        forward = true,
        wrap = true,
        mode = "exact",
        incremental = false,
        exclude = {
          "notify",
          "cmp_menu",
          "noice",
          "flash_prompt",
          function(win)
            return not vim.api.nvim_win_get_config(win).focusable
          end,
        },
      },
      jump = {
        -- ジャンプ時の設定
        jumplist = true,
        pos = "start",
        history = false,
        register = false,
        nohlsearch = false,
        autojump = false,
      },
      modes = {
        -- 検索モードの設定
        search = {
          enabled = true,
          highlight = { backdrop = false },
          jump = { history = true, register = true, nohlsearch = true },
          search = {
            mode = "fuzzy",
            incremental = true,
          },
        },
        char = {
          enabled = true,
          config = function(opts)
            opts.autohide = vim.fn.mode(true):find("no") and vim.v.operator == "y"
            opts.jump_labels = opts.jump_labels and vim.v.count == 0
          end,
          highlight = { backdrop = true },
          jump = { register = false },
          search = { wrap = false },
          multi_line = true,
          keys = { "f", "F", "t", "T", ";", "," },
        },
        treesitter = {
          labels = "abcdefghijklmnopqrstuvwxyz",
          jump = { pos = "range" },
          highlight = {
            label = { before = true, after = true, style = "inline" },
            backdrop = false,
            matches = false,
          },
        },
        remote = {
          remote_op = { restore = true, motion = true },
        },
      },
      highlight = {
        backdrop = true,
        matches = true,
        priority = 5000,
        groups = {
          match = "FlashMatch",
          current = "FlashCurrent",
          backdrop = "FlashBackdrop",
          label = "FlashLabel",
        },
      },
    },
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },

  -- claude-code.nvim (Claude Code統合)
  {
    "sivchari/claude-code.nvim",
    event = "VeryLazy",
    config = function()
      require("claude-code").setup({
        -- 必要に応じて設定を追加
      })
    end,
    keys = {
      { "<leader>clc", function() require("claude-code").toggle() end, desc = "Toggle Claude" },
      { "<leader>clo", function() require("claude-code").open() end, desc = "Open Claude" },
      { "<leader>cll", "<cmd>ClaudeSessions<cr>", desc = "Show Claude Sessions" },
      { "<leader>clm", "<cmd>ClaudeMonitor<cr>", desc = "Monitor Claude Sessions" },
      { "<leader>clw", "<cmd>ClaudeWorktreeSwitch<cr>", desc = "Switch Claude Worktree" },
    },
  },

  -- nvim-cmp (自動補完フレームワーク)
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')

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
          { name = "copilot", group_index = 2 },
          { name = 'nvim_lsp', group_index = 2 },
          { name = 'luasnip', group_index = 2 },
        }, {
          { name = 'buffer' },
          { name = 'path' },
        })
      })
    end,
  },

  -- LSP Package Manager (Mason)
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
          }
        }
      })
    end,
  },

  -- LSP Configuration
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "dartls", "ts_ls", "eslint" },
        automatic_installation = true,
        -- sqlls と markdown LSP を自動セットアップから除外
        handlers = {
          -- デフォルトハンドラー
          function(server_name)
            -- sqlls と markdown 関連の LSP を除外
            if server_name ~= "sqlls" and 
               server_name ~= "marksman" and 
               server_name ~= "remark_ls" and
               server_name ~= "remark-language-server" then
              require("lspconfig")[server_name].setup({})
            end
          end,
          -- Dart は flutter-tools で管理するため、基本設定のみ
          ["dartls"] = function()
            -- dartls は下記の nvim-lspconfig セクションで設定
          end,
        },
      })
    end,
  },

  -- Neovim LSP Configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = { "williamboman/mason-lspconfig.nvim" },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      
      -- LSP診断設定
      vim.diagnostic.config({
        virtual_text = {
          prefix = "●",
          source = "if_many",
          spacing = 4,
        },
        float = {
          focusable = false,
          style = "minimal",
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      -- 診断記号の設定
      local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end

      -- グローバルLSPハンドラーの設定
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
        vim.lsp.handlers.hover, {
          border = "rounded",
          width = 60,
        }
      )

      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
        vim.lsp.handlers.signature_help, {
          border = "rounded",
          width = 60,
        }
      )

      -- LspAttach自動コマンドで共通キーマップを設定
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          
          -- バッファローカルマッピングを有効化
          local opts = { buffer = ev.buf }
          
          -- Navigation
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, vim.tbl_extend('force', opts, { desc = 'Go to declaration' }))
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, vim.tbl_extend('force', opts, { desc = 'Go to definition' }))
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, vim.tbl_extend('force', opts, { desc = 'Hover documentation' }))
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, vim.tbl_extend('force', opts, { desc = 'Go to implementation' }))
          vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, vim.tbl_extend('force', opts, { desc = 'Signature help' }))
          vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, vim.tbl_extend('force', opts, { desc = 'Add workspace folder' }))
          vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, vim.tbl_extend('force', opts, { desc = 'Remove workspace folder' }))
          vim.keymap.set('n', '<leader>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, vim.tbl_extend('force', opts, { desc = 'List workspace folders' }))
          vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, vim.tbl_extend('force', opts, { desc = 'Type definition' }))
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, vim.tbl_extend('force', opts, { desc = 'Rename' }))
          vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, vim.tbl_extend('force', opts, { desc = 'Code action' }))
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, vim.tbl_extend('force', opts, { desc = 'References' }))
          vim.keymap.set('n', '<leader>f', function()
            vim.lsp.buf.format { async = true }
          end, vim.tbl_extend('force', opts, { desc = 'Format buffer' }))
          
          -- Diagnostics
          vim.keymap.set('n', '<leader>de', vim.diagnostic.open_float, vim.tbl_extend('force', opts, { desc = 'Open diagnostic float' }))
          vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, vim.tbl_extend('force', opts, { desc = 'Previous diagnostic' }))
          vim.keymap.set('n', ']d', vim.diagnostic.goto_next, vim.tbl_extend('force', opts, { desc = 'Next diagnostic' }))
          vim.keymap.set('n', '<leader>dl', vim.diagnostic.setloclist, vim.tbl_extend('force', opts, { desc = 'Diagnostic to loclist' }))
          
          -- Enable inlay hints if supported
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            vim.keymap.set('n', '<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
            end, vim.tbl_extend('force', opts, { desc = 'Toggle inlay hints' }))
          end

          -- Enable word highlighting on cursor hold
          if client and client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = ev.buf,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = ev.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

      -- Dart LSP設定（flutter-toolsと連携するため基本設定のみ）
      lspconfig.dartls.setup({
        capabilities = capabilities,
        settings = {
          dart = {
            completeFunctionCalls = true,
            showTodos = true,
          }
        }
      })

      -- TypeScript/JavaScript LSP設定
      lspconfig.ts_ls.setup({
        capabilities = capabilities,
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = 'all',
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            }
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints = 'all',
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            }
          }
        }
      })

      -- ESLint LSP設定
      lspconfig.eslint.setup({
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            command = "EslintFixAll",
          })
        end,
      })

      -- SQL LSP設定を無効化（エラー回避）
      -- sqlls が自動的にアタッチされている場合は明示的に無効化
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "sql",
        callback = function()
          -- SQL ファイルで LSP を無効化
          vim.lsp.stop_client(vim.lsp.get_active_clients({ name = "sqlls" }))
        end,
      })
    end,
  },

  -- Flutter Tools (Flutter/Dart統合)
  {
    "akinsho/flutter-tools.nvim",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim",
    },
    config = function()
      require("flutter-tools").setup({
        ui = {
          border = "rounded",
          notification_style = "native",
        },
        decorations = {
          statusline = {
            app_version = false,
            device = true,
          }
        },
        debugger = {
          enabled = true,
          run_via_dap = true,
          exception_breakpoints = {},
          register_configurations = function(paths)
            require("dap").configurations.dart = {
              require("dap.ext.vscode").load_launchjs(nil, { dart = {"dart", "flutter"} })
            }
          end,
        },
        flutter_path = nil,
        flutter_lookup_cmd = nil,
        fvm = false,
        widget_guides = {
          enabled = true,
        },
        closing_tags = {
          highlight = "ErrorMsg",
          prefix = ">",
          enabled = true
        },
        dev_log = {
          enabled = true,
          notify_errors = true,
          open_cmd = "tabedit",
        },
        dev_tools = {
          autostart = true,
          auto_open_browser = true,
        },
        outline = {
          open_cmd = "30vnew",
          auto_open = false
        },
        lsp = {
          color = {
            enabled = false,
            background = false,
            background_color = nil,
            foreground = false,
            virtual_text = true,
            virtual_text_str = "■",
          },
          on_attach = function(client, bufnr)
            -- 共通のLSPキーマップはLspAttach自動コマンドで設定
            -- Flutter固有の設定をここに追加可能
          end,
          capabilities = require("cmp_nvim_lsp").default_capabilities(),
          settings = {
            showTodos = true,
            completeFunctionCalls = true,
            renameFilesWithClasses = "prompt",
            enableSnippets = true,
            updateImportsOnRename = true,
          }
        }
      })
    end,
  },

  -- render-markdown.nvim (Markdown rendering in Neovim)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown" },
    opts = {},
  },
  -- hlchunk.nvim (コードチャンクハイライト)
  {
    "shellRaining/hlchunk.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("hlchunk").setup({
        chunk = {
          enable = true,
          notify = true,
          use_treesitter = true,
          style = {
            "#806d9c",
            "#c21f30",
          },
          chars = {
            horizontal_line = "─",
            vertical_line = "│",
            left_top = "╭",
            left_bottom = "╰",
            right_arrow = "─",
          },
          textobject = "",
          max_file_size = 1024 * 1024,
          error_sign = true,
        },
        indent = {
          enable = true,
          use_treesitter = false,
          style = {
            "#434C5E",
            "#4C566A",
            "#5E81AC",
            "#88C0D0",
            "#81A1C1",
            "#8FBCBB",
          },
          chars = {
            "│",
          },
          exclude_filetypes = {
            aerial = true,
            dashboard = true,
            help = true,
            lspinfo = true,
            packer = true,
            checkhealth = true,
            man = true,
            gitcommit = true,
            TelescopePrompt = true,
            [""] = true,
          },
        },
        line_num = {
          enable = true,
          style = "#806d9c",
          use_treesitter = true,
        },
        blank = {
          enable = true,
          style = {
            "#434C5E",
          },
          chars = {
            "․",
          },
          exclude_filetypes = {
            aerial = true,
            dashboard = true,
            help = true,
            lspinfo = true,
            packer = true,
            checkhealth = true,
            man = true,
            gitcommit = true,
            TelescopePrompt = true,
            [""] = true,
          },
        },
      })
    end,
  },

  -- 必要な依存関係
  {
    'nvim-lua/popup.nvim',
  },
  {
    'nvim-lua/plenary.nvim',
  },
  
  -- telescope-fzf-native (パフォーマンス向上)
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make',
    cond = function()
      return vim.fn.executable 'make' == 1
    end,
  },
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.4',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local actions = require('telescope.actions')
      require('telescope').setup({
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          path_display = { "truncate" },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<M-q>"] = actions.send_to_qflist + actions.open_qflist,
              ["<C-u>"] = actions.preview_scrolling_up,
              ["<C-d>"] = actions.preview_scrolling_down,
            },
            n = {
              ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<M-q>"] = actions.send_to_qflist + actions.open_qflist,
            }
          },
          file_ignore_patterns = {
            "node_modules",
            ".git/",
            "dist/",
            "build/",
            "*.lock",
          },
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
              results_width = 0.8,
            },
            vertical = {
              mirror = false,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },
          color_devicons = true,
          set_env = { ["COLORTERM"] = "truecolor" },
        },
        pickers = {
          find_files = {
            theme = "dropdown",
            previewer = false,
            find_command = { "rg", "--files", "--hidden", "--glob", "!.git" },
          },
          live_grep = {
            theme = "ivy",
          },
          buffers = {
            theme = "dropdown",
            previewer = false,
            initial_mode = "normal",
            mappings = {
              n = {
                ["dd"] = actions.delete_buffer,
              }
            }
          },
          lsp_references = {
            theme = "dropdown",
            initial_mode = "normal",
          },
          lsp_definitions = {
            theme = "dropdown",
            initial_mode = "normal",
          },
          lsp_implementations = {
            theme = "dropdown",
            initial_mode = "normal",
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          }
        }
      })
      
      -- fzf extension を読み込む
      pcall(require('telescope').load_extension, 'fzf')

      -- Telescopeキーマップ
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<Leader>ff', builtin.find_files, { desc = 'Find files' })
      vim.keymap.set('n', '<Leader>fg', builtin.live_grep, { desc = 'Live grep' })
      vim.keymap.set('n', '<Leader>fb', builtin.buffers, { desc = 'Find buffers' })
      vim.keymap.set('n', '<Leader>fh', builtin.help_tags, { desc = 'Find help' })
      vim.keymap.set('n', '<Leader>fs', builtin.lsp_document_symbols, { desc = 'Find document symbols' })
      vim.keymap.set('n', '<Leader>fw', builtin.lsp_workspace_symbols, { desc = 'Find workspace symbols' })
      vim.keymap.set('n', '<Leader>fr', builtin.oldfiles, { desc = 'Find recent files' })
      vim.keymap.set('n', '<Leader>fc', builtin.commands, { desc = 'Find commands' })
      vim.keymap.set('n', '<Leader>fd', builtin.diagnostics, { desc = 'Find diagnostics' })
      vim.keymap.set('n', '<Leader>fk', builtin.keymaps, { desc = 'Find keymaps' })
      vim.keymap.set('n', '<Leader>ft', builtin.builtin, { desc = 'Find telescope builtin' })
      vim.keymap.set('n', '<Leader>fR', builtin.resume, { desc = 'Resume last search' })
    end,
  },
  
  -- nvim-treesitter (LSPサポート向上)
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          "dart", "lua", "vim", "vimdoc", "query",
          "javascript", "typescript", "html", "css", "json",
          "yaml", "toml", "markdown", "markdown_inline",
          "bash", "regex", "sql"
        },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          -- Enable treesitter for all files including markdown
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = false,
            node_decremental = "<bs>",
          },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
              ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
            },
            selection_modes = {
              ['@parameter.outer'] = 'v',
              ['@function.outer'] = 'V',
              ['@class.outer'] = '<c-v>',
            },
            include_surrounding_whitespace = true,
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]m"] = "@function.outer",
              ["]]"] = "@class.outer",
            },
            goto_next_end = {
              ["]M"] = "@function.outer",
              ["]["] = "@class.outer",
            },
            goto_previous_start = {
              ["[m"] = "@function.outer",
              ["[["] = "@class.outer",
            },
            goto_previous_end = {
              ["[M"] = "@function.outer",
              ["[]"] = "@class.outer",
            },
          },
        },
      })
    end,
  },
  
  -- ファイルブラウザ (nvim-tree)
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require("nvim-tree").setup({
        sort = {
          sorter = "case_sensitive",
        },
        view = {
          width = 30,
          side = "left",
        },
        renderer = {
          group_empty = true,
          highlight_git = true,
          icons = {
            show = {
              git = true,
              folder = true,
              file = true,
              folder_arrow = true,
            },
          },
        },
        filters = {
          dotfiles = false,
          custom = { "^.git$", "node_modules", ".cache" },
        },
        git = {
          enable = true,
          ignore = false,
        },
        actions = {
          open_file = {
            quit_on_open = false,
            window_picker = {
              enable = true,
            },
          },
        },
        on_attach = function(bufnr)
          local api = require('nvim-tree.api')
          
          local function opts(desc)
            return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
          end
          
          -- デフォルトマッピング
          api.config.mappings.default_on_attach(bufnr)
          
          -- カスタムマッピング
          vim.keymap.set('n', 'l', api.node.open.edit, opts('Open'))
          vim.keymap.set('n', 'h', api.node.navigate.parent_close, opts('Close Directory'))
          vim.keymap.set('n', 'v', api.node.open.vertical, opts('Open: Vertical Split'))
        end,
      })
      
      -- nvim-tree キーマップ
      vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'Toggle file tree' })
      vim.keymap.set('n', '<leader>ef', ':NvimTreeFindFile<CR>', { desc = 'Find current file in tree' })
    end,
  },
  
  -- ステータスライン (lualine)
  {
    'nvim-lualine/lualine.nvim',
    event = "VeryLazy",
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup({
        options = {
          icons_enabled = true,
          theme = 'auto',
          component_separators = { left = '│', right = '│' },
          section_separators = { left = '', right = '' },
          disabled_filetypes = {
            statusline = { 'NvimTree' },
            winbar = {},
          },
          ignore_focus = {},
          always_divide_middle = true,
          globalstatus = false,
          refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
          }
        },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'branch', 'diff', 'diagnostics'},
          lualine_c = {{'filename', path = 1}},
          lualine_x = {
            {
              require("lazy.status").updates,
              cond = require("lazy.status").has_updates,
              color = { fg = "#ff9e64" },
            },
            'encoding',
            'fileformat',
            'filetype'
          },
          lualine_y = {'progress'},
          lualine_z = {'location'}
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {{'filename', path = 1}},
          lualine_x = {'location'},
          lualine_y = {},
          lualine_z = {}
        },
        tabline = {},
        winbar = {},
        inactive_winbar = {},
        extensions = {}
      })
    end,
  },
  
  -- バッファライン (bufferline) - デフォルトで無効化
  {
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    enabled = false,  -- デフォルトで無効化
    event = "VeryLazy",
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          always_show_bufferline = false,  -- バッファが1つの時は非表示
          show_buffer_close_icons = false,
          show_close_icon = false,
          separator_style = "thin",
          offsets = {
            {
              filetype = "NvimTree",
              text = "File Explorer",
              highlight = "Directory",
              separator = true,
            }
          },
        }
      })
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
