# Claude Monitor MCP Setup Guide (日本語版)

このガイドは、[Zenn記事](https://zenn.dev/karaage0703/articles/3bd2957807f311)を参考に、Claude CodeにMCP（Model Context Protocol）サーバーを簡単に追加する方法を説明します。

## 概要

MCP（Model Context Protocol）は、Claude Codeの機能を拡張するプロトコルです。MCPサーバーを追加することで、Claude Codeから様々な外部ツールやサービスにアクセスできるようになります。

## クイックセットアップ

### 1. 基本的なMCPセットアップ（推奨）

最も簡単な方法は、メインのセットアップスクリプトを使用することです：

```bash
# フルセットアップ（すべてのコンポーネントを含む）
./scripts/setup.sh

# MCPのみセットアップ（他のコンポーネントは既にインストール済みの場合）
./scripts/setup-mcp.sh
```

### 2. Claude Monitor専用セットアップ

Claude Monitorや追加のMCPサーバーをインタラクティブにセットアップしたい場合：

```bash
# Claude Monitor専用のセットアップスクリプト
./scripts/setup-claude-monitor.sh
```

このスクリプトでは以下の機能が利用できます：
- Claude Monitor MCPサーバーの自動インストール
- 追加のMCPサーバーの選択的インストール（GitHub、ArXiv、Markitdownなど）
- 日本語のインタラクティブなメニュー

## 利用可能なMCPサーバー

### デフォルトで設定されるサーバー（setup.sh使用時）

1. **GitHub MCP** - GitHubリポジトリの操作
2. **Context7 MCP** - コンテキスト管理
3. **Playwright MCP** - ブラウザ自動化
4. **Debug Thinking MCP** - デバッグ支援

### 追加で利用可能なサーバー（setup-claude-monitor.sh使用時）

5. **Claude Monitor MCP** - Claude Codeのモニタリング
6. **ArXiv MCP** - 論文検索
7. **Markitdown MCP** - PDF/PPTXをMarkdownに変換
8. **YouTube MCP** - YouTube動画分析

## 手動でMCPサーバーを追加する方法

Claude CLIを使用して、手動でMCPサーバーを追加することもできます：

```bash
# 基本的な構文
claude mcp add <サーバー名> -s <スコープ> -- <実行コマンド>

# 例：GitHub MCPサーバーを追加
claude mcp add github -s local -- npx -y @modelcontextprotocol/server-github

# 例：ArXiv MCPサーバーを追加
claude mcp add arxiv -s local -- npx -y @modelcontextprotocol/server-arxiv
```

### スコープの説明

- `local`: 現在のプロジェクトのみ（~/.claude.jsonに保存）
- `project`: プロジェクト固有（.mcp.jsonに保存）
- `user`: グローバルに使用可能（~/.claude.jsonに保存）

## 環境変数の設定

一部のMCPサーバーは環境変数の設定が必要です：

### GitHub MCP

```bash
# ~/.zshrc.localまたは~/.bashrc.localに追加
export GITHUB_PERSONAL_ACCESS_TOKEN='your-github-token-here'
```

GitHubトークンの作成方法：
1. [GitHub Settings > Tokens](https://github.com/settings/tokens)にアクセス
2. "Generate new token"をクリック
3. 必要なスコープを選択：`repo`, `read:org`, `read:user`

### プロキシ設定

企業環境などでプロキシを使用する場合：

```bash
export HTTP_PROXY='http://proxy.example.com:8080'
export HTTPS_PROXY='http://proxy.example.com:8080'
export NO_PROXY='localhost,127.0.0.1'
```

## MCPサーバーの確認と管理

### 設定されているサーバーの確認

```bash
# 現在設定されているMCPサーバーを表示
claude mcp list
```

### サーバーの削除

```bash
# MCPサーバーを削除
claude mcp remove <サーバー名>

# 例：GitHub MCPサーバーを削除
claude mcp remove github
```

## Claude Code内でのMCPの使用

1. Claude Codeを起動
2. チャット内で `/mcp` と入力
3. 利用可能なMCPツールが表示されます
4. 各ツールを選択して使用

## トラブルシューティング

### よくある問題と解決方法

1. **「claude: command not found」エラー**
   ```bash
   npm install -g @anthropic-ai/claude-code
   ```

2. **「npm: command not found」エラー**
   - Node.jsをインストールしてください
   - macOS: `brew install node`
   - Ubuntu: `sudo apt install nodejs npm`

3. **MCPサーバーが動作しない**
   - Claude Codeを再起動してください
   - 環境変数が正しく設定されているか確認
   - `claude mcp list`でサーバーが表示されるか確認

4. **プロキシ環境での問題**
   - プロキシ設定を確認
   - `NO_PROXY`に必要なホストを追加

## 参考リンク

- [Zenn記事 - Claude CodeのMCP設定](https://zenn.dev/karaage0703/articles/3bd2957807f311)
- [MCP公式ドキュメント](https://github.com/modelcontextprotocol)
- [Claude Code公式サイト](https://claude.ai/code)

## まとめ

このセットアップスクリプトを使用することで、Claude CodeにMCPサーバーを簡単に追加できます。特に`setup-claude-monitor.sh`は日本語のインタラクティブなメニューを提供し、必要なMCPサーバーを選択的にインストールできるため、初心者にも使いやすくなっています。