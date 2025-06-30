# Flutter開発環境 セットアップガイド

## 🚀 自動セットアップ（推奨）

### macOS ユーザー

**完全自動セットアップ（推奨）**
```bash
# このリポジトリをクローン
git clone <repository-url> ~/flutter-dev-config
cd ~/flutter-dev-config

# 完全セットアップスクリプトを実行
./scripts/setup-flutter-dev-env.sh
```

**クイックセットアップ（Neovimが既にある場合）**
```bash
# 設定ファイルのみを配置
./scripts/quick-setup.sh
```

---

## 🔧 手動セットアップ

### 1. 前提条件のインストール

#### macOS
```bash
# Homebrew経由でインストール
brew install neovim wezterm tmux git ripgrep fd fzf
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono flutter
```

#### Ubuntu/Debian
```bash
# 必要なパッケージをインストール
sudo apt update
sudo apt install -y curl git build-essential

# Neovim (最新版)
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux64.tar.gz
echo 'export PATH="$PATH:/opt/nvim-linux64/bin"' >> ~/.bashrc

# その他のツール
sudo apt install -y tmux ripgrep fd-find fzf

# WezTerm
curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
sudo apt update
sudo apt install wezterm

# Flutter SDK
sudo snap install flutter --classic
```

#### Arch Linux
```bash
# 必要なパッケージをインストール
sudo pacman -S neovim wezterm tmux git ripgrep fd fzf ttf-jetbrains-mono

# Flutter (AUR)
yay -S flutter
```

#### Windows (WSL2推奨)
```powershell
# WSL2のUbuntuセットアップ後、Ubuntu手順に従う
# または以下のWindows Nativeセットアップ

# Chocolatey経由
choco install neovim git ripgrep fd fzf
choco install wezterm flutter

# または Scoop経由
scoop install neovim git ripgrep fd fzf
scoop bucket add extras
scoop install wezterm
```

### 2. 設定ファイルの配置

#### 既存設定のバックアップ
```bash
# Neovim設定をバックアップ
mv ~/.config/nvim ~/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)

# WezTerm設定をバックアップ（存在する場合）
mv ~/.wezterm.lua ~/.wezterm.lua.backup.$(date +%Y%m%d_%H%M%S)
```

#### 新しい設定の配置
```bash
# このリポジトリをクローン
git clone <repository-url> ~/flutter-dev-config
cd ~/flutter-dev-config

# Neovim設定ディレクトリを作成
mkdir -p ~/.config/nvim/lua

# 設定ファイルをコピー
cp init.lua ~/.config/nvim/
cp -r lua/* ~/.config/nvim/lua/
cp wezterm.lua ~/.wezterm.lua

# 安定版の設定を確認（init.luaでflutter-dev-minimalが読み込まれていることを確認）
grep "flutter-dev-minimal" ~/.config/nvim/init.lua

# スクリプトを実行可能にする
chmod +x scripts/*.sh
```

### 3. 開発ツールの設定

#### 開発スクリプトのインストール
```bash
# ~/bin ディレクトリを作成
mkdir -p ~/bin

# 開発ツールのシンボリックリンク作成
ln -sf ~/flutter-dev-config/scripts/flutter-utils.sh ~/bin/flutter-utils
ln -sf ~/flutter-dev-config/scripts/flutter-dev-setup.sh ~/bin/flutter-new

# PATHに~/binを追加（シェル設定ファイルに追加）
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc  # Bashの場合
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc   # Zshの場合
```

#### Flutter SDKの設定
```bash
# Flutter SDKのパスを確認
which flutter

# 環境変数を設定（シェル設定ファイルに追加）
echo 'export FLUTTER_ROOT="/path/to/flutter"' >> ~/.bashrc
echo 'export PATH="$FLUTTER_ROOT/bin:$PATH"' >> ~/.bashrc

# 設定を反映
source ~/.bashrc
```

### 4. 初期化とテスト

#### Neovim プラグインの初期化
```bash
# Neovimを起動して自動的にプラグインがインストールされることを確認
nvim

# 初回起動時にlazy.nvimが自動的にプラグインをダウンロード・インストールします
# プロセスが完了したら :qa で終了
```

#### Flutter環境の確認
```bash
# Flutter Doctor を実行
flutter doctor

# 不足している依存関係があれば指示に従ってインストール
```

#### 動作テスト
```bash
# テスト用のFlutterプロジェクトを作成
flutter create test_project
cd test_project

# Neovimで開く
nvim .

# Dartファイル（lib/main.dart）を開いてLSP機能をテスト:
# - シンタックスハイライト
# - コード補完
# - エラー検出
# - 定義ジャンプ（gd）
```

---

## 🔧 カスタマイズ

### プロジェクト固有設定

各Flutterプロジェクトに `.nvimrc` を作成してプロジェクト固有の設定を追加可能：

```lua
-- .nvimrc (プロジェクトルート)
-- プロジェクト固有のキーマップ
vim.keymap.set('n', '<Leader>Fs', ':!flutter run --flavor staging<CR>')
vim.keymap.set('n', '<Leader>Fp', ':!flutter run --flavor production<CR>')

-- プロジェクト固有の設定
vim.opt_local.colorcolumn = "100"
```

