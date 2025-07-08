# Flutter開発環境トラブルシューティングガイド 🔧

Flutter + Neovim開発環境で発生する一般的な問題とその解決方法を説明します。
Neovim 0.11+に対応した最新のトラブルシューティング情報を含みます。

## 📋 目次

- [基本的なトラブルシューティング手順](#基本的なトラブルシューティング手順)
- [Flutter関連の問題](#flutter関連の問題)
- [Neovim・プラグイン関連](#neovimプラグイン関連)
- [LSP関連の問題](#lsp関連の問題)
- [Git統合の問題](#git統合の問題)
- [GitHub Copilot関連](#github-copilot関連)
- [パフォーマンス問題](#パフォーマンス問題)
- [設定・環境問題](#設定環境問題)
- [緊急時の対処法](#緊急時の対処法)

---

## 基本的なトラブルシューティング手順

### 🔍 問題の特定

1. **症状の確認**
   ```
   :checkhealth        # Neovim全体の健康状態
   :LspInfo           # LSP状態確認
   :Lazy              # プラグイン状態確認
   ```

2. **ログの確認**
   ```bash
   # Neovimログ
   tail -f ~/.local/share/nvim/log
   
   # Flutterログ
   flutter logs
   ```

3. **基本的な再起動手順**
   ```
   # Neovim内で
   :qa!               # Neovim終了
   
   # ターミナルで
   nvim               # 再起動
   ```

---

## Flutter関連の問題

### ❌ Flutter SDKが見つからない

**症状**: LSPが起動しない、Flutter コマンドが認識されない

**原因**: 
- Flutter SDKパスが正しく設定されていない
- mise/asdfの設定問題

**解決方法**:

1. **Flutter SDKの確認**
   ```bash
   which flutter
   flutter --version
   flutter doctor -v
   ```

2. **mise/asdfの確認**
   ```bash
   # miseを使用している場合
   mise which flutter
   mise current
   
   # mise警告メッセージが出る場合
   mise settings set idiomatic_version_file_enable_tools ruby
   
   # asdfを使用している場合
   asdf which flutter
   asdf current
   ```

3. **手動でパスを設定**
   ```bash
   # ~/.zshrc または ~/.bashrc に追加
   export PATH="$HOME/flutter/bin:$PATH"
   source ~/.zshrc
   ```

4. **Neovim設定の確認**
   ```lua
   -- flutter-tools.nvimの設定確認
   -- lua/flutter-dev-minimal.lua 内で flutter_path を確認
   ```

### ❌ ホットリロードが機能しない

**症状**: `<leader>fh` でホットリロードされない

**解決方法**:

1. **Flutter実行状態の確認**
   ```
   <leader>tf          # Flutter専用ターミナル確認
   ```

2. **デバイス接続確認**
   ```bash
   flutter devices
   ```

3. **アプリの再起動**
   ```
   <leader>fR          # ホットリスタート
   <leader>fq          # アプリ終了
   <leader>fr          # 再実行
   ```

4. **ターミナルでの手動確認**
   ```bash
   flutter run
   # その後 'r' キーでホットリロード
   ```

### ❌ ビルドエラー

**症状**: `flutter run` や `flutter build` でエラー

**解決方法**:

1. **キャッシュクリア**
   ```bash
   flutter clean
   flutter pub get
   ```

2. **依存関係の確認**
   ```bash
   flutter pub deps
   flutter pub outdated
   ```

3. **診断情報の確認**
   ```
   <leader>xx          # Troubleでエラー一覧（Troubleプラグイン使用時）
   <leader>de          # 診断詳細（最新キーバインド）
   ```

4. **段階的なビルド**
   ```bash
   flutter analyze     # 静的解析
   flutter test        # テスト実行
   flutter build apk   # ビルド
   ```

---

## Neovim・プラグイン関連

### ❌ プラグインが読み込まれない

**症状**: lazy.nvimでプラグインインストールが失敗

**解決方法**:

1. **プラグインキャッシュクリア**
   ```bash
   rm -rf ~/.local/share/nvim/lazy/
   rm -rf ~/.cache/nvim/
   ```

2. **Neovim再起動**
   ```bash
   nvim
   # 自動的にプラグインが再インストールされる
   ```

3. **ネットワーク接続確認**
   ```bash
   ping github.com
   curl -I https://github.com
   ```

4. **Git設定確認**
   ```bash
   git config --global user.name
   git config --global user.email
   ```

### ❌ lazy.nvim エラー

**症状**: "Error in packer_compiled.lua" のようなエラー

**解決方法**:

1. **古いpacker設定の削除**
   ```bash
   rm -rf ~/.local/share/nvim/site/pack/packer
   rm -rf ~/.config/nvim/plugin/packer_compiled.lua
   ```

2. **lazy.nvim設定の確認**
   ```lua
   -- init.lua で以下を確認
   require('flutter-dev-minimal')  -- または使用している設定
   ```

3. **設定ファイルの構文チェック**
   ```bash
   nvim --clean -c "luafile ~/.config/nvim/init.lua"
   ```

### ❌ DAP（デバッグ）関連エラー

**症状**: "nvim-nio required" エラー

**解決方法**:

1. **安定版設定への切り替え**
   ```lua
   -- init.lua で
   require('flutter-dev-minimal')  -- DAP機能なし版
   -- require('flutter-dev-with-dap')  -- この行をコメントアウト
   ```

2. **キャッシュクリア**
   ```bash
   rm -rf ~/.local/share/nvim/lazy && rm -rf ~/.cache/nvim
   nvim  # 再起動
   ```

3. **段階的な有効化**
   ```lua
   -- flutter-dev-with-dap.lua で enable_debug = false に設定
   local enable_debug = false
   ```

---

## LSP関連の問題

### ❌ Neovim 0.11+ LSP設定エラー

**症状**: LspAttach自動コマンドが動作しない

**解決方法**:

1. **Neovimバージョン確認**
   ```bash
   nvim --version
   # 0.11.0以上であることを確認
   ```

2. **LspAttachイベント確認**
   ```vim
   :au LspAttach
   # 登録された自動コマンドを確認
   ```

3. **手動でLSPアタッチテスト**
   ```vim
   :lua vim.lsp.buf.hover()
   # エラーが出る場合はLSPがアタッチされていない
   ```

### ❌ Dart LSPが起動しない

**症状**: コード補完、エラー表示が機能しない

**解決方法**:

1. **LSP状態確認**
   ```
   :LspInfo
   :checkhealth lsp
   ```

2. **Flutter tools確認**
   ```bash
   flutter doctor -v
   which dart
   ```

3. **LSP再起動**
   ```
   :LspRestart
   ```

4. **設定の確認**
   ```lua
   -- flutter-tools.nvimの lsp.settings を確認
   ```

### ❌ 自動補完が機能しない

**症状**: nvim-cmpで補完が表示されない

**解決方法**:

1. **補完手動実行**
   ```
   <C-Space>           # 手動補完
   ```

2. **設定確認**
   ```
   :CmpStatus          # nvim-cmp状態確認
   ```

3. **ソース確認**
   ```lua
   -- nvim-cmp設定で sources を確認
   sources = {
     { name = 'nvim_lsp' },
     { name = 'copilot' },
     { name = 'luasnip' },
   }
   ```

### ❌ 診断情報が表示されない

**症状**: エラーや警告が表示されない

**解決方法**:

1. **診断設定確認**
   ```
   :lua vim.diagnostic.config()
   ```

2. **手動診断実行**
   ```bash
   flutter analyze
   dart analyze
   ```

3. **nvim-lint確認**
   ```
   :lua require('lint').try_lint()
   ```

---

## Git統合の問題

### ❌ Gitsigns が機能しない

**症状**: Git差分が表示されない

**解決方法**:

1. **Git リポジトリ確認**
   ```bash
   git status
   pwd  # Gitリポジトリ内か確認
   ```

2. **Gitsigns再起動**
   ```
   :Gitsigns refresh
   ```

3. **設定確認**
   ```
   :Gitsigns debug_messages
   ```

### ❌ Neogit が起動しない

**症状**: `<leader>gg` でNeogitが開かない

**解決方法**:

1. **Git設定確認**
   ```bash
   git config --list
   git config user.name
   git config user.email
   ```

2. **手動起動**
   ```
   :Neogit
   ```

3. **依存関係確認**
   ```
   :checkhealth neogit
   ```

---

## GitHub Copilot関連

### ❌ Copilotが認証されない

**症状**: Copilot提案が表示されない

**解決方法**:

1. **認証確認**
   ```
   :Copilot auth
   :Copilot status
   ```

2. **手動認証**
   ```bash
   # ブラウザでGitHubにログイン後、表示されるコードを入力
   ```

3. **Node.js確認**
   ```bash
   node --version  # v18以上が必要
   ```

### ❌ Copilot Chat が機能しない

**症状**: `<leader>cc` でチャットが開かない

**解決方法**:

1. **プラグイン状態確認**
   ```
   :Lazy
   # CopilotChat.nvimの状態確認
   ```

2. **手動起動**
   ```
   :CopilotChatOpen
   ```

3. **依存関係確認**
   ```
   :checkhealth copilot
   ```

---

## パフォーマンス問題

### 🐌 Neovimが重い

**症状**: 起動が遅い、操作が重い

**解決方法**:

1. **起動時間計測**
   ```bash
   nvim --startuptime startup.log
   # startup.logで重い箇所を特定
   ```

2. **不要なプラグインの無効化**
   ```lua
   -- 重いプラグインを一時的に無効化
   {
     'heavy-plugin',
     enabled = false,
   }
   ```

3. **Treesitter最適化**
   ```lua
   require('nvim-treesitter.configs').setup {
     highlight = { enable = false }, -- 一時的に無効化
   }
   ```

4. **診断機能の調整**
   ```lua
   vim.diagnostic.config({
     update_in_insert = false,  -- インサート中の診断を無効
   })
   ```

### 🐌 Flutter実行が遅い

**症状**: ホットリロードに時間がかかる

**解決方法**:

1. **プロファイルモードでの実行**
   ```bash
   flutter run --profile
   ```

2. **キャッシュ最適化**
   ```bash
   flutter clean
   flutter pub get
   ```

3. **不要なログの無効化**
   ```lua
   require("flutter-tools").setup {
     dev_log = { enabled = false },
   }
   ```

---

## 設定・環境問題

### ❌ キーバインドの競合

**症状**: キーバインドが期待通り動作しない

**解決方法**:

1. **競合するキーマップの確認**
   ```vim
   :verbose map <Tab>
   :verbose map <leader>e
   # 複数のマッピングがある場合は競合
   ```

2. **最新のキーバインド確認**
   - `<Tab>`/`<S-Tab>`: バッファ切り替え
   - `<leader>e`: nvim-treeトグル
   - `<leader>de`: 診断フロート
   - `<leader>Q`: 終了（大文字Q）

3. **キーマップリセット**
   ```vim
   :mapclear
   :source ~/.config/nvim/init.lua
   ```

### ❌ キーバインドが効かない

**症状**: `<leader>` キーが反応しない

**解決方法**:

1. **リーダーキー確認**
   ```
   :echo mapleader
   # 'Space' が返されるはず
   ```

2. **キーマップ確認**
   ```
   :map <leader>ff
   # ファイル検索のマップが表示されるはず
   ```

3. **Which-key確認**
   ```
   <leader>           # Which-keyヘルプが表示されるか
   ```

### ❌ ファイルタイプ認識エラー

**症状**: Dartファイルが正しく認識されない

**解決方法**:

1. **ファイルタイプ確認**
   ```
   :set filetype?
   # dart が返されるはず
   ```

2. **手動設定**
   ```
   :set filetype=dart
   ```

3. **設定ファイル確認**
   ```lua
   -- ファイルタイプ設定を確認
   vim.filetype.add {
     extension = { arb = 'json' },
   }
   ```

---

## 新機能・拡張機能の問題

### ❌ Treesitterエラー

**症状**: 構文ハイライトが機能しない

**解決方法**:

1. **Treesitterパーサーインストール**
   ```vim
   :TSInstall dart
   :TSInstall flutter
   :TSUpdate
   ```

2. **パーサー状態確認**
   ```vim
   :checkhealth nvim-treesitter
   :TSInstallInfo
   ```

3. **キャッシュクリア**
   ```bash
   rm -rf ~/.local/share/nvim/tree-sitter
   ```

### ❌ Telescope検索が遅い

**症状**: ファイル検索が非常に遅い

**解決方法**:

1. **telescope-fzf-native確認**
   ```vim
   :Telescope
   # Extensionsにfzfがあるか確認
   ```

2. **ビルド確認**
   ```bash
   cd ~/.local/share/nvim/lazy/telescope-fzf-native.nvim
   make
   ```

3. **検索除外設定**
   ```lua
   -- file_ignore_patternsに大きなフォルダを追加
   file_ignore_patterns = {
     "node_modules",
     ".git/",
     "build/",
     "%.lock",
   }
   ```

### ❌ nvim-treeが開かない

**症状**: `<leader>e`でファイルツリーが開かない

**解決方法**:

1. **手動起動**
   ```vim
   :NvimTreeToggle
   :NvimTreeOpen
   ```

2. **設定確認**
   ```vim
   :checkhealth nvim-tree
   ```

3. **キーマップ確認**
   ```vim
   :map <leader>e
   # NvimTreeToggleがマップされているか確認
   ```

## 緊急時の対処法

### 🆘 設定が完全に壊れた場合

1. **設定バックアップの復元**
   ```bash
   mv ~/.config/nvim ~/.config/nvim.broken
   mv ~/.config/nvim.backup ~/.config/nvim
   ```

2. **最小構成での起動**
   ```bash
   nvim --clean
   nvim --noplugin
   ```

3. **段階的な復旧**
   ```bash
   # 基本設定のみ復元
   cp init.lua ~/.config/nvim/
   nvim  # 動作確認
   
   # プラグイン設定を段階的に追加
   ```

### 🆘 プラグインが全く動かない

1. **完全クリーンアップ**
   ```bash
   rm -rf ~/.local/share/nvim/
   rm -rf ~/.cache/nvim/
   rm -rf ~/.config/nvim/lazy-lock.json
   ```

2. **Neovim再インストール**
   ```bash
   # macOS
   brew reinstall neovim
   
   # または公式バイナリから再インストール
   ```

3. **設定の段階的復元**
   ```bash
   # 最小設定から開始
   echo "-- minimal config" > ~/.config/nvim/init.lua
   nvim  # 動作確認
   ```

---

## 🔧 診断ツール

### 総合診断スクリプト

```bash
#!/bin/bash
echo "=== Flutter開発環境診断 ==="

echo "1. システム情報"
uname -a
echo "Neovim: $(nvim --version | head -1)"
echo "Flutter: $(flutter --version | head -1)"
echo "Dart: $(dart --version)"
echo "Git: $(git --version)"
echo "ripgrep: $(rg --version | head -1)"
echo "fd: $(fd --version)"

echo "2. 環境変数"
echo "PATH: $PATH"
echo "FLUTTER_ROOT: $FLUTTER_ROOT"

echo "3. Flutter Doctor"
flutter doctor -v

echo "4. Neovim設定"
echo "Config dir: ~/.config/nvim"
ls -la ~/.config/nvim/

echo "5. プラグイン状態"
nvim --headless -c "Lazy! show" -c "qa"
```

### 問題レポートテンプレート

問題を報告する際は以下の情報を含めてください：

```
## 環境情報
- OS: macOS 14.0
- Neovim: 0.11.2
- Flutter: 3.16.0
- 設定ファイル: flutter-dev-with-dap.lua

## 症状
具体的な症状を記述

## 再現手順
1. 
2. 
3. 

## 期待される動作


## 実際の動作


## エラーメッセージ
```

---

**🔧 問題が解決しない場合は、GitHub Issues または関連コミュニティで質問してください。**

**💡 このガイドは定期的に更新されます。新しい問題や解決方法があれば追加していきます。**