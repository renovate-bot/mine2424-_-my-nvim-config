#!/bin/bash

# ===============================================
# Flutter開発環境 初期セットアップスクリプト
# ===============================================

set -e

# カラー出力用の定数
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ロゴ表示
echo -e "${BLUE}"
cat << 'EOF'
🚀 Flutter Development Environment Setup
=========================================
Neovim + Flutter Tools (+ Optional WezTerm)

このスクリプトは以下をセットアップします:
✅ 必要なソフトウェアのインストール
✅ Neovim設定の配置
✅ Flutter開発環境の構築
✅ 開発用ツールの設定
🔧 WezTerm設定（オプション）
EOF
echo -e "${NC}"

# OS検出
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macOS"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "Linux"
    else
        echo "Unknown"
    fi
}

OS=$(detect_os)
echo -e "${CYAN}検出されたOS: $OS${NC}"

# 確認プロンプト
echo -e "${YELLOW}このスクリプトは以下の作業を行います:${NC}"
echo "1. 必要なソフトウェアをインストール (Homebrew経由)"
echo "2. 既存のNeovim設定をバックアップ"
echo "3. 新しい設定ファイルを配置"
echo "4. Flutter開発環境を構築"
echo "5. WezTerm設定を配置（利用可能な場合）"
echo ""
echo -e "${YELLOW}続行しますか? (y/N)${NC}"
read -r CONFIRM

if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}セットアップを中止しました${NC}"
    exit 0
fi

