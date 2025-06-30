# Flutter開発用Neovim設定 🎯

高度なFlutter開発環境をNeovimで構築するための設定集です。GitHub Copilot、Git統合、統合ターミナル、高度な診断機能など、本格的なIDE機能を提供します。

## ✨ 主な機能

### 🚀 Flutter開発
- **Flutter Tools**: フルサポートのFlutter開発環境
- **Dart LSP**: 完全なコード補完・診断・リファクタリング
- **デバッグサポート**: DAP統合によるフルデバッグ機能
- **VSCode統合**: launch.json自動読み込み・実行（2024年最適化済み）
- **ホットリロード**: `<leader>fh`でリアルタイム更新
- **デバイス管理**: エミュレータ・デバイス管理
- **カラープレビュー**: Flutterカラーのインライン表示

### 🤖 AI統合
- **GitHub Copilot**: コード自動補完
- **Copilot Chat**: エディタ内AI会話
- **コード説明・レビュー**: AI支援による開発

### 📊 Git統合
- **Gitsigns**: インライン差分表示・ステージング
- **Diffview**: サイドバイサイド差分表示
- **Neogit**: Magit風Git操作インターフェース
- **ブランチ情報**: ステータスライン表示

### 🛠️ IDE機能
- **統合ターミナル**: ToggleTerm with Flutter専用ターミナル
- **診断情報**: Trouble.nvimによる高度なエラー表示
- **プロジェクト検索**: Telescope fuzzy finder
- **TODO管理**: todo-comments.nvimでタスク追跡
- **キーバインドヘルプ**: which-key.nvimでコマンド発見

### 🎨 UI/UX
- **ステータスライン**: Lualineによる情報豊富な表示
- **タブライン**: Bufferlineによる美しいタブ管理
- **ファイルツリー**: NvimTreeによるプロジェクト探索
- **インデントガイド**: hlchunk.nvimによる高度なコードチャンク・インデント表示
- **コードハイライト**: 階層化されたインデントラインとコードブロック可視化

### ⚡ 効率化機能
- **高速移動**: Hop.nvimによるジャンプ
- **自動ペアリング**: 括弧・クォートの自動補完
- **スマートコメント**: Comment.nvimによる高度なコメント機能
- **テキスト操作**: nvim-surroundによる囲み操作

## 📦 設定ファイル

### 基本設定
- `lua/flutter-dev-minimal.lua` - 軽量版（フル機能）
- `lua/flutter-dev-with-dap.lua` - デバッグ機能付き
- `lua/flutter-dev-enhanced.lua` - 最新強化版

### スクリプト
- `scripts/setup-flutter-dev-env.sh` - 自動セットアップスクリプト
- `scripts/flutter-utils.sh` - Flutter開発ユーティリティ

## 🚀 クイックスタート

### 自動セットアップ（推奨）

```bash
# リポジトリをクローン
git clone https://github.com/your-username/my-nvim-config.git
cd my-nvim-config

# 自動セットアップを実行
chmod +x scripts/setup-flutter-dev-env.sh
./scripts/setup-flutter-dev-env.sh
```

### 手動セットアップ

1. **必要なソフトウェアをインストール**
```bash
brew install neovim wezterm tmux git ripgrep fd fzf
brew install --cask flutter
```

2. **設定ファイルを配置**
```bash
# 既存設定をバックアップ
mv ~/.config/nvim ~/.config/nvim.backup.$(date +%Y%m%d)

# 新しい設定を配置
mkdir -p ~/.config/nvim/lua
cp init.lua ~/.config/nvim/
cp -r lua/* ~/.config/nvim/lua/
```

3. **WezTerm設定**
```bash
cp wezterm.lua ~/.wezterm.lua
```

## 📖 使い方

### 基本的な開発フロー

1. **プロジェクトを開く**
```bash
cd your-flutter-project
nvim .
```

