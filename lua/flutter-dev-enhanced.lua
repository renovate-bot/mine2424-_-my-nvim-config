-- ===============================================
-- Flutter開発環境設定（強化版）
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

-- Flutter開発用プラグイン設定（強化版）
require("lazy").setup({
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
            app_version = true,
            device = true,
            project_config = true,
          }
        },
        debugger = {
          enabled = true,
          run_via_dap = true,
          exception_breakpoints = {},
        },
        flutter_path = (function()
          -- Check mise installation paths
          local function check_mise_flutter()
            -- Check if mise is available
            if vim.fn.executable("mise") == 0 then return nil end
            
            -- Get flutter path from mise
            local flutter_path = vim.fn.system("mise which flutter 2>/dev/null"):gsub("%s+", "")
            if vim.v.shell_error == 0 and flutter_path ~= "" then
              return flutter_path
            end
            return nil
          end
          
          -- Check asdf installation paths
          local function check_asdf_flutter()
            -- Check if asdf is available
            if vim.fn.executable("asdf") == 0 then return nil end
            
            -- Get flutter path from asdf
            local flutter_path = vim.fn.system("asdf which flutter 2>/dev/null"):gsub("%s+", "")
            if vim.v.shell_error == 0 and flutter_path ~= "" then
              return flutter_path
            end
            return nil
          end
          
          -- Try mise first, then asdf, then system PATH
          return check_mise_flutter() or check_asdf_flutter() or vim.fn.exepath("flutter") or "flutter"
        end)(),
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
            enabled = true,
            background = true,
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
                    return string.format("E: %s", diagnostic.message)
                  elseif diagnostic.severity == vim.diagnostic.severity.WARN then
                    return string.format("W: %s", diagnostic.message)
                  elseif diagnostic.severity == vim.diagnostic.severity.INFO then
                    return string.format("I: %s", diagnostic.message)
                  else
                    return string.format("H: %s", diagnostic.message)
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
              signs = true,
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
          { name = 'copilot' },
        }, {
          { name = 'buffer' },
          { name = 'path' },
        })
      })
    end,
  },

  -- GitHub Copilot
  {
    'zbirenbaum/copilot.lua',
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
      })
    end,
  },

  -- Copilot補完統合
  {
    "zbirenbaum/copilot-cmp",
    dependencies = { "copilot.lua" },
    config = function ()
      require("copilot_cmp").setup()
    end
  },

  -- Copilot Chat
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
    opts = {
      debug = true,
      window = {
        layout = 'float',
        relative = 'cursor',
        width = 1,
        height = 0.4,
        row = 1
      }
    },
    keys = {
      { "<leader>cc", "<cmd>CopilotChatOpen<cr>", desc = "CopilotChat - Open" },
      { "<leader>ce", "<cmd>CopilotChatExplain<cr>", desc = "CopilotChat - Explain code" },
      { "<leader>ct", "<cmd>CopilotChatTests<cr>", desc = "CopilotChat - Generate tests" },
      { "<leader>cr", "<cmd>CopilotChatReview<cr>", desc = "CopilotChat - Review code" },
      { "<leader>cR", "<cmd>CopilotChatRefactor<cr>", desc = "CopilotChat - Refactor code" },
    },
  },

  -- Git強化版
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup {
        signs = {
          add          = { text = '│' },
          change       = { text = '│' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
          untracked    = { text = '┆' },
        },
        signcolumn = true,
        numhl      = false,
        linehl     = false,
        word_diff  = false,
        watch_gitdir = {
          interval = 1000,
          follow_files = true
        },
        attach_to_untracked = true,
        current_line_blame = true,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = 'eol',
          delay = 1000,
          ignore_whitespace = false,
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
        yadm = {
          enable = false
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
          end, {expr=true})

          map('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, {expr=true})

          -- Actions
          map('n', '<leader>hs', gs.stage_hunk)
          map('n', '<leader>hr', gs.reset_hunk)
          map('v', '<leader>hs', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
          map('v', '<leader>hr', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
          map('n', '<leader>hS', gs.stage_buffer)
          map('n', '<leader>hu', gs.undo_stage_hunk)
          map('n', '<leader>hR', gs.reset_buffer)
          map('n', '<leader>hp', gs.preview_hunk)
          map('n', '<leader>hb', function() gs.blame_line{full=true} end)
          map('n', '<leader>tb', gs.toggle_current_line_blame)
          map('n', '<leader>hd', gs.diffthis)
          map('n', '<leader>hD', function() gs.diffthis('~') end)
          map('n', '<leader>td', gs.toggle_deleted)

          -- Text object
          map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
        end
      }
    end,
  },

  -- Diffview
  {
    'sindrets/diffview.nvim',
    dependencies = 'nvim-lua/plenary.nvim',
    config = function()
      require("diffview").setup({
        diff_binaries = false,
        enhanced_diff_hl = false,
        git_cmd = { "git" },
        use_icons = true,
        icons = {
          folder_closed = "",
          folder_open = "",
        },
        signs = {
          fold_closed = "",
          fold_open = "",
        },
        view = {
          default = {
            layout = "diff2_horizontal",
            winbar_info = false,
          },
          merge_tool = {
            layout = "diff3_horizontal",
            disable_diagnostics = true,
          },
          file_history = {
            layout = "diff2_horizontal",
            winbar_info = false,
          },
        },
        file_panel = {
          listing_style = "tree",
          tree_options = {
            flatten_dirs = true,
            folder_statuses = "only_folded",
          },
          win_config = {
            position = "left",
            width = 35,
          },
        },
        key_bindings = {
          disable_defaults = false,
        },
      })
      
      -- キーマップ
      vim.keymap.set('n', '<leader>gd', '<cmd>DiffviewOpen<cr>', { desc = 'Git diff view' })
      vim.keymap.set('n', '<leader>gh', '<cmd>DiffviewFileHistory<cr>', { desc = 'Git file history' })
      vim.keymap.set('n', '<leader>gc', '<cmd>DiffviewClose<cr>', { desc = 'Close diff view' })
    end,
  },

  -- Neogit
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require('neogit').setup({
        disable_signs = false,
        disable_hint = false,
        disable_context_highlighting = false,
        disable_commit_confirmation = false,
        auto_refresh = true,
        sort_branches = "-committerdate",
        disable_builtin_notifications = false,
        use_magit_keybindings = false,
        kind = "tab",
        console_timeout = 2000,
        auto_show_console = true,
        remember_settings = true,
        use_per_project_settings = true,
        ignored_settings = {},
        commit_popup = {
          kind = "split",
        },
        preview_buffer = {
          kind = "split",
        },
        popup = {
          kind = "split",
        },
        signs = {
          section = { ">", "v" },
          item = { ">", "v" },
          hunk = { "", "" },
        },
        integrations = {
          diffview = true,
        },
      })
      
      vim.keymap.set('n', '<leader>gg', '<cmd>Neogit<cr>', { desc = 'Neogit status' })
    end,
  },

  -- Treesitter - シンタックスハイライト
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = { "dart", "yaml", "json", "markdown", "lua", "vim", "vimdoc", "regex", "bash", "markdown_inline" },
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

  -- ToggleTerm - 統合ターミナル
  {
    'akinsho/toggleterm.nvim',
    version = "*",
    config = function()
      require("toggleterm").setup{
        size = function(term)
          if term.direction == "horizontal" then
            return 15
          elseif term.direction == "vertical" then
            return vim.o.columns * 0.4
          end
        end,
        open_mapping = [[<c-\>]],
        hide_numbers = true,
        shade_filetypes = {},
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true,
        terminal_mappings = true,
        persist_size = true,
        persist_mode = true,
        direction = 'float',
        close_on_exit = true,
        shell = vim.o.shell,
        float_opts = {
          border = 'curved',
          winblend = 0,
          highlights = {
            border = "Normal",
            background = "Normal",
          }
        }
      }
      
      -- ターミナル用キーマップ
      function _G.set_terminal_keymaps()
        local opts = {buffer = 0}
        vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
        vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
        vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
        vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
        vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
        vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
      end
      
      vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
      
      -- Flutter専用ターミナル
      local Terminal = require('toggleterm.terminal').Terminal
      local flutter_terminal = Terminal:new({
        cmd = "flutter run",
        direction = "horizontal",
        close_on_exit = false,
      })
      
      function _flutter_toggle()
        flutter_terminal:toggle()
      end
      
      vim.keymap.set("n", "<leader>tf", "<cmd>lua _flutter_toggle()<CR>", {noremap = true, silent = true})
    end,
  },

  -- Trouble - 診断情報の改善
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>TroubleToggle<cr>", desc = "Toggle Trouble" },
      { "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace Diagnostics" },
      { "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Document Diagnostics" },
      { "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", desc = "QuickFix" },
      { "<leader>xl", "<cmd>TroubleToggle loclist<cr>", desc = "Location List" },
    },
  },

  -- TODO Comments
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      signs = true,
      sign_priority = 8,
      keywords = {
        FIX = {
          icon = " ",
          color = "error",
          alt = { "FIXME", "BUG", "FIXIT", "ISSUE" },
        },
        TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
        TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
      },
      gui_style = {
        fg = "NONE",
        bg = "BOLD",
      },
      merge_keywords = true,
      highlight = {
        multiline = true,
        multiline_pattern = "^.",
        multiline_context = 10,
        before = "",
        keyword = "wide",
        after = "fg",
        pattern = [[.*<(KEYWORDS)\s*:]],
        comments_only = true,
        max_line_len = 400,
        exclude = {},
      },
      colors = {
        error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
        warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
        info = { "DiagnosticInfo", "#2563EB" },
        hint = { "DiagnosticHint", "#10B981" },
        default = { "Identifier", "#7C3AED" },
        test = { "Identifier", "#FF00FF" }
      },
      search = {
        command = "rg",
        args = {
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
        },
        pattern = [[\b(KEYWORDS):]],
      },
    },
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
      { "<leader>xt", "<cmd>TodoTrouble<cr>", desc = "Todo (Trouble)" },
      { "<leader>xT", "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme (Trouble)" },
      { "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Todo" },
      { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme" },
    },
  },

  -- Which Key
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {
      plugins = {
        marks = true,
        registers = true,
        spelling = {
          enabled = true,
          suggestions = 20,
        },
        presets = {
          operators = true,
          motions = true,
          text_objects = true,
          windows = true,
          nav = true,
          z = true,
          g = true,
        },
      },
      key_labels = {},
      icons = {
        breadcrumb = "»",
        separator = "➜",
        group = "+",
      },
      popup_mappings = {
        scroll_down = "<c-d>",
        scroll_up = "<c-u>",
      },
      window = {
        border = "rounded",
        position = "bottom",
        margin = { 1, 0, 1, 0 },
        padding = { 2, 2, 2, 2 },
        winblend = 0,
      },
      layout = {
        height = { min = 4, max = 25 },
        width = { min = 20, max = 50 },
        spacing = 3,
        align = "left",
      },
      ignore_missing = false,
      hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " },
      show_help = true,
      show_keys = true,
      triggers = "auto",
      triggers_blacklist = {
        i = { "j", "k" },
        v = { "j", "k" },
      },
      disable = {
        buftypes = {},
        filetypes = { "TelescopePrompt" },
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      
      -- グループ定義
      wk.register({
        ["<leader>f"] = { name = "+flutter/find" },
        ["<leader>g"] = { name = "+git" },
        ["<leader>h"] = { name = "+hunk" },
        ["<leader>x"] = { name = "+diagnostics/quickfix" },
        ["<leader>c"] = { name = "+copilot" },
        ["<leader>t"] = { name = "+terminal/toggle" },
        ["<leader>s"] = { name = "+search" },
        ["<leader>d"] = { name = "+dart/debug" },
        ["<leader>F"] = { name = "+Flutter project" },
      })
    end,
  },

  -- Lualine - ステータスライン
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup {
        options = {
          icons_enabled = true,
          theme = 'auto',
          component_separators = { left = '', right = ''},
          section_separators = { left = '', right = ''},
          disabled_filetypes = {
            statusline = {},
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
          lualine_c = {'filename'},
          lualine_x = {
            {
              function()
                local msg = 'No Active Lsp'
                local clients = vim.lsp.get_clients({ bufnr = 0 })
                if next(clients) == nil then
                  return msg
                end
                for _, client in ipairs(clients) do
                  return client.name
                end
                return msg
              end,
              icon = ' LSP:',
              color = { fg = '#ffffff', gui = 'bold' },
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
          lualine_c = {'filename'},
          lualine_x = {'location'},
          lualine_y = {},
          lualine_z = {}
        },
        tabline = {},
        winbar = {},
        inactive_winbar = {},
        extensions = {'nvim-tree', 'toggleterm', 'trouble'}
      }
    end,
  },

  -- Bufferline - タブライン
  {
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      require("bufferline").setup{
        options = {
          mode = "buffers",
          style_preset = require("bufferline").style_preset.default,
          themable = true,
          numbers = "none",
          close_command = "bdelete! %d",
          right_mouse_command = "bdelete! %d",
          left_mouse_command = "buffer %d",
          middle_mouse_command = nil,
          indicator = {
            icon = '▎',
            style = 'icon',
          },
          buffer_close_icon = '',
          modified_icon = '●',
          close_icon = '',
          left_trunc_marker = '',
          right_trunc_marker = '',
          max_name_length = 18,
          max_prefix_length = 15,
          truncate_names = true,
          tab_size = 18,
          diagnostics = "nvim_lsp",
          diagnostics_update_in_insert = false,
          diagnostics_indicator = function(count, level, diagnostics_dict, context)
            local s = " "
            for e, n in pairs(diagnostics_dict) do
              local sym = e == "error" and " "
                or (e == "warning" and " " or "")
              s = s .. n .. sym
            end
            return s
          end,
          offsets = {
            {
              filetype = "NvimTree",
              text = "File Explorer",
              text_align = "left",
              separator = true
            }
          },
          color_icons = true,
          show_buffer_icons = true,
          show_buffer_close_icons = true,
          show_close_icon = true,
          show_tab_indicators = true,
          show_duplicate_prefix = true,
          persist_buffer_sort = true,
          separator_style = "slant",
          enforce_regular_tabs = false,
          always_show_bufferline = true,
          hover = {
            enabled = true,
            delay = 200,
            reveal = {'close'}
          },
          sort_by = 'insert_after_current',
        }
      }
      
      -- Bufferlineキーマップ
      vim.keymap.set('n', '<Tab>', '<cmd>BufferLineCycleNext<cr>', { desc = 'Next buffer' })
      vim.keymap.set('n', '<S-Tab>', '<cmd>BufferLineCyclePrev<cr>', { desc = 'Previous buffer' })
      vim.keymap.set('n', '<leader>bp', '<cmd>BufferLineTogglePin<cr>', { desc = 'Pin buffer' })
      vim.keymap.set('n', '<leader>bP', '<cmd>BufferLineGroupClose ungrouped<cr>', { desc = 'Close non-pinned buffers' })
    end,
  },

  -- Indent Blankline
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
      scope = { enabled = false },
      exclude = {
        filetypes = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
        },
      },
    },
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
        renderer = {
          highlight_git = true,
          icons = {
            show = {
              git = true,
            },
          },
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

  -- Hop - 高速移動
  {
    'phaazon/hop.nvim',
    branch = 'v2',
    config = function()
      require'hop'.setup { keys = 'etovxqpdygfblzhckisuran' }
      
      -- Hopキーマップ
      vim.keymap.set('', 'f', "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true })<cr>", {})
      vim.keymap.set('', 'F', "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true })<cr>", {})
      vim.keymap.set('', 't', "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true, hint_offset = -1 })<cr>", {})
      vim.keymap.set('', 'T', "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 })<cr>", {})
      vim.keymap.set('n', '<leader>hw', "<cmd>HopWord<cr>", { desc = 'Hop to word' })
      vim.keymap.set('n', '<leader>hl', "<cmd>HopLine<cr>", { desc = 'Hop to line' })
      vim.keymap.set('n', '<leader>hc', "<cmd>HopChar1<cr>", { desc = 'Hop to char' })
      vim.keymap.set('n', '<leader>hp', "<cmd>HopPattern<cr>", { desc = 'Hop to pattern' })
    end
  },

  -- Auto Pairs
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    opts = {},
    config = function(_, opts)
      require("nvim-autopairs").setup(opts)
      
      -- nvim-cmpとの統合
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      local cmp = require('cmp')
      cmp.event:on(
        'confirm_done',
        cmp_autopairs.on_confirm_done()
      )
    end,
  },

  -- Comment
  {
    'numToStr/Comment.nvim',
    opts = {},
    lazy = false,
  },

  -- Surround
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup()
    end
  },

  -- Mason - LSP Manager
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

  -- Mason LSPConfig
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "dartls" },
        automatic_installation = true,
      })
    end,
  },

  -- DAP support
  {
    'mfussenegger/nvim-dap',
    config = function()
      local dap = require('dap')
      
      -- Enhanced VSCode launch.json support with project root detection
      local function find_launch_json()
        local cwd = vim.fn.getcwd()
        local markers = {
          'pubspec.yaml',  -- Flutter/Dart
          'package.json',  -- Node.js
          '.git',          -- Git repository
          '.vscode'        -- VSCode workspace
        }
        
        -- Check current directory first
        for _, marker in ipairs(markers) do
          if vim.fn.filereadable(cwd .. '/' .. marker) == 1 or vim.fn.isdirectory(cwd .. '/' .. marker) == 1 then
            local launch_json = cwd .. '/.vscode/launch.json'
            if vim.fn.filereadable(launch_json) == 1 then
              return launch_json
            end
          end
        end
        
        -- Walk up the directory tree
        local path = cwd
        while path ~= '/' do
          for _, marker in ipairs(markers) do
            if vim.fn.filereadable(path .. '/' .. marker) == 1 or vim.fn.isdirectory(path .. '/' .. marker) == 1 then
              local launch_json = path .. '/.vscode/launch.json'
              if vim.fn.filereadable(launch_json) == 1 then
                return launch_json
              end
            end
          end
          path = vim.fn.fnamemodify(path, ':h')
        end
        
        return nil
      end
      
      -- Load launch.json with enhanced type mapping
      local launch_json_path = find_launch_json()
      require('dap.ext.vscode').load_launchjs(launch_json_path, {
        dart = {'dart', 'flutter'},
        flutter = {'dart', 'flutter'},
        node = {'javascript', 'typescript'},
        python = {'python'},
        go = {'go'},
        rust = {'rust'},
        cpp = {'cpp', 'c'},
        java = {'java'}
      })
      
      -- Flutter debug adapter configuration
      dap.adapters.dart = {
        type = "executable",
        command = (function()
          -- Check mise installation paths
          local function check_mise_dart()
            if vim.fn.executable("mise") == 0 then return nil end
            local dart_path = vim.fn.system("mise which dart 2>/dev/null"):gsub("%s+", "")
            if vim.v.shell_error == 0 and dart_path ~= "" then
              return dart_path
            end
            return nil
          end
          
          -- Check asdf installation paths
          local function check_asdf_dart()
            if vim.fn.executable("asdf") == 0 then return nil end
            local dart_path = vim.fn.system("asdf which dart 2>/dev/null"):gsub("%s+", "")
            if vim.v.shell_error == 0 and dart_path ~= "" then
              return dart_path
            end
            return nil
          end
          
          -- Try mise first, then asdf, then system PATH
          return check_mise_dart() or check_asdf_dart() or vim.fn.exepath("dart") or "dart"
        end)(),
        args = {"debug_adapter"},
        options = {
          detached = false,
        },
      }
      
      -- Flutter debug configuration
      dap.configurations.dart = {
        {
          type = "dart",
          request = "launch",
          name = "Launch Flutter",
          dartSdkPath = function()
            -- Get project-specific Dart SDK path
            local function get_project_dart_sdk()
              local cwd = vim.fn.getcwd()
              
              -- Check project-local mise configuration
              local mise_toml = cwd .. "/.mise.toml"
              if vim.fn.filereadable(mise_toml) == 1 then
                local dart_path = vim.fn.system("cd " .. cwd .. " && mise which dart 2>/dev/null"):gsub("%s+", "")
                if vim.v.shell_error == 0 and dart_path ~= "" then
                  return vim.fn.fnamemodify(dart_path, ":h:h")
                end
              end
              
              -- Check project-local asdf configuration
              local tool_versions = cwd .. "/.tool-versions"
              if vim.fn.filereadable(tool_versions) == 1 then
                local dart_path = vim.fn.system("cd " .. cwd .. " && asdf which dart 2>/dev/null"):gsub("%s+", "")
                if vim.v.shell_error == 0 and dart_path ~= "" then
                  return vim.fn.fnamemodify(dart_path, ":h:h")
                end
              end
              
              -- Fallback to global mise/asdf, then system PATH
              if vim.fn.executable("mise") == 1 then
                local dart_path = vim.fn.system("mise which dart 2>/dev/null"):gsub("%s+", "")
                if vim.v.shell_error == 0 and dart_path ~= "" then
                  return vim.fn.fnamemodify(dart_path, ":h:h")
                end
              end
              
              if vim.fn.executable("asdf") == 1 then
                local dart_path = vim.fn.system("asdf which dart 2>/dev/null"):gsub("%s+", "")
                if vim.v.shell_error == 0 and dart_path ~= "" then
                  return vim.fn.fnamemodify(dart_path, ":h:h")
                end
              end
              
              return vim.fn.fnamemodify(vim.fn.exepath("dart"), ":h:h")
            end
            
            return get_project_dart_sdk()
          end,
          flutterSdkPath = function()
            -- Get project-specific Flutter SDK path
            local function get_project_flutter_sdk()
              local cwd = vim.fn.getcwd()
              
              -- Check project-local mise configuration
              local mise_toml = cwd .. "/.mise.toml"
              if vim.fn.filereadable(mise_toml) == 1 then
                local flutter_path = vim.fn.system("cd " .. cwd .. " && mise which flutter 2>/dev/null"):gsub("%s+", "")
                if vim.v.shell_error == 0 and flutter_path ~= "" then
                  return vim.fn.fnamemodify(flutter_path, ":h:h")
                end
              end
              
              -- Check project-local asdf configuration
              local tool_versions = cwd .. "/.tool-versions"
              if vim.fn.filereadable(tool_versions) == 1 then
                local flutter_path = vim.fn.system("cd " .. cwd .. " && asdf which flutter 2>/dev/null"):gsub("%s+", "")
                if vim.v.shell_error == 0 and flutter_path ~= "" then
                  return vim.fn.fnamemodify(flutter_path, ":h:h")
                end
              end
              
              -- Fallback to global mise/asdf, then system PATH
              if vim.fn.executable("mise") == 1 then
                local flutter_path = vim.fn.system("mise which flutter 2>/dev/null"):gsub("%s+", "")
                if vim.v.shell_error == 0 and flutter_path ~= "" then
                  return vim.fn.fnamemodify(flutter_path, ":h:h")
                end
              end
              
              if vim.fn.executable("asdf") == 1 then
                local flutter_path = vim.fn.system("asdf which flutter 2>/dev/null"):gsub("%s+", "")
                if vim.v.shell_error == 0 and flutter_path ~= "" then
                  return vim.fn.fnamemodify(flutter_path, ":h:h")
                end
              end
              
              return vim.fn.fnamemodify(vim.fn.exepath("flutter"), ":h:h")
            end
            
            return get_project_flutter_sdk()
          end,
          program = "${workspaceFolder}/lib/main.dart",
          cwd = "${workspaceFolder}",
        },
        {
          type = "dart",
          request = "launch",
          name = "Launch Dart",
          program = "${file}",
          cwd = "${workspaceFolder}",
        },
      }
      
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
      
      -- VSCode style debug keymaps
      vim.keymap.set('n', '<Leader>dl', function()
        local launch_json_path = find_launch_json()
        if launch_json_path then
          require('dap.ext.vscode').load_launchjs(launch_json_path, {
            dart = {'dart', 'flutter'},
            flutter = {'dart', 'flutter'},
            node = {'javascript', 'typescript'},
            python = {'python'},
            go = {'go'},
            rust = {'rust'},
            cpp = {'cpp', 'c'},
            java = {'java'}
          })
          vim.notify("VSCode launch.json reloaded: " .. vim.fn.fnamemodify(launch_json_path, ':t'), vim.log.levels.INFO)
        else
          vim.notify("No launch.json found in project", vim.log.levels.WARN)
        end
      end, { desc = "Reload VSCode launch.json" })
      
      -- Auto-reload launch.json when it changes
      local function setup_launch_json_watcher()
        local launch_json_path = find_launch_json()
        if launch_json_path then
          -- Set up file watcher for launch.json changes
          vim.api.nvim_create_autocmd({"BufWritePost"}, {
            pattern = "launch.json",
            callback = function()
              vim.defer_fn(function()
                require('dap.ext.vscode').load_launchjs(launch_json_path, {
                  dart = {'dart', 'flutter'},
                  flutter = {'dart', 'flutter'},
                  node = {'javascript', 'typescript'},
                  python = {'python'},
                  go = {'go'},
                  rust = {'rust'},
                  cpp = {'cpp', 'c'},
                  java = {'java'}
                })
                vim.notify("Auto-reloaded launch.json configurations", vim.log.levels.INFO)
              end, 500)  -- Small delay to ensure file is written
            end,
            desc = "Auto-reload VSCode launch.json on save"
          })
        end
      end
      
      -- Set up the watcher
      setup_launch_json_watcher()
      
      -- Enhanced configuration selector
      vim.keymap.set('n', '<Leader>vl', function()
        local function find_project_root()
          local cwd = vim.fn.getcwd()
          local markers = {
            'pubspec.yaml',
            'package.json',
            '.git',
            '.vscode'
          }
          
          for _, marker in ipairs(markers) do
            if vim.fn.filereadable(cwd .. '/' .. marker) == 1 or vim.fn.isdirectory(cwd .. '/' .. marker) == 1 then
              return cwd
            end
          end
          
          local path = cwd
          while path ~= '/' do
            for _, marker in ipairs(markers) do
              if vim.fn.filereadable(path .. '/' .. marker) == 1 or vim.fn.isdirectory(path .. '/' .. marker) == 1 then
                return path
              end
            end
            path = vim.fn.fnamemodify(path, ':h')
          end
          
          return cwd
        end
        
        local project_root = find_project_root()
        local launch_json_path = project_root .. '/.vscode/launch.json'
        
        if vim.fn.filereadable(launch_json_path) == 0 then
          vim.notify("No .vscode/launch.json found in project: " .. project_root, vim.log.levels.WARN)
          vim.ui.input({ prompt = "Create basic launch.json? (y/n): " }, function(input)
            if input and input:lower() == 'y' then
              vim.cmd('edit ' .. launch_json_path)
            end
          end)
          return
        end
        
        -- Reload configurations
        require('dap.ext.vscode').load_launchjs(launch_json_path, {
          dart = {'dart', 'flutter'},
          flutter = {'dart', 'flutter'},
          node = {'javascript', 'typescript'},
          python = {'python'},
          go = {'go'},
          rust = {'rust'},
          cpp = {'cpp', 'c'},
          java = {'java'}
        })
        
        -- Get all available configurations with better sorting
        local current_ft = vim.bo.filetype
        local all_configs = {}
        
        -- Collect configurations from multiple file types, prioritizing current filetype
        local filetypes_to_check = {current_ft, 'dart', 'flutter'}
        
        for _, ft in ipairs(filetypes_to_check) do
          if dap.configurations[ft] then
            for _, config in ipairs(dap.configurations[ft]) do
              table.insert(all_configs, {
                config = config,
                filetype = ft,
                is_current_ft = ft == current_ft
              })
            end
          end
        end
        
        if #all_configs > 0 then
          -- Sort configurations: current filetype first, then by name
          table.sort(all_configs, function(a, b)
            if a.is_current_ft ~= b.is_current_ft then
              return a.is_current_ft
            end
            return (a.config.name or '') < (b.config.name or '')
          end)
          
          vim.ui.select(all_configs, {
            prompt = 'Select debug configuration (' .. vim.fn.fnamemodify(project_root, ':t') .. '):',
            format_item = function(item)
              local prefix = item.is_current_ft and '● ' or '  '
              local name = item.config.name or 'Unnamed'
              local type_info = '[' .. (item.config.type or 'unknown') .. ']'
              local args_info = ''
              
              if item.config.args and #item.config.args > 0 then
                args_info = ' (args: ' .. table.concat(item.config.args, ' ') .. ')'
              end
              
              return prefix .. name .. ' ' .. type_info .. args_info
            end,
          }, function(choice)
            if choice then
              local old_cwd = vim.fn.getcwd()
              vim.cmd('cd ' .. project_root)
              
              vim.notify("Starting debug session: " .. (choice.config.name or 'Unnamed'), vim.log.levels.INFO)
              dap.run(choice.config)
              
              vim.cmd('cd ' .. old_cwd)
            end
          end)
        else
          vim.notify("No launch configurations found. Check " .. launch_json_path, vim.log.levels.WARN)
          vim.ui.input({ prompt = "Open launch.json for editing? (y/n): " }, function(input)
            if input and input:lower() == 'y' then
              vim.cmd('edit ' .. launch_json_path)
            end
          end)
        end
      end, { desc = 'Select and run VSCode launch configuration' })
    end,
  },

  -- DAP UI
  {
    'rcarriga/nvim-dap-ui',
    dependencies = {
      'mfussenegger/nvim-dap',
      'nvim-neotest/nvim-nio',
    },
    config = function()
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
  },

  -- DAP Virtual Text
  {
    'theHamsta/nvim-dap-virtual-text',
    dependencies = {
      'mfussenegger/nvim-dap',
    },
    config = function()
      require('nvim-dap-virtual-text').setup()
    end,
  },
}, {
  ui = {
    border = "rounded",
  },
})

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
    status = status .. " Flutter"
    
    -- Flutterデバイス情報取得
    local device_info = vim.fn.system("flutter devices --machine 2>/dev/null")
    if vim.v.shell_error == 0 and device_info ~= "" then
      status = status .. " | Device Connected"
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

print("Flutter development environment loaded! (Enhanced Edition)")