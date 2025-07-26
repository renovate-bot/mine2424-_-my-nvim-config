# Flutter開発用Neovim設定 🎯

高度なFlutter開発環境をNeovimで構築するための設定集です。Neovim 0.11+に最適化され、GitHub Copilot、Git統合、統合ターミナル、高度な診断機能など、本格的なIDE機能を提供します。

## ✨ 主な機能

- 🚀 **Flutter開発**: DAP統合デバッグ、ホットリロード、デバイス管理
- 🤖 **AI統合**: GitHub Copilot完全統合、Claude Code連携
- 🔌 **アダプティブMCP統合**: 環境に応じて自動検出・設定されるMCPサーバー（GitHub、Context7、Playwright、Debug Thinking）
- 📊 **Git統合**: リアルタイム差分表示、インラインステージング（Gitsigns）
- 🎨 **モダンUI**: Treesitter構文ハイライト、Telescope検索、NvimTree、Markdownレンダリング
- 🖼️ **シンプルな3分割IDE**: ファイルツリー | エディタ | エディタ レイアウト
- 📝 **LSP**: Neovim 0.11+対応の強化されたLSP設定、インレイヒント対応
- 🖥️ **ターミナル統合**: Ghostty モダンターミナル設定
- 🐚 **モダンZsh**: wasabeef/dotfiles ベースの高機能Zsh設定
- 🛠️ **CLIツール**: eza, bat, lazygit等のモダンCLIツール
- 📦 **pnpm**: 高速パッケージマネージャーとワークスペース対応
- ⚡ **高性能**: 遅延読み込み、最適化済み設定

## 🚀 クイックスタート

```bash
# 1. リポジトリクローン
git clone https://github.com/your-repo/my-nvim-config.git
cd my-nvim-config

# 2. 自動セットアップ（設定ファイルのみ - 安全なデフォルト）
./scripts/setup.sh

# フル機能インストール（ツール含む）
./scripts/setup.sh --full

# または個別セットアップ
./scripts/setup.sh pnpm-only      # pnpmのみ
./scripts/setup.sh starship-only  # Starshipのみ
./scripts/setup.sh quick          # 設定ファイルのみ（依存関係は手動インストール済みと仮定）

# 3. 検証
./scripts/verify-setup.sh

# 4. Flutter プロジェクト開始
./scripts/flutter.sh create my_app
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

### Markdown
- `<leader>mr` - Markdownレンダリング切り替え
- `<leader>me` - Markdownレンダリング有効化
- `<leader>md` - Markdownレンダリング無効化

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
- **pnpm** 8.0.0+ (オプション、JavaScript開発用)

## 📦 含まれる設定

- **Neovim**: 完全なFlutter開発環境
- **Zsh**: モダンなシェル設定（sheldon、プラグイン、エイリアス）
- **Ghostty**: モダンターミナル設定
- **Starship**: Flutter特化プロンプト
- **Claude Desktop**: 安全なコマンド実行設定
- **Claude Code MCP**: GitHub、Context7、Playwright統合
- **pnpm**: ワークスペース対応パッケージマネージャー設定
- **Scripts**: 整理された開発ツール（setup.sh、flutter.sh、pnpm.sh、mcp.sh）

## 🔧 セットアップオプション

### メインセットアップ（setup.sh）
```bash
./scripts/setup.sh              # 設定ファイルのみ（安全なデフォルト）
./scripts/setup.sh --full       # 全機能インストール
./scripts/setup.sh quick        # 設定ファイルのみ
./scripts/setup.sh starship-only # Starshipのみ
./scripts/setup.sh pnpm-only    # pnpmのみ
./scripts/setup.sh mcp-only     # MCPサーバーのみ
```

オプション：
- `--no-starship` - Starshipをスキップ
- `--no-flutter` - Flutterをスキップ
- `--no-pnpm` - pnpmをスキップ
- `--dry-run` - 実行内容の確認のみ

### ユーティリティスクリプト
```bash
# Flutter開発
./scripts/flutter.sh create myapp  # 新規プロジェクト作成
./scripts/flutter.sh setup         # 既存プロジェクトセットアップ
./scripts/flutter.sh test          # テスト実行
./scripts/flutter.sh build apk     # ビルド

# パッケージマネージャー
./scripts/pnpm.sh install   # pnpmインストール
./scripts/pnpm.sh migrate   # npm/yarnからの移行

# MCP設定
./scripts/mcp.sh            # アダプティブMCPセットアップ
```

## 📦 pnpmワークスペース

JavaScript/TypeScriptプロジェクト用のワークスペース構造：
```
packages/    # 共有パッケージ
apps/        # アプリケーション
tools/       # 開発ツール
examples/    # サンプルプロジェクト
```

## 🤝 貢献

Issue報告やPull Requestを歓迎します。

## 📄 ライセンス

MIT License