2. **Flutter開発を開始**
- `<leader>fd` - デバイス一覧表示
- `<leader>fe` - エミュレータ起動
- `<leader>fr` - Flutter実行
- `<leader>fh` - ホットリロード

3. **コード編集**
- LSPによる自動補完・エラー表示
- GitHub Copilotによるコード提案
- `<leader>ca` - コードアクション
- `<leader>rn` - リネーム

4. **Git操作**
- `<leader>gg` - Neogitでステータス確認
- `<leader>gd` - 差分表示
- `<leader>hs` - Hunkをステージング

### 主要キーバインド

| キー | 機能 |
|------|------|
| `<leader>ff` | ファイル検索 |
| `<leader>fg` | テキスト検索 |
| `<leader>e` | ファイルツリー |
| `<C-\>` | ターミナル |
| `<leader>xx` | 診断情報 |
| `<leader>cc` | Copilot Chat |

詳細なキーバインドは [FLUTTER_KEYBINDINGS.md](./FLUTTER_KEYBINDINGS.md) を参照してください。

## 📚 ドキュメント

- [📋 キーバインド一覧](./FLUTTER_KEYBINDINGS.md)
- [🔄 開発ワークフロー](./FLUTTER_WORKFLOW.md)
- [📊 lualine.nvim 設定ガイド](./LUALINE_GUIDE.md) **NEW!**
- [🌈 hlchunk.nvim 使用ガイド](./HLCHUNK_GUIDE.md)
- [🚀 VSCode統合アップデート](./VSCODE_INTEGRATION_UPDATE.md)
- [🔧 トラブルシューティング](./TROUBLESHOOTING.md)
- [⚙️ 設定ガイド](./CONFIG_GUIDE.md)

## 🛠️ カスタマイズ

### プラグインの有効/無効

特定のプラグインを無効にする場合：

```lua
-- lua/flutter-dev-minimal.lua内で
{
  'plugin-name',
  enabled = false,  -- プラグインを無効化
  -- ... 設定
}
```

### キーバインドのカスタマイズ

```lua
-- カスタムキーマップを追加
vim.keymap.set('n', '<your-key>', '<command>', { desc = 'Your description' })
```

### テーマの変更

```lua
-- Lualineテーマの変更
require('lualine').setup {
  options = {
    theme = 'your-preferred-theme'  -- auto, gruvbox, etc.
  }
}
```

## 🔧 システム要件

### 必須
- Neovim 0.9.0+
- Node.js 18+ (Copilot用)
- Git
- Flutter SDK

### 推奨
- WezTerm (ターミナル)
- ripgrep (高速検索)
- fd (高速ファイル検索)
- fzf (ファジーファインダー)

### OS サポート
- ✅ macOS (完全サポート)
- ⚠️ Linux (手動セットアップ)
- ⚠️ Windows (WSL推奨)

## 🚨 トラブルシューティング

### よくある問題

**プラグインが読み込まれない**
```bash
# lazy.nvimを更新
:Lazy sync
```

**Copilotが動作しない**
```bash
# Copilotにログイン
:Copilot auth
```

**Flutter LSPが起動しない**
```bash
# Flutter doctorで環境確認
flutter doctor -v
```

詳細は [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) を参照してください。

## 🔄 アップデート

```bash
# 設定を更新
cd my-nvim-config
git pull origin main

# プラグインを更新
nvim -c "Lazy sync" -c "qa"
```

## 🤝 コントリビューション

1. このリポジトリをフォーク
2. 機能ブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add amazing feature'`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成

## 📄 ライセンス

MIT License - 詳細は [LICENSE](./LICENSE) ファイルを参照してください。

## 🙏 謝辞

以下のプロジェクトに感謝します：
- [akinsho/flutter-tools.nvim](https://github.com/akinsho/flutter-tools.nvim)
- [zbirenbaum/copilot.lua](https://github.com/zbirenbaum/copilot.lua)
- [lewis6991/gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)
- その他多数の素晴らしいNeovimプラグイン

---

**Happy Flutter Development with Neovim! 🎯✨**