# Flutter開発用Neovim設定 🎯

高度なFlutter開発環境をNeovimで構築するための設定集です。GitHub Copilot、Git統合、統合ターミナル、高度な診断機能など、本格的なIDE機能を提供します。

## ✨ 主な機能

- 🚀 **Flutter開発**: DAP統合デバッグ、ホットリロード、デバイス管理
- 🤖 **AI統合**: GitHub Copilot完全統合
- 🔌 **MCP統合**: Claude Code用MCP（GitHub、Context7、Playwright）サーバー
- 📊 **Git統合**: リアルタイム差分表示、インラインステージング
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

### Git操作
- `]c` / `[c` - hunk移動
- `<leader>hs` - hunkステージ
- `<leader>hp` - hunkプレビュー

### AI機能
- `Alt+l` - Copilot提案受け入れ
- `<leader>cc` - Copilotチャット

## 📚 詳細ドキュメント

- **[DOCS.md](DOCS.md)** - 完全ガイド（セットアップ、ワークフロー、キーバインド）
- **[CLAUDE.md](CLAUDE.md)** - AI開発者向け技術詳細
- **[MCP_SETUP.md](MCP_SETUP.md)** - MCP（Model Context Protocol）設定ガイド
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - トラブルシューティング

## 🔧 システム要件

- **Neovim** 0.9.0+
- **Flutter** 3.0.0+
- **Git** 2.30.0+
- **Node.js** 16.0.0+ (Copilot用)

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