# Homebrewのインストールチェック
check_homebrew() {
    if ! command -v brew &> /dev/null; then
        echo -e "${YELLOW}Homebrewが見つかりません。インストールしますか? (y/N)${NC}"
        read -r INSTALL_BREW
        if [[ $INSTALL_BREW =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}Homebrewをインストール中...${NC}"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            
            # Apple Silicon Macの場合のPATH設定
            if [[ "$OS" == "macOS" && $(uname -m) == "arm64" ]]; then
                echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
                eval "$(/opt/homebrew/bin/brew shellenv)"
            fi
        else
            echo -e "${RED}❌ Homebrewが必要です。手動でインストールしてください${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}✅ Homebrew が利用可能です${NC}"
    fi
}

# 必要なソフトウェアのインストール
install_software() {
    echo -e "${BLUE}🔧 必要なソフトウェアをインストール中...${NC}"
    
    local packages=(
        "neovim"
        "tmux"
        "git"
        "ripgrep"
        "fd"
        "fzf"
    )
    
    local optional_packages=(
        "wezterm"
    )
    
    local font_packages=(
        "font-jetbrains-mono-nerd-font"
        "font-fira-code-nerd-font"
        "font-hack-nerd-font"
        "font-cascadia-code-nerd-font"
        "font-meslo-lg-nerd-font"
        "font-inconsolata-nerd-font"
    )
    
    local cask_packages=(
        "flutter"
    )
    
    # 必須パッケージのインストール
    for package in "${packages[@]}"; do
        if brew list "$package" &>/dev/null; then
            echo -e "${GREEN}✅ $package は既にインストール済み${NC}"
        else
            echo -e "${BLUE}📦 $package をインストール中...${NC}"
            brew install "$package" || echo -e "${YELLOW}⚠️  $package のインストールに失敗しました${NC}"
        fi
    done
    
    # オプションパッケージのインストール
    for package in "${optional_packages[@]}"; do
        if brew list "$package" &>/dev/null; then
            echo -e "${GREEN}✅ $package は既にインストール済み${NC}"
        else
            echo -e "${BLUE}📦 $package (オプション) をインストール中...${NC}"
            brew install "$package" || echo -e "${CYAN}ℹ️  $package のインストールをスキップしました${NC}"
        fi
    done
    
    # Nerd Fontsのインストール
    echo -e "${BLUE}🔤 Nerd Fonts をインストール中...${NC}"
    for font in "${font_packages[@]}"; do
        if brew list --cask "$font" &>/dev/null; then
            echo -e "${GREEN}✅ $font は既にインストール済み${NC}"
        else
            echo -e "${BLUE}📦 $font をインストール中...${NC}"
            brew install --cask "$font" || echo -e "${CYAN}ℹ️  $font のインストールをスキップしました${NC}"
        fi
    done
    
    # Caskパッケージのインストール
    for package in "${cask_packages[@]}"; do
        if brew list --cask "$package" &>/dev/null; then
            echo -e "${GREEN}✅ $package は既にインストール済み${NC}"
        else
            echo -e "${BLUE}📦 $package をインストール中...${NC}"
            brew install --cask "$package" || echo -e "${YELLOW}⚠️  $package のインストールに失敗しました${NC}"
        fi
    done
}

# バックアップ作成
create_backup() {
    echo -e "${BLUE}💾 既存設定のバックアップを作成中...${NC}"
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    
    # Neovim設定のバックアップ
    if [ -d ~/.config/nvim ]; then
        echo -e "${BLUE}📁 Neovim設定をバックアップ中...${NC}"
        mv ~/.config/nvim ~/.config/nvim.backup.$timestamp
        echo -e "${GREEN}✅ ~/.config/nvim → ~/.config/nvim.backup.$timestamp${NC}"
    fi
    
    # WezTerm設定のバックアップ（オプション）
    if [ -f ~/.wezterm.lua ]; then
        echo -e "${BLUE}📁 WezTerm設定をバックアップ中...${NC}"
        mv ~/.wezterm.lua ~/.wezterm.lua.backup.$timestamp
        echo -e "${GREEN}✅ ~/.wezterm.lua → ~/.wezterm.lua.backup.$timestamp${NC}"
    fi
    
    # 既存のpacker設定をクリア（競合回避）
    if [ -d ~/.local/share/nvim/site/pack/packer ]; then
        echo -e "${BLUE}🧹 古いpacker設定をクリア中...${NC}"
        rm -rf ~/.local/share/nvim/site/pack/packer
        echo -e "${GREEN}✅ packer設定をクリアしました${NC}"
    fi
}

# 設定ファイルの配置
deploy_configs() {
    echo -e "${BLUE}📂 設定ファイルを配置中...${NC}"
    
    # 現在のスクリプトディレクトリを取得
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    CONFIG_DIR="$(dirname "$SCRIPT_DIR")"
    
    # Neovim設定ディレクトリ作成
    mkdir -p ~/.config/nvim/lua
    
    # 設定ファイルのコピー
    echo -e "${BLUE}📋 Neovim設定をコピー中...${NC}"
    cp "$CONFIG_DIR/init.lua" ~/.config/nvim/
    cp -r "$CONFIG_DIR/lua"/* ~/.config/nvim/lua/
    echo -e "${GREEN}✅ Neovim設定を配置しました${NC}"
    
    # WezTerm設定（オプション）
    if [ -f "$CONFIG_DIR/wezterm.lua" ]; then
        echo -e "${BLUE}📋 WezTerm設定をコピー中...${NC}"
        cp "$CONFIG_DIR/wezterm.lua" ~/.wezterm.lua
        echo -e "${GREEN}✅ WezTerm設定を配置しました${NC}"
    fi
    
    # スクリプトを実行可能にする
    echo -e "${BLUE}🔧 開発スクリプトを設定中...${NC}"
    chmod +x "$CONFIG_DIR/scripts"/*.sh
    
    # シンボリックリンクを作成（オプション）
    if [ ! -d ~/bin ]; then
        mkdir -p ~/bin
    fi
    
    ln -sf "$CONFIG_DIR/scripts/flutter-utils.sh" ~/bin/flutter-utils
    ln -sf "$CONFIG_DIR/scripts/flutter-dev-setup.sh" ~/bin/flutter-new
    
    echo -e "${GREEN}✅ 開発ツールを ~/bin に配置しました${NC}"
    echo -e "${CYAN}  flutter-utils: Flutter開発ユーティリティ${NC}"
    echo -e "${CYAN}  flutter-new: 新規Flutterプロジェクト作成${NC}"
}

# Flutter環境の確認
verify_flutter() {
    echo -e "${BLUE}🔍 Flutter環境を確認中...${NC}"
    
    if command -v flutter &> /dev/null; then
        echo -e "${GREEN}✅ Flutter SDK が利用可能です${NC}"
        flutter --version | head -1
        
        echo -e "${BLUE}📋 Flutter Doctor を実行中...${NC}"
        flutter doctor
    else
        echo -e "${YELLOW}⚠️  Flutter SDKが見つかりません${NC}"
        echo -e "${CYAN}手動で Flutter SDK をインストールしてください:${NC}"
        echo "https://docs.flutter.dev/get-started/install"
    fi
}

# Neovim プラグインの初期化
initialize_neovim() {
    echo -e "${BLUE}🔌 Neovim プラグインを初期化中...${NC}"
    
    # lazy.nvimのプラグインを事前インストール
    echo -e "${BLUE}📦 lazy.nvim でプラグインをインストール中...${NC}"
    nvim --headless -c "lua require('flutter-dev')" -c "qa" 2>/dev/null || true
    
    # Treesitterパーサーのインストール
    echo -e "${BLUE}🌳 Treesitter パーサーをインストール中...${NC}"
    nvim --headless -c "TSUpdate" -c "qa" 2>/dev/null || true
    
    echo -e "${GREEN}✅ Neovim プラグインを初期化しました${NC}"
}

# 環境設定の追加
setup_shell_env() {
    echo -e "${BLUE}🐚 シェル環境を設定中...${NC}"
    
    # Zshの場合
    if [ -n "$ZSH_VERSION" ] || [ "$SHELL" = "/bin/zsh" ] || [ "$SHELL" = "/usr/bin/zsh" ]; then
        local shell_config="$HOME/.zshrc"
    # Bashの場合
    else
        local shell_config="$HOME/.bashrc"
    fi
    
    # ~/binをPATHに追加
    if ! grep -q "export PATH=.*$HOME/bin" "$shell_config" 2>/dev/null; then
        echo "" >> "$shell_config"
        echo "# Flutter Development Tools" >> "$shell_config"
        echo "export PATH=\"\$HOME/bin:\$PATH\"" >> "$shell_config"
        echo -e "${GREEN}✅ ~/bin を PATH に追加しました${NC}"
    fi
    
    # Flutter環境変数の設定
    if command -v flutter &> /dev/null && ! grep -q "FLUTTER_ROOT" "$shell_config" 2>/dev/null; then
        local flutter_path=$(which flutter)
        local flutter_root=$(dirname "$(dirname "$flutter_path")")
        
        echo "export FLUTTER_ROOT=\"$flutter_root\"" >> "$shell_config"
        echo -e "${GREEN}✅ FLUTTER_ROOT を設定しました${NC}"
    fi
    
    echo -e "${CYAN}シェル設定を反映するには、ターミナルを再起動するか以下を実行してください:${NC}"
    echo "source $shell_config"
}

# セットアップ完了メッセージ
show_completion_message() {
    echo -e "${GREEN}"
    cat << 'EOF'
🎉 Flutter開発環境のセットアップが完了しました！
================================================

📋 インストールされたもの:
✅ Neovim (Flutter開発最適化済み)
✅ Flutter Tools & LSP
✅ 開発用ユーティリティスクリプト
✅ Nerd Fonts (アイコン表示対応)
🔧 WezTerm設定（オプション）

🚀 次のステップ:
EOF
    echo -e "${NC}"
    
    echo -e "${CYAN}1. ターミナルを再起動して新しい設定を読み込み${NC}"
    echo -e "${CYAN}2. 新しいFlutterプロジェクトを作成: ${YELLOW}flutter-new my_app${NC}"
    echo -e "${CYAN}3. 既存プロジェクトで開発: ${YELLOW}cd project && nvim .${NC}"
    
    if command -v wezterm &> /dev/null; then
        echo -e "${CYAN}4. WezTerm を起動: ${YELLOW}open -a WezTerm${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}📚 ドキュメント:${NC}"
    echo -e "${CYAN}• Flutter開発ワークフロー: FLUTTER_WORKFLOW.md${NC}"
    echo -e "${CYAN}• キーバインド一覧: FLUTTER_KEYBINDINGS.md${NC}"
    
    echo ""
    echo -e "${PURPLE}🔧 利用可能なコマンド:${NC}"
    echo -e "${CYAN}• flutter-utils: Flutter開発ユーティリティ${NC}"
    echo -e "${CYAN}• flutter-new: 新規プロジェクト作成${NC}"
    
    echo ""
    echo -e "${GREEN}Happy Flutter Development! 🎯${NC}"
}

# エラーハンドリング
handle_error() {
    echo -e "${RED}"
    echo "❌ セットアップ中にエラーが発生しました"
    echo "エラー発生行: $1"
    echo "詳細なログを確認し、手動で対処してください"
    echo -e "${NC}"
    exit 1
}

# エラートラップの設定
trap 'handle_error $LINENO' ERR

# メイン実行フロー
main() {
    echo -e "${BLUE}🚀 Flutter開発環境セットアップを開始します...${NC}"
    
    # macOSのみサポート（現在）
    if [ "$OS" != "macOS" ]; then
        echo -e "${YELLOW}⚠️  現在このスクリプトはmacOSのみをサポートしています${NC}"
        echo -e "${CYAN}Linux/Windows用の手動セットアップガイドは README.md を参照してください${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}📋 セットアップ手順:${NC}"
    echo "1. Homebrewの確認・インストール"
    echo "2. 必要なソフトウェアのインストール"
    echo "3. 既存設定のバックアップ"
    echo "4. 新しい設定の配置"
    echo "5. Flutter環境の確認"
    echo "6. Neovimプラグインの初期化"
    echo "7. シェル環境の設定"
    echo ""
    
    # 各ステップの実行
    check_homebrew
    install_software
    create_backup
    deploy_configs
    verify_flutter
    initialize_neovim
    setup_shell_env
    show_completion_message
}

# スクリプト実行
main "$@"