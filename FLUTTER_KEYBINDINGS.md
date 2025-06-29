# Flutter開発 - キーバインド クイックリファレンス

## 🎯 概要

WezTerm + Neovim Flutter開発環境で使用する主要なキーバインドの一覧です。
印刷やクイックリファレンスとして活用してください。

---

## ⌨️ Neovim - Flutter開発

### 🚀 プロジェクト管理

| キーバインド | コマンド | 説明 |
|-------------|---------|------|
| `<Leader>Fr` | `:!flutter run` | Flutterアプリ実行 |
| `<Leader>Fh` | `:!flutter run --hot-reload` | ホットリロード付き実行 |
| `<Leader>Fc` | `:!flutter clean` | プロジェクトクリーン |
| `<Leader>Fb` | `:!flutter build apk` | APKビルド |
| `<Leader>Ft` | `:!flutter test` | テスト実行 |
| `<Leader>Fd` | `:!flutter devices` | デバイス一覧 |
| `<Leader>Fe` | `:!flutter emulators` | エミュレータ一覧 |

### 🎯 Dart専用

| キーバインド | コマンド | 説明 |
|-------------|---------|------|
| `<Leader>Da` | `:!dart analyze` | コード解析 |
| `<Leader>Df` | `:!dart format .` | コードフォーマット |
| `<Leader>Dp` | `:!dart pub get` | 依存関係取得 |
| `<Leader>Du` | `:!dart pub upgrade` | 依存関係更新 |

### 🖥️ ターミナル

| キーバインド | 説明 |
|-------------|------|
| `<Leader>FT` | 新しいタブでFlutter実行 |
| `<Leader>FL` | 分割ペインでFlutterログ表示 |

---

## 🔧 Neovim - LSP機能 (flutter-tools.nvim)

### 📍 ナビゲーション

| キーバインド | 機能 | 説明 |
|-------------|------|------|
| `gd` | Definition | 定義にジャンプ |
| `gD` | Declaration | 宣言にジャンプ |
| `gi` | Implementation | 実装にジャンプ |
| `gr` | References | 参照箇所一覧 |
| `K` | Hover | ホバー情報表示 |

### ✏️ 編集・リファクタリング

| キーバインド | 機能 | 説明 |
|-------------|------|------|
| `<Leader>rn` | Rename | 変数・関数リネーム |
| `<Leader>ca` | Code Action | コードアクション実行 |
| `<C-k>` | Signature Help | 関数シグネチャ表示 |

### 🐛 診断・エラー

| キーバインド | 機能 | 説明 |
|-------------|------|------|
| `<Leader>e` | Open Float | エラー詳細をフロート表示 |
| `[d` | Previous Diagnostic | 前のエラーに移動 |
| `]d` | Next Diagnostic | 次のエラーに移動 |

### 🎯 Flutter特化機能

| キーバインド | コマンド | 説明 |
|-------------|---------|------|
| `<Leader>fr` | `FlutterRun` | Flutterアプリ起動 |
| `<Leader>fq` | `FlutterQuit` | Flutterアプリ終了 |
| `<Leader>fR` | `FlutterRestart` | ホットリスタート |
| `<Leader>fh` | `FlutterReload` | ホットリロード |
| `<Leader>fd` | `FlutterDevices` | デバイス選択 |
| `<Leader>fe` | `FlutterEmulators` | エミュレータ選択 |
| `<Leader>fo` | `FlutterOutlineToggle` | アウトライン表示切り替え |
| `<Leader>ft` | `FlutterDevTools` | DevTools起動 |
| `<Leader>fc` | `FlutterLogClear` | ログクリア |

---

## 🐛 デバッグ機能

### 🎮 デバッグ制御

| キーバインド | 機能 | 説明 |
|-------------|------|------|
| `<F5>` | Continue | デバッグ開始/継続 |
| `<F10>` | Step Over | ステップオーバー |
| `<F11>` | Step Into | ステップイン |
| `<F12>` | Step Out | ステップアウト |

### 🔍 ブレークポイント

