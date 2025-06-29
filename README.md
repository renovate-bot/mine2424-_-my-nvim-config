# Flutter開発最適化済み Development Environment

## 📖 概要

**WezTerm + Neovim + Flutter開発環境**に最適化された包括的な設定集です。モダンなFlutter開発ワークフローを実現し、IDE級の機能をターミナルベースで提供します。

## 📁 ファイル構成

```
├── README.md                    # このファイル
├── FLUTTER_WORKFLOW.md          # 🎯 Flutter開発ワークフロー完全ガイド
├── FLUTTER_KEYBINDINGS.md       # ⌨️ Flutter開発キーバインド一覧
├── NEOVIM_CONFIG.md             # Neovim設定の詳細説明
├── WEZTERM_CONFIG.md            # WezTerm設定の詳細説明
├── init.lua                     # Neovim メイン設定ファイル
├── wezterm.lua                  # WezTerm設定ファイル（Flutter最適化済み）
├── lua/
│   ├── base.lua                # Neovim基本設定
│   ├── maps.lua                # キーマップ設定（Flutter専用追加）
│   ├── plugins.lua             # 自動化・ファイルタイプ設定
│   ├── flutter-dev-minimal.lua # 🚀 Flutter開発環境設定（安定版・DAP無効）
│   └── flutter-dev-with-dap.lua # 🚀 Flutter開発環境設定（DAP機能付き・上級者向け）
└── scripts/
    ├── flutter-dev-setup.sh    # Flutter プロジェクト自動セットアップ
    └── flutter-utils.sh         # Flutter 開発ユーティリティ
```

## ✨ 主な特徴

### 🎯 **統合開発環境**
- **WezTerm**: GPU加速対応、tmux統合ターミナル
- **Neovim**: プラグインレス、高機能エディタ
- **tmux**: セッション管理とウィンドウ操作
- **🚀 IDE風レイアウト**: ワンコマンドでIDE級の画面分割

### ⚡ **開発効率化**
- **言語別自動設定**: JS/TS/Python/Dart/Flutter対応
- **キーバインド最適化**: 直感的で覚えやすい操作
- **視覚的改善**: 相対行番号、カーソルライン、不可視文字表示
- **スマートレイアウト**: プロジェクトタイプを自動判定して最適なIDE環境を構築

### 🛠️ **Flutter開発特化**
- **🎯 flutter-tools.nvim**: 包括的なFlutter/Dart LSP統合
- **⚡ ホットリロード**: `Cmd+Shift+H`で即座にリロード
- **🖥️ 自動ワークスペース**: Flutterプロジェクト検出で専用レイアウト作成
- **🔧 自動化スクリプト**: プロジェクト作成からデプロイまで自動化
- **🐛 統合デバッグ**: nvim-dap連携でブレークポイント・ステップ実行（オプション・上級者向け）
- **📱 デバイス管理**: エミュレータ起動・デバイス切り替えをNeovim内で

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
- **🎯 IDE風レイアウト**: プロジェクト自動判定機能付きワンコマンドIDE環境

## 🚀 クイックスタート

### ⚡ 自動セットアップ（推奨）

**完全自動インストール（macOS）**
```bash
# リポジトリをクローン
git clone <repository-url> ~/flutter-dev-config
cd ~/flutter-dev-config

# 🎯 ワンコマンドセットアップ
./scripts/setup-flutter-dev-env.sh
```

**軽量セットアップ（Neovim既存ユーザー）**
```bash
# 設定ファイルのみ配置（WezTerm Claude統合機能も含む）
./scripts/quick-setup.sh
```

### 🔧 手動セットアップ

<details>
<summary>手動でセットアップする場合（クリックして展開）</summary>

#### 1. 前提条件のインストール
```bash
# macOS (Homebrew)
brew install neovim wezterm tmux git ripgrep fd fzf
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono flutter
```

#### 2. 設定ファイルの配置
```bash
# 既存設定をバックアップ
mv ~/.config/nvim ~/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)
mv ~/.wezterm.lua ~/.wezterm.lua.backup.$(date +%Y%m%d_%H%M%S)

# 設定ファイルを配置
mkdir -p ~/.config/nvim/lua
cp init.lua ~/.config/nvim/
cp -r lua/ ~/.config/nvim/
cp wezterm.lua ~/.wezterm.lua
```

