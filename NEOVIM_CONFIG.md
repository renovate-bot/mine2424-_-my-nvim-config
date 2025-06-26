# Neovim Configuration for Development

このドキュメントでは、開発効率を最大化するNeovim設定について説明します。プラグインマネージャーを使わず、Neovimの標準機能のみで構成されています。

## 📋 目次

- [インストールと設定](#インストールと設定)
- [設定構成](#設定構成)
- [キーマップ一覧](#キーマップ一覧)
- [自動化機能](#自動化機能)
- [言語別設定](#言語別設定)
- [カスタマイズ](#カスタマイズ)
- [トラブルシューティング](#トラブルシューティング)

## 🚀 インストールと設定

### 1. Neovimのインストール

```bash
# macOS (Homebrew)
brew install neovim

# Ubuntu/Debian
sudo apt install neovim

# 最新版（推奨）
brew install --HEAD neovim
```

### 2. 設定ファイルの配置

```bash
# 設定ディレクトリを作成
mkdir -p ~/.config/nvim/lua

# 設定ファイルをコピー
cp init.lua ~/.config/nvim/
cp -r lua/ ~/.config/nvim/
```

### 3. 設定の確認

```bash
# Neovimの設定確認
nvim --version
nvim +checkhealth
```

## 🗂️ 設定構成

```
~/.config/nvim/
├── init.lua              # メイン設定ファイル
└── lua/
    ├── base.lua          # 基本設定
    ├── maps.lua          # キーマップ設定
    └── plugins.lua       # プラグイン設定（標準機能のみ）
```

### 各ファイルの役割

| ファイル | 説明 |
|---------|------|
| `init.lua` | 設定の読み込み順序を管理 |
| `lua/base.lua` | エディタの基本動作設定 |
| `lua/maps.lua` | キーバインドとショートカット |
| `lua/plugins.lua` | 自動化とファイルタイプ設定 |

## ⌨️ キーマップ一覧

### リーダーキー
- **リーダーキー**: `Space`

### 基本操作
| キーバインド | モード | 機能 |
|-------------|-------|------|
| `jj` / `kk` | Insert | ESCキー代替 |
| `ESC ESC` | Normal | 検索ハイライト解除 |
| `Space w` | Normal | ファイル保存 |
| `Space q` | Normal | 終了 |
| `Space wq` | Normal | 保存して終了 |

### ウィンドウ・タブ操作
| キーバインド | モード | 機能 |
|-------------|-------|------|
| `ss` | Normal | 水平分割 |
| `sv` | Normal | 垂直分割 |
| `sh/sk/sj/sl` | Normal | ウィンドウ移動 |
| `Ctrl-w + 矢印` | Normal | ウィンドウリサイズ |
| `Space t` | Normal | 新しいタブ |
| `Tab` / `Shift-Tab` | Normal | タブ移動 |

### バッファ操作
| キーバインド | モード | 機能 |
|-------------|-------|------|
| `Space bp/bn` | Normal | バッファ移動 |
| `Space bd` | Normal | バッファ削除 |
| `Space bl` | Normal | バッファ一覧 |

### 編集操作
| キーバインド | モード | 機能 |
|-------------|-------|------|
| `J` / `K` | Visual | 選択行を上下移動 |
| `<` / `>` | Visual | インデント調整 |
| `Space d` | Normal | 行複製 |
| `Space a` | Normal | 全選択 |
| `Space r` | Normal | 単語置換 |

### ファイル・ターミナル
| キーバインド | モード | 機能 |
|-------------|-------|------|
| `Space n` | Normal | 新しいファイル |
| `Space T` | Normal | ターミナル起動 |
| `ESC` | Terminal | ターミナルノーマルモード |

### ユーティリティ
| キーバインド | モード | 機能 |
|-------------|-------|------|
| `Space cp` | Normal | ファイルパスをコピー |
| `Space cl` | Normal | 現在行をコピー |
| `Space f` | Normal | ファイル整形 |

## 🤖 自動化機能

### ファイル管理
- **自動リロード**: ファイル変更時の自動読み込み
- **トレーリング空白削除**: 保存時に行末空白を自動削除
- **カーソル位置復元**: ファイル再開時に前回位置に移動

### ビジュアル改善
- **ヤンクハイライト**: コピー時の視覚的フィードバック
- **相対行番号**: vim操作効率化のための行番号表示
- **カーソルライン**: 現在行のハイライト表示

### 開発支援
- **言語別インデント**: ファイルタイプに応じた自動設定
- **Git統合**: gitcommitファイルでのスペルチェック
- **ターミナル最適化**: ターミナルモードでの設定調整

## 🌐 言語別設定

### JavaScript/TypeScript
```lua
-- 自動設定される内容
shiftwidth = 2
tabstop = 2
omnifunc = 'syntaxcomplete#Complete'
```

### Python
```lua
-- 自動設定される内容  
shiftwidth = 4
tabstop = 4
```

### Dart/Flutter
```lua
-- 自動設定される内容
shiftwidth = 2
tabstop = 2
```

### Markdown
```lua
-- 自動設定される内容
wrap = true          -- 行の折り返し
spell = true         -- スペルチェック
conceallevel = 2     -- マークダウン記法の隠蔽
```

## 🎨 表示設定

### エディタ外観
- **行番号**: 絶対 + 相対行番号表示
- **カーソルライン**: 現在行をハイライト
- **カラーカラム**: 80文字ガイドライン
- **不可視文字**: タブや空白の視覚化

### ステータスライン
カスタムステータスラインが表示する情報：
- 現在のモード（NORMAL/INSERT/VISUAL等）
- ファイル名
- ファイルタイプ
- カーソル位置（行:列/総行数）

### UI設定
- **透明度**: フローティングウィンドウ10%透明
- **補完メニュー**: 最大10項目表示
- **スクロール余白**: 上下8行、左右16列

## 🛠️ カスタマイズ

### インデント設定の変更
```lua
-- lua/base.lua で設定変更
vim.opt.shiftwidth = 4    -- お好みの幅
vim.opt.tabstop = 4       -- お好みの幅
```

### キーマップの追加
```lua
-- lua/maps.lua に追加
keymap.set('n', '<Leader>x', ':your-command<Return>', { desc = 'Your description' })
```

### 新しい言語サポート
```lua
-- lua/plugins.lua に追加
autocmd('FileType', {
  pattern = { 'your-language' },
  callback = function()
    vim.opt_local.shiftwidth = 2
    -- その他の設定
  end,
  desc = 'Your language settings'
})
```

### カラースキームの変更
```lua
-- lua/plugins.lua で変更
vim.cmd.colorscheme('your-preferred-theme')
```

## 🔧 開発ワークフロー最適化

### WezTerm + tmux連携
この設定はWezTermとtmuxとの連携を考慮しています：

- **ウィンドウ移動**: `sh/sk/sj/sl`でNeovim内ペイン移動
- **ターミナル統合**: `Space T`で内蔵ターミナル起動
- **クリップボード**: システムクリップボードと統合

### Git連携
- **gitcommit**: スペルチェックと文字数ガイド自動有効化
- **ファイル差分**: 標準のgitツールと連携

### Flutter開発
- **Dart言語サポート**: 2スペースインデント自動設定
- **ターミナル統合**: WezTermのFlutterショートカットと連携

## 🐛 トラブルシューティング

### よくある問題と解決方法

#### 1. 設定が反映されない
```bash
# Neovimの設定確認
nvim +checkhealth

# 設定ファイルの構文確認
nvim --clean -c "luafile ~/.config/nvim/init.lua"
```

#### 2. キーマップが効かない
```bash
# キーマップの確認
:map
:nmap
:imap
```

#### 3. ファイルタイプが認識されない
```bash
# ファイルタイプの確認
:set filetype?

# 手動設定
:set filetype=javascript
```

#### 4. ステータスラインが表示されない
```lua
-- lua/base.lua で確認
vim.opt.laststatus = 2  -- 常時表示
```

#### 5. 透明度が効かない
```bash
# True Color対応確認
:echo $COLORTERM

# 手動設定
:set termguicolors
```

### パフォーマンス問題

#### 大きなファイルでの動作が重い
```lua
-- lua/base.lua に追加
vim.opt.synmaxcol = 200        -- シンタックスハイライト制限
vim.opt.lazyredraw = true      -- 描画の最適化
```

#### 起動が遅い
```bash
# 起動時間の分析
nvim --startuptime startup.log

# プロファイリング
nvim --clean  # プラグインなしで起動確認
```

## 📝 設定更新手順

1. **設定ファイルの編集**
   ```bash
   nvim ~/.config/nvim/lua/base.lua
   ```

2. **設定の再読み込み**
   ```vim
   :source ~/.config/nvim/init.lua
   ```

3. **変更の確認**
   ```vim
   :checkhealth
   ```

## 🚀 次のステップ

### プラグインマネージャーの導入
より高度な機能が必要な場合：

```bash
# lazy.nvimの導入例
git clone --filter=blob:none https://github.com/folke/lazy.nvim.git \
  ~/.local/share/nvim/lazy/lazy.nvim
```

### LSPサーバーの設定
言語サーバーサポートの追加：

```bash
# 各言語のLSPサーバーインストール
npm install -g typescript-language-server
pip install python-lsp-server
```

### おすすめプラグイン
機能拡張のための推奨プラグイン：

- **telescope.nvim**: ファジーファインダー
- **nvim-treesitter**: シンタックスハイライト強化
- **gitsigns.nvim**: Git統合
- **nvim-lspconfig**: LSP設定管理

## 🔗 関連リンク

- [Neovim公式ドキュメント](https://neovim.io/doc/)
- [Lua言語リファレンス](https://www.lua.org/manual/5.1/)
- [Neovim Luaガイド](https://neovim.io/doc/user/lua-guide.html)
- [WezTerm設定](./WEZTERM_CONFIG.md)

## 📄 ライセンス

この設定ファイルはMITライセンスの下で公開されています。

---

**Note**: この設定は継続的に改善されています。新しい機能や最適化があれば、このドキュメントも更新されます。