### 個人設定の追加

```lua
-- ~/.config/nvim/lua/personal.lua を作成
-- カスタムキーマップ
vim.keymap.set('n', '<Leader>Fm', ':!flutter run --flavor main<CR>')

-- カスタム設定
vim.opt.background = "dark"

-- init.luaで読み込み
-- require('personal')
```

### 🆕 VSCode統合の設定

#### launch.json と tasks.json の作成

```bash
# プロジェクトのルートで実行
mkdir -p .vscode

# launch.json のサンプルをコピー
cp ~/.config/nvim/.vscode/launch.json .vscode/
cp ~/.config/nvim/.vscode/tasks.json .vscode/

# 必要に応じて編集
nvim .vscode/launch.json
nvim .vscode/tasks.json
```

#### mise/asdf環境での自動パス検出

```bash
# mise を使用している場合
mise install dart@latest flutter@latest
mise local dart@latest flutter@latest

# asdf を使用している場合  
asdf install dart latest
asdf install flutter latest
asdf local dart latest
asdf local flutter latest

# Neovimが自動的にパスを検出します
# 手動設定は不要です
```

#### VSCode統合機能の使用方法

1. **タスク実行**: `<Leader>vr` でVSCodeタスク選択
2. **Launch設定**: `<Leader>vl` で起動設定選択
3. **デバッグ**: F5キーでVSCode launch.json基準のデバッグ開始
4. **タスクリスト**: `<Leader>vt` でタスク管理UI表示

---

## 🆘 トラブルシューティング

### よくある問題

#### 1. Neovimでプラグインが読み込まれない

**症状**: Dartファイルを開いてもLSP機能が動作しない

**解決方法**:
```bash
# プラグインディレクトリを確認
ls ~/.local/share/nvim/lazy/

# 手動でプラグインを再インストール
nvim -c "Lazy sync" -c "qa"

# または設定をリセット
rm -rf ~/.local/share/nvim/lazy
nvim  # 再インストールが自動実行される
```

#### 1.5. nvim-dap-ui エラー（"nvim-nio required"）

**症状**: `Failed to run config for nvim-dap` または `nvim-dap-ui requires nvim-nio`

**解決方法**:
```bash
# 安定版に切り替え（推奨）
# ~/.config/nvim/init.lua を編集
# require('flutter-dev-minimal')  # この行を有効化
# -- require('flutter-dev-with-dap')  # この行をコメントアウト

# プラグインキャッシュを完全削除
rm -rf ~/.local/share/nvim/lazy && rm -rf ~/.cache/nvim

# Neovimを再起動
nvim

# または、上級者向け: DAP機能を有効にする場合
# ~/.config/nvim/init.lua で flutter-dev-with-dap を使用
# ただし依存関係の問題が発生する可能性があります
```

#### 2. Flutter SDKが見つからない

**症状**: `flutter command not found`

**解決方法**:
```bash
# Flutter SDKのパスを確認
echo $PATH | grep flutter

# 環境変数を正しく設定
export PATH="/path/to/flutter/bin:$PATH"

# 永続化（シェル設定ファイルに追加）
echo 'export PATH="/path/to/flutter/bin:$PATH"' >> ~/.bashrc
```

#### 3. WezTermでワークスペースが動作しない

**症状**: Flutter専用レイアウトが作成されない

**解決方法**:
```bash
# pubspec.yamlの存在確認
ls -la pubspec.yaml

# WezTerm設定の確認
wezterm --config-file ~/.wezterm.lua

# 手動ワークスペース作成
# Cmd+Alt+F (macOS) でマニュアル作成
```

#### 4. フォントが正しく表示されない

**症状**: リガチャーや特殊文字が正しく表示されない

**解決方法**:
```bash
# JetBrains Monoフォントの再インストール
# macOS
brew reinstall --cask font-jetbrains-mono

# Linux
# https://github.com/JetBrains/JetBrainsMono/releases から手動ダウンロード
```

### ログとデバッグ

#### Neovimログの確認
```vim
" Neovim内で実行
:messages
:checkhealth
:Lazy log
```

#### Flutter診断
```bash
flutter doctor -v
flutter config
```

---

## 📞 サポート

### ドキュメント

- **[Flutter開発ワークフロー](FLUTTER_WORKFLOW.md)** - 詳細な使用方法
- **[キーバインド一覧](FLUTTER_KEYBINDINGS.md)** - 全ショートカット
- **[README.md](README.md)** - プロジェクト概要

### コミュニティリソース

- [Flutter公式ドキュメント](https://docs.flutter.dev/)
- [Neovim公式ドキュメント](https://neovim.io/doc/)
- [WezTerm公式ドキュメント](https://wezfurlong.org/wezterm/)

### 問題報告

設定やスクリプトに問題がある場合は、以下の情報と共に報告してください：

1. OS・バージョン
2. Neovim・Flutter・WezTermのバージョン
3. エラーメッセージ
4. 実行したコマンド

---

**🎯 Happy Flutter Development!**