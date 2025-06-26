# My Development Environment Configuration

## 📖 概要

tmux + Neovim + Flutter開発環境に最適化された設定集です。WezTermとNeovimの包括的な設定により、効率的な開発ワークフローを提供します。

## 📁 ファイル構成

```
├── README.md               # このファイル
├── NEOVIM_CONFIG.md       # Neovim設定の詳細説明
├── WEZTERM_CONFIG.md      # WezTerm設定の詳細説明
├── init.lua               # Neovim メイン設定ファイル
├── wezterm.lua            # WezTerm設定ファイル
└── lua/
    ├── base.lua           # Neovim基本設定
    ├── maps.lua           # キーマップ設定
    └── plugins.lua        # 自動化・ファイルタイプ設定
```

## ✨ 主な特徴

### 🎯 **統合開発環境**
- **WezTerm**: GPU加速対応、tmux統合ターミナル
- **Neovim**: プラグインレス、高機能エディタ
- **tmux**: セッション管理とウィンドウ操作

### ⚡ **開発効率化**
- **言語別自動設定**: JS/TS/Python/Dart/Flutter対応
- **キーバインド最適化**: 直感的で覚えやすい操作
- **視覚的改善**: 相対行番号、カーソルライン、不可視文字表示

### 🛠️ **Flutter開発特化**
- **クイックコマンド**: `Cmd+Shift+R`でflutter run
- **環境変数設定**: Android SDK、Java自動設定
- **ハイパーリンク**: エラーメッセージから直接ファイルジャンプ

## ⚙️ 設定内容

### WezTerm設定
- **GPU加速**: WebGPU使用で高パフォーマンス
- **tmux統合**: 自動セッション起動
- **透明度**: 95%背景透明度 + macOS Blur効果
- **フォント**: JetBrains Mono + ligatures対応

### Neovim設定
- **プラグインレス**: 標準機能のみで軽量動作
- **カスタムステータスライン**: モード・ファイル・位置表示
- **自動化機能**: ファイル保存時の空白削除、カーソル位置復元
- **言語別設定**: ファイルタイプに応じた自動インデント

## 🚀 クイックスタート

### 1. 前提条件のインストール
```bash
# macOS (Homebrew)
brew install neovim wezterm tmux
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono

# Flutter開発の場合
brew install --cask flutter
```

### 2. 設定ファイルの配置
```bash
# 既存設定をバックアップ
mv ~/.config/nvim ~/.config/nvim.backup
mv ~/.wezterm.lua ~/.wezterm.lua.backup

# 設定ファイルを配置
mkdir -p ~/.config/nvim/lua
cp init.lua ~/.config/nvim/
cp -r lua/ ~/.config/nvim/
cp wezterm.lua ~/.wezterm.lua
```

### 3. 動作確認
```bash
# WezTermを起動（自動的にtmuxセッション開始）
open -a WezTerm

# Neovimの設定確認
nvim +checkhealth
```

## ⌨️ 基本的な使い方

### WezTermショートカット
| キー | 機能 |
|-----|------|
| `Cmd + T` | 新しいタブ |
| `Cmd + D` | 水平分割 |
| `Cmd + Shift + R` | flutter run |
| `Cmd + K` | ターミナルクリア |

### Neovimキーマップ（リーダー: Space）
| キー | 機能 |
|-----|------|
| `Space w` | ファイル保存 |
| `ss` / `sv` | ウィンドウ分割 |
| `Space T` | ターミナル起動 |
| `jj` / `kk` | Insert mode脱出 |

## 📚 詳細ドキュメント

各設定の詳細については、以下のドキュメントを参照してください：

- **[Neovim設定詳細](./NEOVIM_CONFIG.md)** - エディタ設定の包括的ガイド
- **[WezTerm設定詳細](./WEZTERM_CONFIG.md)** - ターミナル設定とFlutter開発機能

## 🔧 カスタマイズ

### よく使うカスタマイズ例

**フォントサイズ変更**
```lua
-- wezterm.lua
config.font_size = 16.0  -- お好みのサイズ
```

**カラースキーム変更**
```lua
-- wezterm.lua  
config.color_scheme = 'Dracula'  -- お好みのテーマ
```

**Neovimインデント設定**
```lua
-- lua/base.lua
vim.opt.shiftwidth = 4  -- 4スペースに変更
vim.opt.tabstop = 4
```

### 開発言語の追加
```lua
-- lua/plugins.lua に追加
autocmd('FileType', {
  pattern = { 'go' },
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
  end,
  desc = 'Go specific settings'
})
```

## 🔗 推奨追加ツール

### 開発効率をさらに向上させるツール
```bash
# Git管理強化
brew install gh               # GitHub CLI
brew install git-delta        # 美しいdiff表示

# ファイル検索・管理
brew install ripgrep          # 高速grep
brew install fd               # 高速find
brew install fzf              # ファジーファインダー

# コード整形
npm install -g prettier       # JavaScript/JSON整形
pip install black             # Python整形
```

### LSPサーバー（高度な編集機能）
```bash
# JavaScript/TypeScript
npm install -g typescript-language-server

# Python  
pip install python-lsp-server

# Dart/Flutter (Flutter SDKに含まれる)
# 追加設定不要
```

## 🆘 トラブルシューティング

### よくある問題

**1. WezTermでtmuxが起動しない**
```bash
# tmuxのパス確認
which tmux

# wezterm.luaのパス修正
config.default_prog = { '/usr/local/bin/tmux', '...' }
```

**2. フォントが表示されない**
```bash
# フォント再インストール
brew reinstall --cask font-jetbrains-mono
```

**3. Neovimの設定エラー**
```bash
# 設定の構文確認
nvim --clean -c "luafile ~/.config/nvim/init.lua"
```

## 📄 ライセンス

MIT License - 自由にカスタマイズしてご利用ください。

## 🤝 コントリビューション

改善提案やバグ報告は Issues でお知らせください。