#### 3. 動作確認
```bash
# WezTermを起動
open -a WezTerm

# Neovimでプラグイン自動インストール
nvim  # 初回起動時にプラグインが自動インストール

# Flutter環境確認
flutter doctor
```

</details>

### 📋 他のOSでのセットアップ

**Linux・Windows** → **[詳細セットアップガイド](SETUP_GUIDE.md)** を参照

## ⌨️ 基本的な使い方

### WezTermショートカット
| キー | 機能 |
|-----|------|
| `Cmd + T` | 新しいタブ |
| `Cmd + D` | 水平分割 |
| `Cmd + Shift + R` | flutter run |
| `Cmd + Shift + H` | ホットリロード |
| `Cmd + Shift + Q` | Flutterアプリ終了 |
| `Cmd + Alt + F` | Flutter専用ワークスペース作成 |
| `Cmd + K` | ターミナルクリア |

### Neovimキーマップ（リーダー: Space）
| キー | 機能 |
|-----|------|
| `Space w` | ファイル保存 |
| `ss` / `sv` | ウィンドウ分割 |
| `Space T` | ターミナル起動 |
| `jj` / `kk` | Insert mode脱出 |
| `Space Fr` | Flutter実行 |
| `Space Fh` | ホットリロード |
| `Space Ft` | Flutterテスト |
| `gd` | 定義にジャンプ（LSP） |

### 🚀 IDE風レイアウト（新機能）
| キー | 機能 |
|-----|------|
| `Space ide` | **スマートIDE起動**（プロジェクト自動判定） |
| `Space I` | フルIDEレイアウト（ファイルツリー+エディタ+ターミナル） |
| `Space is` | シンプルIDEレイアウト（ファイルツリー+エディタ） |
| `Space if` | Flutter専用IDEレイアウト |
| `Space ir` | レイアウトリセット |
| `Space e` | ファイルツリー切り替え |
| `Space E` | ファイルエクスプローラー（現在のウィンドウ） |

## 📚 詳細ドキュメント

### 🎯 Flutter開発者向け（**まずこちらを読んでください**）

- **[🚀 Flutter開発ワークフロー](./FLUTTER_WORKFLOW.md)** - Flutter開発の完全ガイド
- **[⌨️ Flutter キーバインド一覧](./FLUTTER_KEYBINDINGS.md)** - 開発で使用する全キーバインド

### 📖 設定詳細

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

### デバッグ機能の有効化（上級者向け）
```lua
-- ~/.config/nvim/init.lua で以下を変更
-- DAP機能なし版（安定版）
-- require('flutter-dev-minimal')

-- DAP機能付き版を使用したい場合は、上記をコメントアウトして以下を有効にする
require('flutter-dev-with-dap')
```

**重要**: デバッグ機能は依存関係が複雑で、`nvim-nio`の依存問題が発生する可能性があります。
問題が発生した場合は、安定版(`flutter-dev-minimal`)に戻してください。

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

**1. プラグインのインストールエラー**
```bash
# lazy.nvimキャッシュのクリア
rm -rf ~/.local/share/nvim/lazy/
rm -rf ~/.local/share/nvim/lazy-lock.json

# Neovimを再起動してプラグインを再インストール
nvim
```

**2. nvim-dap-ui エラー（"nvim-nio required"）**
```bash
# DAP機能の依存問題が発生した場合
# 安定版に切り替え
# ~/.config/nvim/init.lua で以下を確認：
# require('flutter-dev-minimal')  # 安定版を使用

# キャッシュをクリア
rm -rf ~/.local/share/nvim/lazy && rm -rf ~/.cache/nvim

# Neovimを再起動
nvim
```

**3. WezTermでtmuxが起動しない**
```bash
# tmuxのパス確認
which tmux

# wezterm.luaのパス修正
config.default_prog = { '/usr/local/bin/tmux', '...' }
```

**4. フォントが表示されない**
```bash
# フォント再インストール
brew reinstall --cask font-jetbrains-mono
```

**5. Neovimの設定エラー**
```bash
# 設定の構文確認
nvim --clean -c "luafile ~/.config/nvim/init.lua"

# セットアップテストの実行
./scripts/test-setup.sh
```

## 📄 ライセンス

MIT License - 自由にカスタマイズしてご利用ください。

## 🤝 コントリビューション

改善提案やバグ報告は Issues でお知らせください。
