# Flutter開発ワークフロー完全ガイド 🔄

このガイドでは、Neovim + Flutter環境での効率的な開発ワークフローを詳しく説明します。

## 📋 目次

- [開発環境の起動](#開発環境の起動)
- [新規プロジェクト開発](#新規プロジェクト開発)
- [既存プロジェクト開発](#既存プロジェクト開発)
- [日常的な開発作業](#日常的な開発作業)
- [デバッグ・テスト](#デバッグテスト)
- [リファクタリング](#リファクタリング)
- [Git操作](#git操作)
- [パフォーマンス最適化](#パフォーマンス最適化)
- [トラブルシューティング](#トラブルシューティング)

---

## 開発環境の起動

### 🚀 基本的な起動手順

1. **ターミナルを開く**
   ```bash
   # WezTermを使用する場合
   open -a WezTerm
   ```

2. **プロジェクトディレクトリに移動**
   ```bash
   cd /path/to/your/flutter/project
   ```

3. **Neovimでプロジェクトを開く**
   ```bash
   nvim .
   ```

4. **Flutter環境の確認**
   - 自動的にFlutter LSPが起動します
   - ステータスラインでFlutter環境を確認

### 📱 Flutter開発環境の確認

初回起動時に以下を確認：

```bash
# Neovim内で実行
:checkhealth
```

以下の項目をチェック：
- ✅ Flutter SDK
- ✅ Dart LSP
- ✅ プラグインの正常動作

### 📊 ステータスライン情報の確認

lualine.nvimによる開発状況の監視：
- **🎯 Flutter**: プロジェクトタイプの確認
- **⚡ dartls**: LSPクライアントの動作状況
- **🔷 3.7.0**: Dartバージョンの確認
- **🤖 Ready**: Copilot利用可能状況
- **🚨 ⚠️ 💡**: 診断情報（エラー・警告・情報）

---

## 新規プロジェクト開発

### 📦 新規プロジェクト作成

1. **プロジェクト作成コマンド**
   ```bash
   # ターミナルまたはNeovim内で
   flutter create my_awesome_app
   cd my_awesome_app
   nvim .
   ```

2. **または、Neovim内から**
   ```
   <leader>Fn  # Flutter新規プロジェクト作成
   ```

### 🎯 初期設定ワークフロー

1. **ファイルツリーを表示**
   ```
   <leader>e
   ```

2. **プロジェクト構造を確認**
   ```
   lib/
   ├── main.dart
   └── [他のファイル]
   ```

3. **依存関係の確認**
   ```
   <leader>ff  # pubspec.yamlを検索・開く
   ```

4. **最初のビルド・実行**
   ```
   <leader>fr  # Flutter実行
   ```

### 📋 プロジェクトテンプレートの設定

推奨されるプロジェクト構造：

```
lib/
├── main.dart
├── models/          # データモデル
├── screens/         # 画面
├── widgets/         # 再利用可能なウィジェット
├── services/        # API・サービス層
├── utils/           # ユーティリティ
└── constants/       # 定数
```

---

## 既存プロジェクト開発

### 🔍 プロジェクト理解フロー

1. **プロジェクトを開く**
   ```bash
   cd existing_project
   nvim .
   ```

2. **プロジェクト構造を把握**
   ```
   <leader>e       # ファイルツリー表示
   <leader>fs      # シンボル検索
   <leader>fw      # ワークスペースシンボル検索
   ```

3. **エントリーポイントから理解**
   ```
   <leader>ff      # main.dartを検索
   gd              # 定義へジャンプ
   gr              # 参照箇所を確認
   ```

4. **依存関係の確認**
   ```bash
   flutter pub get  # 依存関係をインストール
   ```

### 📱 既存プロジェクトのセットアップ

1. **環境の確認**
   ```bash
   flutter doctor
   flutter pub get
   ```

2. **最初の実行**
   ```
   <leader>fd      # デバイス確認
   <leader>fr      # 実行
   ```

3. **エラーがある場合**
   ```
   <leader>xx      # Troubleで診断確認
   <leader>e       # 診断詳細表示
   ```

---

## 日常的な開発作業

### ✏️ 効率的なコーディング

1. **ファイル間の移動**
   ```
   <leader>ff      # ファイル検索
   <leader>fg      # テキスト検索
   <Tab>/<S-Tab>   # バッファ切り替え
   ```

2. **コード編集**
   ```
   # 自動補完
   <C-Space>       # 手動で補完表示
   <Tab>           # 次の候補
   <CR>            # 補完確定
   
   # LSP機能
   K               # ホバー情報
   gd              # 定義へジャンプ
   gr              # 参照一覧
   <leader>ca      # コードアクション
   <leader>rn      # リネーム
   ```

3. **AI支援機能**
   ```
   <leader>cc      # Copilot Chat開く
   <leader>ce      # コード説明
   <leader>ct      # テスト生成
   <leader>cr      # コードレビュー
   <M-l>           # Copilot提案受け入れ
   ```

4. **コード整形**
   ```
   # 自動整形（保存時）
   :w              # 保存時に自動フォーマット
   ```

### 🔄 ホットリロード開発

1. **基本的なホットリロードフロー**
   ```
   <leader>fr      # Flutter実行
   # コード編集
   <leader>fh      # ホットリロード
   ```

2. **状態リセットが必要な場合**
   ```
   <leader>fR      # ホットリスタート
   ```

3. **ログの確認**
   ```
   <leader>fc      # ログクリア
   <leader>tf      # Flutter専用ターミナル
   <C-\>           # フローティングターミナル
   ```

### 🎨 UI開発ワークフロー

1. **ウィジェット階層の理解**
   ```
   <leader>fo      # Flutterアウトライン表示
   ```

2. **視覚的コード構造の活用**
   - **hlchunk.nvim機能**: カーソル位置に応じた自動インデント・チャンクハイライト
   - **階層化表示**: Flutterの深いネスト構造を6段階のカラーで可視化
   - **コードチャンク**: 現在のコードブロックの範囲を明確に表示
   - **エラー検知**: 不正なブロック構造を視覚的にハイライト

3. **ウィジェット操作**
   ```
   <leader>Fw      # ウィジェットをラップ
   <leader>ca      # リファクタリングアクション
   ```

4. **DevToolsの活用**
   ```
   <leader>ft      # DevTools起動
   ```

---

## デバッグ・テスト

### 🐛 デバッグワークフロー

#### 🎯 基本的なデバッグ手順

1. **ブレークポイントの設定**
   ```
   <leader>b       # ブレークポイント切り替え
   <leader>B       # 条件付きブレークポイント
   ```

2. **デバッグ実行**
   ```
   <F5>            # デバッグ開始
   <F10>           # ステップオーバー
   <F11>           # ステップイン
   <F12>           # ステップアウト
   ```

3. **デバッグ情報の確認**
   ```
   <leader>du      # デバッグUI表示
   <leader>dr      # デバッグREPL
   ```

#### 🚀 VSCode launch.json統合デバッグ

**自動設定読み込み**
- プロジェクトの`.vscode/launch.json`ファイルを自動検出・読み込み
- 複数の言語（Dart、Flutter、Node.js、Python、Go、Rust、C++、Java）をサポート
- ファイル変更時の自動再読み込み機能

**高度なデバッグ操作**
1. **VSCode設定選択実行**
   ```
   <leader>vl      # launch.json設定を選択してデバッグ実行
   ```

2. **設定の再読み込み**
   ```
   <leader>dl      # launch.json設定を手動で再読み込み
   ```

3. **プロジェクト固有の設定**
   - プロジェクトルート自動検出（pubspec.yaml、package.json等）
   - mise/asdf版本管理ツールとの統合
   - SDKパスの自動解決

**launch.json設定例**
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Launch Flutter",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart"
    },
    {
      "name": "Launch Dart Script",
      "type": "dart",
      "request": "launch",
      "program": "${file}"
    }
  ]
}
```

**デバッグワークフロー例**
1. プロジェクトに`.vscode/launch.json`を作成
2. `<leader>vl`で設定を選択
3. 設定された環境でデバッグ開始
4. 通常のデバッグ操作（F5、F10等）で実行制御

### 🧪 テスト実行

1. **単体テストの実行**
   ```bash
   # ターミナルから
   flutter test
   
   # 特定のファイル
   flutter test test/widget_test.dart
   ```

2. **統合テストの実行**
   ```bash
   flutter test integration_test/
   ```

3. **カバレッジの確認**
   ```bash
   flutter test --coverage
   genhtml coverage/lcov.info -o coverage/html
   ```

### 📊 パフォーマンス分析

1. **プロファイリング**
   ```bash
   flutter run --profile
   ```

2. **DevToolsでの分析**
   ```
   <leader>ft      # DevTools起動
   # Performance、Memory、Networkタブを活用
   ```

---

## リファクタリング

### 🔧 安全なリファクタリング手順

1. **リファクタリング前の準備**
   ```
   <leader>gg      # Gitステータス確認
   # 変更をコミット
   ```

2. **LSPを活用したリファクタリング**
   ```
   <leader>rn      # シンボルリネーム
   <leader>ca      # コードアクション
   gd              # 定義確認
   gr              # 影響範囲確認
   ```

3. **AI支援リファクタリング**
   ```
   <leader>cR      # Copilotリファクタリング
   <leader>ce      # コード説明（理解のため）
   ```

4. **大規模リファクタリング**
   ```
   <leader>fg      # 全体検索
   # 一括置換の検討
   ```

5. **リファクタリング後の確認**
   ```
   <leader>fr      # 実行確認
   flutter test    # テスト実行
   ```

### 📋 リファクタリングチェックリスト

- [ ] 影響範囲の特定（`gr`で参照確認）
- [ ] テストの実行
- [ ] 型安全性の確認
- [ ] パフォーマンスへの影響確認
- [ ] ドキュメントの更新

---

## Git操作

### 📝 効率的なGitワークフロー

1. **変更状況の確認**
   ```
   <leader>gg      # Neogitでステータス確認
   <leader>gd      # Diffview表示
   <leader>gh      # ファイル履歴表示
   ```

2. **Hunk単位での操作**
   ```
   ]c              # 次の変更箇所
   [c              # 前の変更箇所
   <leader>hp      # 変更内容プレビュー
   <leader>hs      # Hunkステージング
   <leader>hr      # Hunk取り消し
   ```

3. **ファイル単位での操作**
   ```
   <leader>hS      # ファイル全体ステージング
   <leader>hR      # ファイル全体リセット
   <leader>hu      # ステージング取り消し
   ```

4. **Blame・履歴確認**
   ```
   <leader>hb      # Git blame表示
   <leader>tb      # Blame表示切り替え
   <leader>td      # 削除行表示切り替え
   ```

### 🌿 ブランチ管理

1. **ブランチ操作**
   ```bash
   # ターミナルから
   git checkout -b feature/new-widget
   git push -u origin feature/new-widget
   ```

2. **マージ・リベース**
   ```
   <leader>gd      # マージ時の競合解決に活用
   ```

### 📋 コミットベストプラクティス

1. **コミット前チェック**
   ```
   <leader>xx      # エラー・警告の確認
   flutter test    # テスト実行
   flutter analyze # 静的解析
   ```

2. **コミットメッセージ**
   ```
   feat: add user authentication widget
   fix: resolve memory leak in image cache
   refactor: extract common utility functions
   ```

---

## パフォーマンス最適化

### 🚀 パフォーマンス分析ワークフロー

1. **プロファイルビルドでの確認**
   ```bash
   flutter run --profile
   flutter build apk --profile
   ```

2. **DevToolsでの分析**
   ```
   <leader>ft      # DevTools起動
   # Performance、Memory、Networkタブを使用
   ```

3. **ホットスポットの特定**
   ```
   <leader>fg      # パフォーマンス問題のあるコード検索
   # "setState", "build"等のキーワード検索
   ```

### 📊 最適化のポイント

1. **ウィジェット最適化**
   - const constructorの使用
   - 不要なrebuildの回避
   - ListView.builderの活用

2. **状態管理の最適化**
   - 適切なスコープでの状態管理
   - 無駄な再計算の回避

3. **アセット最適化**
   - 画像サイズの最適化
   - 不要なアセットの削除

---

## トラブルシューティング

### 🔍 一般的な問題の解決手順

1. **LSPが動作しない**
   ```
   :LspInfo        # LSP状態確認
   :checkhealth    # 全体的な健康状態チェック
   ```

2. **ビルドエラー**
   ```
   <leader>xx      # Trouble表示
   <leader>e       # 診断詳細
   flutter clean   # キャッシュクリア
   flutter pub get # 依存関係再取得
   ```

3. **プラグインエラー**
   ```bash
   # プラグインキャッシュクリア
   rm -rf ~/.local/share/nvim/lazy/
   # Neovim再起動
   ```

4. **Copilotが動作しない**
   ```
   :Copilot auth   # 認証確認
   :Copilot status # ステータス確認
   ```

### 🆘 緊急時の対処法

1. **設定をリセット**
   ```bash
   # 設定バックアップの復元
   mv ~/.config/nvim.backup ~/.config/nvim
   ```

2. **最小構成での起動**
   ```bash
   nvim --clean
   ```

3. **ログの確認**
   ```bash
   tail -f ~/.local/share/nvim/log
   ```

---

## 💡 生産性向上のヒント

### ⚡ ショートカット活用

1. **Which-keyの活用**
   ```
   <leader>        # Which-keyでヘルプ表示
   ```

2. **TODO管理**
   ```
   ]t              # 次のTODO
   [t              # 前のTODO
   <leader>xt      # TODO一覧（Trouble）
   <leader>st      # TODO検索（Telescope）
   ```

3. **高速移動**
   ```
   <leader>hw      # 単語へジャンプ
   <leader>hl      # 行へジャンプ
   f/F/t/T         # 行内文字ジャンプ
   ```

### 📚 学習リソース

1. **Flutter公式ドキュメント**
   - [Flutter.dev](https://flutter.dev)
   - [Dart Language Tour](https://dart.dev/guides/language/language-tour)

2. **Neovim関連**
   - `:help`でヘルプ確認
   - コミュニティフォーラム

### 🎯 継続的改善

1. **定期的な設定見直し**
   - 使わないプラグインの削除
   - キーマップの最適化

2. **新機能の学習**
   - プラグインの更新確認
   - 新しいワークフローの試行

---

## 📊 パフォーマンス指標

### ⏱️ 開発効率の測定

| 指標 | 目標値 |
|------|---------|
| プロジェクト起動時間 | < 5秒 |
| ホットリロード時間 | < 2秒 |
| LSP応答時間 | < 500ms |
| ビルド時間（Debug） | < 30秒 |
| ビルド時間（Release） | < 3分 |

### 📈 品質指標

| 指標 | 目標値 |
|------|---------|
| テストカバレッジ | > 80% |
| 静的解析スコア | 100点 |
| パフォーマンススコア | > 90点 |

---

## 🔧 高度な機能

### 🤖 AI支援開発

1. **Copilot Chat活用**
   ```
   <leader>cc      # チャット開始
   <leader>ce      # コード説明
   <leader>ct      # テスト生成
   <leader>cR      # リファクタリング
   ```

2. **効果的なプロンプト**
   ```
   # コード説明の場合
   "この関数の目的と動作を説明して"
   
   # テスト生成の場合
   "このウィジェットのテストケースを作成して"
   
   # リファクタリングの場合
   "このコードをより効率的にして"
   ```

### 📋 タスク管理

1. **TODO統合**
   ```dart
   // TODO: ユーザー認証機能を実装
   // FIXME: メモリリークを修正
   // HACK: 一時的な回避策
   // NOTE: 重要な仕様変更
   ```

2. **TODO検索・管理**
   ```
   <leader>xt      # Trouble表示
   <leader>st      # Telescope検索
   ]t / [t         # TODO間移動
   ```

---

**🎯 このワークフローを参考に、あなた独自の効率的な開発スタイルを確立してください！**