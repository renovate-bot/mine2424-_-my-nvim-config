# Flutter開発用Neovim設定 🎯

高度なFlutter開発環境をNeovimで構築するための設定集です。Neovim 0.11+に最適化され、GitHub Copilot、Git統合、統合ターミナル、高度な診断機能など、本格的なIDE機能を提供します。

## ✨ 主な機能

- 🚀 **Flutter開発**: DAP統合デバッグ、ホットリロード、デバイス管理
- 🤖 **AI統合**: GitHub Copilot完全統合、Claude Code連携
- 🔌 **MCP統合**: Claude Code用MCP（GitHub、Context7、Playwright）サーバー
- 📊 **Git統合**: リアルタイム差分表示、インラインステージング（Gitsigns）
- 🎨 **モダンUI**: Treesitter構文ハイライト、Telescope検索、NvimTree
- 🖼️ **シンプルな3分割IDE**: ファイルツリー | エディタ | エディタ レイアウト
- 📝 **LSP**: Neovim 0.11+対応の強化されたLSP設定、インレイヒント対応
- 🖥️ **ターミナル統合**: Ghostty モダンターミナル設定
- 🐚 **モダンZsh**: wasabeef/dotfiles ベースの高機能Zsh設定
- 🛠️ **CLIツール**: eza, bat, lazygit等のモダンCLIツール
- ⚡ **高性能**: 遅延読み込み、最適化済み設定

## 🚀 クイックスタート

```bash
# 1. リポジトリクローン
git clone https://github.com/your-repo/my-nvim-config.git
cd my-nvim-config

# 2. 自動セットアップ
./scripts/setup.sh

# 3. 検証
./scripts/verify-setup.sh

# 4. Flutter プロジェクト開始
./scripts/create-flutter-project.sh my_app
cd my_app && nvim .
```

## 📋 主要コマンド

### Flutter開発
- `<leader>fr` - Flutter実行
- `<leader>fh` - ホットリロード  
- `<leader>fd` - デバイス一覧
- `<F5>` - デバッグ開始
- `<F1>` - ステップイン
- `<F2>` - ステップオーバー

### Git操作
- `]c` / `[c` - hunk移動
- `<leader>hs` - hunkステージ
- `<leader>hp` - hunkプレビュー
- `<leader>hb` - blame表示

### AI機能
- `Alt+l` - Copilot提案受け入れ
- `<leader>cc` - Copilotチャット
- `<leader>clc` - Claude トグル
- `<leader>clo` - Claude 開く

### 検索・ナビゲーション
- `<leader>ff` - ファイル検索
- `<leader>fg` - テキスト検索
- `<leader>fd` - 診断検索
- `s` - Flash 2文字ジャンプ
- `<leader>e` - ファイルツリー

### IDE操作
- `<leader>is` - 3分割IDEレイアウト起動
- `<leader>w1/2/3` - ウィンドウ1/2/3へ移動
- `<leader>qq` - IDE全体を終了
- `<leader>wqa` - 全て保存して終了

## 📚 詳細ドキュメント

- **[DOCS.md](DOCS.md)** - 完全ガイド（セットアップ、ワークフロー、キーバインド）
- **[FLUTTER_KEYBINDINGS.md](FLUTTER_KEYBINDINGS.md)** - 全キーバインドリファレンス
- **[CLAUDE.md](CLAUDE.md)** - AI開発者向け技術詳細
- **[MCP_SETUP.md](MCP_SETUP.md)** - MCP（Model Context Protocol）設定ガイド
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - トラブルシューティング

## 🔧 システム要件

- **Neovim** 0.11.0+ (推奨: 最新版)
- **Flutter** 3.0.0+
- **Git** 2.30.0+
- **Node.js** 16.0.0+ (Copilot用)
- **ripgrep** (高速検索用)
- **fd** (ファイル検索用)

## 📦 含まれる設定

- **Neovim**: 完全なFlutter開発環境
- **Zsh**: モダンなシェル設定（sheldon、プラグイン、エイリアス）
- **Ghostty**: モダンターミナル設定
- **Starship**: Flutter特化プロンプト
- **Claude Desktop**: 安全なコマンド実行設定
- **Claude Code MCP**: GitHub、Context7、Playwright統合
- **Scripts**: 自動セットアップツール

## 🤝 貢献

Issue報告やPull Requestを歓迎します。

## 📄 ライセンス

MIT License