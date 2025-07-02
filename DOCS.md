# Flutter開発用Neovim設定 - 詳細ガイド 📚

## 📋 目次

- [セットアップガイド](#セットアップガイド)
- [Flutter開発ワークフロー](#flutter開発ワークフロー)
- [キーバインド一覧](#キーバインド一覧)
- [Git統合機能](#git統合機能)
- [WezTerm統合設定](#wezterm統合設定)
- [プラグイン詳細ガイド](#プラグイン詳細ガイド)

---

## セットアップガイド

### 🚀 統合セットアップスクリプト（推奨）

```bash
# このリポジトリをクローン
git clone https://github.com/your-repo/my-nvim-config.git
cd my-nvim-config

# 全て一括インストール
./scripts/setup.sh

# 手動検証
./scripts/verify-setup.sh

# Flutter プロジェクト作成
./scripts/create-flutter-project.sh <project-name>
```

### 📦 手動インストール手順

1. **依存関係のインストール**
   ```bash
   # macOS
   brew install neovim flutter dart ripgrep fd fzf
   
   # Ubuntu/Debian
   sudo apt install neovim flutter dart ripgrep fd-find fzf
   ```

2. **設定ファイルの配置**
   ```bash
   # Neovim設定
   cp -r lua ~/.config/nvim/
   cp init.lua ~/.config/nvim/
   
   # WezTerm設定
   cp wezterm.lua ~/.config/wezterm/
   
   # Starship設定
   cp starship.toml ~/.config/
   ```

---

## Flutter開発ワークフロー

### 🔄 日常的な開発フロー

1. **プロジェクトを開く**
   ```bash
   cd your-flutter-project
   nvim .
   ```

2. **開発環境の起動**
   - `<leader>fd` - デバイス一覧表示
   - `<leader>fe` - エミュレータ起動
   - `<leader>fr` - Flutter アプリ実行

3. **コード編集**
   - `<leader>fh` - ホットリロード
   - `<leader>fR` - ホットリスタート
   - `gd` - 定義へジャンプ
   - `<leader>ca` - コードアクション

4. **デバッグ**
   - `<F5>` - デバッグ開始
   - `<F10>` - ステップオーバー
   - `<F11>` - ステップイン
   - `<F9>` - ブレークポイント切り替え

### 🎯 新規プロジェクト開発

```bash
# プロジェクト作成
./scripts/create-flutter-project.sh my_app

# VSCode統合（launch.json自動読み込み）
cd my_app
nvim .
# :FlutterRun でVSCode設定を自動読み込み
```

---

## キーバインド一覧

### 🔥 Flutter開発
| キー | 機能 |
|------|------|
| `<leader>fr` | Flutter実行 |
| `<leader>fh` | ホットリロード |
| `<leader>fR` | ホットリスタート |
| `<leader>fq` | Flutter終了 |
| `<leader>fd` | デバイス一覧 |
| `<leader>fe` | エミュレータ起動 |
| `<leader>fl` | Flutter ログ表示 |
| `<leader>fc` | Flutter クリーン |

### 🤖 GitHub Copilot
| キー | 機能 |
|------|------|
| `Alt+l` | 提案受け入れ |
| `Alt+]` | 次の提案 |
| `Alt+[` | 前の提案 |
| `<leader>cc` | Copilot チャット |
| `<leader>Ce` | Copilot 有効化 |
| `<leader>Cd` | Copilot 無効化 |

### 📊 Git操作
| キー | 機能 |
|------|------|
| `]c` | 次のhunk |
| `[c` | 前のhunk |
| `<leader>hs` | hunkステージ |
| `<leader>hr` | hunkリセット |
| `<leader>hp` | hunkプレビュー |
| `<leader>hb` | 行のblame表示 |
| `<leader>tb` | blame表示切り替え |

### 🔍 LSP機能
| キー | 機能 |
|------|------|
| `gd` | 定義へジャンプ |
| `gr` | 参照一覧 |
| `gi` | 実装へジャンプ |
| `<leader>ca` | コードアクション |
| `<leader>rn` | 変数名変更 |
| `K` | ホバー情報 |
| `<leader>f` | フォーマット |

### ⚡ デバッグ (DAP)
| キー | 機能 |
|------|------|
| `<F5>` | デバッグ開始/続行 |
| `<F10>` | ステップオーバー |
| `<F11>` | ステップイン |
| `<F12>` | ステップアウト |
| `<F9>` | ブレークポイント切り替え |
| `<leader>dr` | REPL開く |
| `<leader>dl` | 最後のセッション再実行 |

---

## Git統合機能

### 📊 gitsigns.nvimによる高度なGit統合

#### ✨ 主な機能
- **リアルタイム差分表示**: ファイル編集中にサイン列で変更を可視化
- **インラインステージング**: エディタ内でhunk単位のGit操作
- **Git blame情報**: 各行の作者・コミット情報表示

#### 🎯 視覚的表示
```
  │ 1  local config = {}           # 変更なし
+ │ 2  config.new_feature = true   # 追加行（緑）
~ │ 3  config.old_setting = false  # 変更行（青）
- │ 4                              # 削除行（赤）
```

#### 🚀 高度な機能
- **ステージング**: `<leader>hs` で選択hunkをステージ
- **プレビュー**: `<leader>hp` でdiff詳細表示
- **ナビゲーション**: `]c` / `[c` でhunk間移動
- **Blame情報**: `<leader>hb` で行の詳細情報

---

## WezTerm統合設定

### 🖥️ Claude監視システム

#### ✨ 機能概要
- **リアルタイム検出**: CPU使用率ベースの状態判定
- **視覚的表示**: 絵文字とカラーコードによる状態表示
- **パフォーマンス最適化**: キャッシュ機能付きプロセス監視

#### 🤖 Claude実行状況表示
- **🤖** (idle) - Claude待機中（CPU < 1.0%）
- **⚡** (active) - Claude実行中（CPU > 1.0%）

#### 📊 ステータスバー表示
```
[Git Repository]  [Branch]   🤖⚡  [Time]
```

#### 🔧 設定詳細
```lua
-- Claude監視の設定
config.status_update_interval = 100  -- 0.1秒更新
CLAUDE_CONSTANTS = {
  CPU_ACTIVE_THRESHOLD = 1.0,     -- CPU使用率閾値
  EMOJI_IDLE = '🤖',              -- 待機中アイコン
  EMOJI_RUNNING = '⚡',           -- 実行中アイコン
}
```

### 🎨 テーマとレイアウト
- **タブバー**: 下部配置、Git情報表示
- **フォント**: JetBrains Mono / Monaco / Menlo
- **透明度**: 75%（背景）
- **キーバインド**: tmux風操作

---

## プラグイン詳細ガイド

### 🌈 hlchunk.nvim - コード構造可視化

#### 機能
- **インデントライン**: 階層構造の可視化
- **現在のチャンク**: アクティブなコードブロックをハイライト
- **ブランクライン**: 空行のインデント表示

#### 設定
```lua
require('hlchunk').setup({
  chunk = {
    enable = true,
    style = "#806d9c",
  },
  indent = {
    enable = true,
    chars = { "│", "¦", "┆", "┊" },
  }
})
```

### 📊 lualine.nvim - ステータスライン

#### カスタムコンポーネント
- **Flutter状態**: 実行中デバイス表示
- **Git情報**: ブランチ、変更統計
- **LSP状態**: アクティブサーバー表示
- **診断情報**: エラー・警告カウント

#### テーマ
```lua
require('lualine').setup {
  options = {
    theme = 'auto',
    component_separators = '|',
    section_separators = '',
  }
}
```

### 🔍 telescope.nvim - ファジーファインダー

#### 主要機能
- **ファイル検索**: `<leader>ff`
- **文字列検索**: `<leader>fg`
- **バッファ切り替え**: `<leader>fb`
- **Git操作**: `<leader>gc` (commits), `<leader>gb` (branches)

### 🌳 nvim-tree.lua - ファイルエクスプローラー

#### 設定
- **自動開閉**: プロジェクト開始時に自動表示
- **Git統合**: 変更ファイルの視覚的表示
- **アイコン**: Nerd Font対応

---

## VSCode統合機能

### 🚀 launch.json自動読み込み

#### 機能概要
- VSCodeの`launch.json`設定を自動読み込み
- Neovim DAP設定への自動変換
- Flutter専用設定の最適化

#### 対応設定
```json
{
  "name": "Flutter Debug",
  "type": "dart",
  "request": "launch",
  "program": "lib/main.dart",
  "args": ["--flavor", "dev"]
}
```

#### 使用方法
1. プロジェクトルートに`.vscode/launch.json`を配置
2. Neovimでプロジェクトを開く
3. `<F5>`でデバッグ開始（自動的にlaunch.json設定を使用）

---

## パフォーマンス最適化

### ⚡ 起動時間最適化
- **Lazy Loading**: プラグインの遅延読み込み
- **条件付き読み込み**: Flutter プロジェクトでのみ有効化
- **キャッシュ**: 設定ファイルのキャッシュ機能

### 🔧 メモリ使用量最適化
- **不要プラグインの無効化**: 必要最小限の構成
- **バッファ管理**: 自動クリーンアップ
- **LSPサーバー管理**: プロジェクト終了時の自動停止

---

## 緊急時の対処法

### 🆘 設定が壊れた場合
```bash
# バックアップから復元
cp ~/.config/nvim/init.lua.backup ~/.config/nvim/init.lua

# 初期化
rm -rf ~/.local/share/nvim/lazy
nvim  # プラグイン再インストール
```

### 🔧 プラグインエラー
```vim
:Lazy clean    " 不要プラグイン削除
:Lazy update   " プラグイン更新
:Lazy restore  " バックアップから復元
```

### 📱 Flutter接続問題
```bash
flutter doctor              # 環境確認
flutter devices             # デバイス一覧
adb kill-server && adb start-server  # ADB再起動
```