# WezTerm Configuration for tmux + Neovim + Flutter Development (Claude Code統合版)

このドキュメントでは、Claude Code統合機能を含む、tmux + Neovim + Flutter開発環境に最適化されたWezTerm設定について説明します。

## 🚀 新機能ハイライト

### Claude Code統合機能
- **リアルタイムステータス表示**: Claude Codeの実行状態をステータスバーに表示（🤖待機中・⚡実行中）
- **高精度プロセス監視**: CPU使用率・プロセス状態・ファイルディスクリプタ数による判定
- **完了通知システム**: Claudeタスク完了時の音声・視覚通知

### Git情報表示
- **リポジトリ名自動表示**: remote URL・toplevel・ディレクトリ名から自動抽出
- **ブランチ情報**: 現在のブランチ名をカラー表示
- **worktree対応**: bare/gitリポジトリでの適切な名前抽出

### 開発効率化機能
- **Leader機能**: Ctrl+Space でのtmux風操作（`Ctrl+Space` → `w` で3ペイン自動分割）
- **タブアイコン**: プロセス別の視覚的識別
- **OS自動最適化**: macOS/Linux/Windows対応の設定分岐

## 📋 目次

- [インストールと設定](#インストールと設定)
- [主な機能](#主な機能)
- [キーバインド](#キーバインド)
- [Flutter開発機能](#flutter開発機能)
- [カスタマイズ](#カスタマイズ)
- [トラブルシューティング](#トラブルシューティング)

## 🚀 インストールと設定

### 1. WezTermのインストール

```bash
# macOS (Homebrew)
brew install --cask wezterm

# または公式サイトからダウンロード
# https://wezfurlong.org/wezterm/installation.html
```

### 2. 設定ファイルの配置

```bash
# 設定ファイルをホームディレクトリにコピー
cp wezterm.lua ~/.wezterm.lua

# または、シンボリックリンクを作成
ln -s $(pwd)/wezterm.lua ~/.wezterm.lua
```

### 3. 必要な依存関係

```bash
# tmuxのインストール
brew install tmux

# 推奨フォント（JetBrains Mono）のインストール
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono

# Flutter SDK（Flutter開発の場合）
brew install --cask flutter
```

## ✨ 主な機能

### 🎨 視覚的特徴
- **カラースキーム**: Solarized Dark（tmux/nvimとの一貫性）
- **フォント**: JetBrains Mono（プログラミング最適化）
- **透明度**: 背景95%透明度でmacOSのBlur効果
- **タブバー**: 下部配置でプロセス表示

### ⚡ パフォーマンス最適化
- **GPU加速**: WebGPU使用
- **高フレームレート**: 60fps設定
- **効率的なスクロールバック**: 10,000行保持
- **視覚的ベル**: 音声ベルを無効化し、視覚的フィードバックを使用
- **カーソル設定**: 点滅ブロックカーソルで視認性向上

### 🔧 tmux統合
- **自動tmuxセッション**: 起動時に`main`セッションを開始
- **競合回避**: tmuxキーバインドとの競合を最小化
- **ペイン間移動**: Shift+Ctrl+矢印キーでペイン移動

## ⌨️ キーバインド

### 🎯 Leader機能（新機能）
**Leader Key**: `Ctrl + Space`

| キーバインド | 機能 |
|-------------|------|
| `Ctrl+Space` → `s` | 垂直分割 |
| `Ctrl+Space` → `v` | 水平分割 |
| `Ctrl+Space` → `q` | 現在のペインを閉じる |
| `Ctrl+Space` → `h` | 左のペインに移動 |
| `Ctrl+Space` → `j` | 下のペインに移動 |
| `Ctrl+Space` → `k` | 上のペインに移動 |
| `Ctrl+Space` → `l` | 右のペインに移動 |
| `Ctrl+Space` → `c` | コピーモード開始 |
| `Ctrl+Space` → `w` | **3ペイン自動分割レイアウト** |

### 基本操作
| キーバインド | 機能 |
|-------------|------|
| `Cmd + T` | 新しいタブを作成 |
| `Cmd + W` | 現在のタブを閉じる |
| `Cmd + D` | 水平分割 |
| `Cmd + Shift + D` | 垂直分割 |
| `Shift + Ctrl + N` | フルスクリーン切り替え |

### ペイン操作（レガシー・互換性維持）
| キーバインド | 機能 |
|-------------|------|
| `Shift + Ctrl + ←` | 左のペインに移動 |
| `Shift + Ctrl + →` | 右のペインに移動 |
| `Shift + Ctrl + ↑` | 上のペインに移動 |
| `Shift + Ctrl + ↓` | 下のペインに移動 |

### スクロール・ナビゲーション
| キーバインド | 機能 |
|-------------|------|
| `Shift + Ctrl + U` | 半ページ上スクロール |
| `Shift + Ctrl + D` | 半ページ下スクロール |
| `Shift + Ctrl + G` | 最下部にジャンプ |
| `Ctrl + H/J/K/L` | Vim風カーソル移動 |

### フォント調整
| キーバインド | 機能 |
|-------------|------|
| `Cmd + =` | フォントサイズを大きく |
| `Cmd + -` | フォントサイズを小さく |
| `Cmd + 0` | フォントサイズをリセット |
| `Ctrl + Shift + +` | フォントサイズを大きく（代替） |
| `Ctrl + Shift + _` | フォントサイズを小さく（代替） |
| `Ctrl + Shift + Backspace` | フォントサイズをリセット（代替） |

### 🤖 Claude Code統合機能

#### ステータス表示
WezTermの右下に以下の情報が表示されます：

**Git情報**:
- ` repo-name  branch-name`
- 例: ` my-nvim-config  main`

**Claude状態**:
- `🤖` : Claude待機中
- `⚡` : Claude実行中
- `🧔` : 非Claudeタブ

#### 通知機能
- **音声通知**: Claudeタスク完了時に音声再生（OS別サウンド）
- **トースト通知**: ウィンドウに完了メッセージ表示（3秒間）

### Flutter開発専用
| キーバインド | 機能 |
|-------------|------|
| `Cmd + Shift + R` | `flutter run` を実行 |
| `Cmd + Shift + H` | `flutter run --hot-reload` を実行 |

### 開発効率化コマンド
| キーバインド | 機能 |
|-------------|------|
| `Cmd + Shift + G` | `git status` を実行 |
| `Cmd + Shift + L` | `ls -la` を実行 |
| `Cmd + K` | ターミナルをクリア |

## 🎯 Flutter開発機能

### クイックコマンド
設定には以下のFlutter開発用ショートカットが含まれています：

```lua
-- Flutter実行コマンド
{
  key = 'r',
  mods = 'CMD|SHIFT',
  action = wezterm.action.SendString 'flutter run\r',
}
```

### 環境変数設定
```lua
config.set_environment_variables = {
  FLUTTER_ROOT = '/opt/homebrew/bin/flutter',
  ANDROID_HOME = os.getenv('HOME') .. '/Library/Android/sdk',
  JAVA_HOME = '/Library/Java/JavaVirtualMachines/openjdk-11.jdk/Contents/Home',
}
```

### ハイパーリンク認識
- Flutterエラーメッセージ内のファイルパスを自動認識
- パッケージURLの認識
- スタックトレースからのファイル移動

## 🛠️ カスタマイズ

### フォント変更
```lua
config.font = wezterm.font_with_fallback {
  'Your Preferred Font',
  'SF Mono',
  'Menlo',
}
config.font_size = 16.0  -- お好みのサイズ
```

### カラースキーム変更
```lua
config.color_scheme = 'Your Preferred Scheme'
-- 利用可能なスキーム: 'Dracula', 'Nord', 'Tomorrow Night', etc.
```

### 透明度調整
```lua
config.window_background_opacity = 1.0  -- 完全不透明
config.macos_window_background_blur = 0  -- Blur効果なし
```

### 追加キーバインド
```lua
-- カスタムキーバインドの追加例
table.insert(config.keys, {
  key = 'k',
  mods = 'CMD',
  action = wezterm.action.SendString 'kubectl get pods\r',
})
```

## 🌐 リモート開発とSSH接続

### SSH接続設定
WezTermではSSH接続を簡単に管理できます：

```lua
config.ssh_domains = {
  {
    name = 'server',
    remote_address = 'your-server.example.com',
    username = 'your-username',
  },
}
```

### リモート接続の使用方法
1. **新しいSSH接続**: `Cmd + Shift + P` → "SSH to server"
2. **既存接続の再利用**: 設定したドメイン名で接続

### テキスト選択の最適化
- **単語境界設定**: プログラミングに適した単語選択
- **マウス操作**: Shiftキーでマウスレポート回避

## 🔧 開発ワークフロー最適化

### 推奨tmux設定
```bash
# ~/.tmux.conf に追加
set -g default-terminal "xterm-256color"
set -ga terminal-overrides ",*256col*:Tc"

# マウス操作を有効化
set -g mouse on

# Neovimとの統合
set -sg escape-time 0
```

### Neovim統合
この設定はNeovimの以下の機能と最適化されています：
- TrueColor対応
- クリップボード統合
- ターミナル内Neovim使用時の快適性

## 🐛 トラブルシューティング

### よくある問題と解決方法

#### 1. 視覚的ベルが気になる場合
```lua
-- 視覚的ベルを無効化
config.visual_bell = {
  fade_in_duration_ms = 0,
  fade_out_duration_ms = 0,
}
```

#### 2. ウィンドウパディングの調整
```lua
-- パディングを変更
config.window_padding = {
  left = 4,   -- 左側のパディング
  right = 4,  -- 右側のパディング
  top = 4,    -- 上側のパディング
  bottom = 4, -- 下側のパディング
}
```

#### 3. フォントが表示されない
```bash
# フォントの再インストール
brew reinstall --cask font-jetbrains-mono
```

#### 4. tmuxセッションが自動開始されない
```bash
# tmuxのパスを確認
which tmux

# 設定ファイル内のパスを更新
config.default_prog = { '/usr/local/bin/tmux', 'new-session', '-A', '-s', 'main' }
```

#### 5. Flutter環境変数が認識されない
```bash
# Flutter SDKのパスを確認
which flutter

# 設定ファイル内のパスを更新
FLUTTER_ROOT = '/path/to/your/flutter',
```

#### 6. GPU加速が効かない
```lua
-- フォールバック設定
config.front_end = 'OpenGL'  -- WebGpuの代わりに使用
```

### ログ確認方法
```bash
# WezTermのログを確認
tail -f ~/.local/share/wezterm/wezterm.log
```

## 📝 設定更新手順

1. **設定ファイルの編集**
   ```bash
   nvim ~/.wezterm.lua
   ```

2. **設定の再読み込み**
   - WezTermを再起動
   - または設定を変更後、WezTermが自動的に検出して適用

3. **変更の確認**
   - 新しいタブまたはウィンドウで動作確認

## 🔗 関連リンク

- [WezTerm公式ドキュメント](https://wezfurlong.org/wezterm/)
- [tmux公式ドキュメント](https://github.com/tmux/tmux/wiki)
- [Flutter公式ドキュメント](https://flutter.dev/docs)
- [JetBrains Monoフォント](https://www.jetbrains.com/lp/mono/)

## 📄 ライセンス

この設定ファイルはMITライセンスの下で公開されています。

---

**Note**: この設定は継続的に改善されています。新しい機能や最適化があれば、このドキュメントも更新されます。
