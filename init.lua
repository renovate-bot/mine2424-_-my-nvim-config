-- Neovim設定
require('base')
require('maps')
require('plugins')

-- IDE風レイアウト設定
require('ide-layout').setup()

-- Flutter開発環境設定
-- DAP機能なし版（安定版）
-- require('flutter-dev-minimal')

-- DAP機能付き版を使用したい場合は、上記をコメントアウトして以下を有効にしてください
require('flutter-dev-with-dap')

-- Flutter開発に最適化されたhlchunk.nvim設定
-- Doc: https://github.com/shellRaining/hlchunk.nvim
require("hlchunk").setup({
  chunk = {
    enable = true,
    notify = true,
    use_treesitter = true,
    style = {
      -- Flutter開発に適した視覚的なコードチャンクハイライト
      "#806d9c",  -- メインチャンクカラー（薄紫）
      "#c21f30",  -- エラーチャンク用（赤）
    },
    chars = {
      horizontal_line = "─",
      vertical_line = "│",
      left_top = "╭",
      left_bottom = "╰",
      right_arrow = "─",
    },
    textobject = "",
    max_file_size = 1024 * 1024,  -- 1MB制限
    error_sign = true,
  },
  indent = {
    enable = true,
    use_treesitter = false,
    style = {
      -- Flutterの深いネスト構造に適したインデントライン
      "#434C5E",  -- 通常のインデント（ダークグレー）
      "#4C566A",  -- レベル2インデント
      "#5E81AC",  -- レベル3インデント（青）
      "#88C0D0",  -- レベル4インデント（シアン）
      "#81A1C1",  -- レベル5インデント（青）
      "#8FBCBB",  -- レベル6インデント（緑がかった青）
    },
    chars = {
      "│",  -- 縦線
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
    style = "#806d9c",  -- 行番号ハイライト
    use_treesitter = true,
  },
  blank = {
    enable = true,
    style = {
      "#434C5E",  -- 空行スタイル
    },
    chars = {
      "․",  -- 空行文字
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