| キーバインド | 機能 | 説明 |
|-------------|------|------|
| `<Leader>b` | Toggle Breakpoint | ブレークポイント切り替え |
| `<Leader>B` | Conditional Breakpoint | 条件付きブレークポイント |

### 🖥️ デバッグUI

| キーバインド | 機能 | 説明 |
|-------------|------|------|
| `<Leader>dr` | REPL Open | デバッグREPL開く |
| `<Leader>du` | UI Toggle | デバッグUI表示切り替え |

---

## 🔍 Telescope (ファジーファインダー)

### 📁 ファイル検索

| キーバインド | 機能 | 説明 |
|-------------|------|------|
| `<Leader>ff` | Find Files | ファイル検索 |
| `<Leader>fg` | Live Grep | 文字列検索 |
| `<Leader>fb` | Buffers | バッファ一覧 |
| `<Leader>fh` | Help Tags | ヘルプ検索 |

### 🏗️ LSP統合

| キーバインド | 機能 | 説明 |
|-------------|------|------|
| `<Leader>fs` | Document Symbols | ドキュメント内シンボル |
| `<Leader>fw` | Workspace Symbols | ワークスペースシンボル |

---

## 🖥️ WezTerm - Flutter専用ホットキー

### 🚀 Flutter実行制御

| キーバインド | 送信文字 | 説明 |
|-------------|---------|------|
| `Cmd+Shift+R` | `flutter run\r` | Flutterアプリ実行 |
| `Cmd+Shift+H` | `r` | ホットリロード |
| `Cmd+Shift+R` | `R` | ホットリスタート |
| `Cmd+Shift+Q` | `q` | アプリ終了 |

### 🖥️ ワークスペース管理

| キーバインド | 機能 | 説明 |
|-------------|------|------|
| `Cmd+Alt+F` | Flutter Workspace | Flutter専用レイアウト作成 |

### 🔧 開発支援

| キーバインド | 送信文字 | 説明 |
|-------------|---------|------|
| `Cmd+Shift+G` | `git status\r` | Git状態確認 |
| `Cmd+Shift+L` | `ls -la\r` | ファイル一覧表示 |

---

## 🎯 利用シーン別ガイド

### 📝 日常的なコーディング

1. **プロジェクト開始**: `cd project && wezterm`
2. **ファイル開く**: `<Leader>ff` → ファイル名入力
3. **コーディング**: 通常のNeovim操作
4. **保存**: `:w` (自動フォーマット実行)
5. **ホットリロード**: `Cmd+Shift+H`

### 🐛 デバッグ作業

1. **ブレークポイント設定**: `<Leader>b`
2. **デバッグ開始**: `<F5>`
3. **ステップ実行**: `<F10>`, `<F11>`
4. **変数確認**: デバッグUI内で確認
5. **継続**: `<F5>`

### 🔍 コード調査

1. **定義確認**: カーソルを合わせて `gd`
2. **使用箇所確認**: `gr`
3. **シンボル検索**: `<Leader>fs`
4. **文字列検索**: `<Leader>fg`

### 🚀 アプリ実行・テスト

1. **アプリ起動**: `<Leader>Fr`
2. **テスト実行**: `<Leader>Ft`
3. **デバイス切り替え**: `<Leader>Fd`
4. **ビルド確認**: `<Leader>Fb`

---

## 💡 カスタマイズのヒント

### 🎯 個人設定の追加

```lua
-- ~/.config/nvim/lua/personal-flutter.lua に追加
vim.keymap.set('n', '<Leader>Fm', ':!flutter run --flavor main<CR>')
vim.keymap.set('n', '<Leader>Fs', ':!flutter run --flavor staging<CR>')
```

### 🖥️ プロジェクト固有設定

```lua
-- プロジェクトルートに .nvimrc を作成
vim.keymap.set('n', '<Leader>Fp', ':!flutter run --flavor production<CR>')
```

---

**📖 このリファレンスを印刷して手元に置いておくと便利です！**

**🎯 より詳細な情報は [FLUTTER_WORKFLOW.md](FLUTTER_WORKFLOW.md) を参照してください。**