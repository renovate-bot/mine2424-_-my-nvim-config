#!/bin/bash

# ===============================================
# Flutter開発環境 クイックセットアップ
# ===============================================

set -e

# カラー出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}⚡ Flutter開発環境 クイックセットアップ${NC}"
echo "=============================================="

# 現在のディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")"

# 必要なツールの確認
echo -e "${BLUE}🔍 必要なツールを確認中...${NC}"

MISSING_TOOLS=()

check_tool() {
    if ! command -v $1 &> /dev/null; then
        MISSING_TOOLS+=($1)
        echo -e "${YELLOW}⚠️  $1 が見つかりません${NC}"
    else
        echo -e "${GREEN}✅ $1${NC}"
    fi
}

check_tool "nvim"
check_tool "git"

# 不足ツールの報告
if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    echo -e "${RED}❌ 不足しているツール: ${MISSING_TOOLS[*]}${NC}"
    echo -e "${CYAN}完全セットアップスクリプトを実行してください:${NC}"
    echo -e "${YELLOW}./setup-flutter-dev-env.sh${NC}"
    exit 1
fi

# 設定ファイルのバックアップと配置
echo -e "${BLUE}📂 設定ファイルを配置中...${NC}"

# タイムスタンプ
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Neovim設定
if [ -d ~/.config/nvim ]; then
    echo -e "${YELLOW}既存のNeovim設定をバックアップ中...${NC}"
    mv ~/.config/nvim ~/.config/nvim.backup.$TIMESTAMP
fi

mkdir -p ~/.config/nvim/lua
cp "$CONFIG_DIR/init.lua" ~/.config/nvim/
cp -r "$CONFIG_DIR/lua"/* ~/.config/nvim/lua/

echo -e "${GREEN}✅ Neovim設定を配置しました${NC}"

# WezTerm設定（オプション）
if [ -f "$CONFIG_DIR/wezterm.lua" ]; then
    if [ -f ~/.wezterm.lua ]; then
        echo -e "${YELLOW}既存のWezTerm設定をバックアップ中...${NC}"
        mv ~/.wezterm.lua ~/.wezterm.lua.backup.$TIMESTAMP
    fi
    
    cp "$CONFIG_DIR/wezterm.lua" ~/.wezterm.lua
    echo -e "${GREEN}✅ WezTerm設定を配置しました${NC}"
fi

# スクリプトを実行可能にする
chmod +x "$CONFIG_DIR/scripts"/*.sh

# 初期プラグインインストール
echo -e "${BLUE}🔌 Neovimプラグインを初期化中...${NC}"
echo -e "${CYAN}初回起動時にプラグインが自動インストールされます${NC}"

# 完了メッセージ
echo -e "${GREEN}"
echo "🎉 クイックセットアップ完了！"
echo "=========================="
echo -e "${NC}"

echo -e "${CYAN}次のステップ:${NC}"
echo -e "${YELLOW}1. nvim を起動してプラグインのインストール完了を確認${NC}"
echo -e "${YELLOW}2. Flutter開発を開始: nvim your_flutter_project${NC}"

if command -v wezterm &> /dev/null; then
    echo -e "${YELLOW}3. WezTermでClaude統合機能を確認${NC}"
    echo ""
    echo -e "${BLUE}🎯 WezTerm機能:${NC}"
    echo -e "${CYAN}• Ctrl+Space → w : 3ペイン自動分割レイアウト${NC}"
    echo -e "${CYAN}• 右下ステータス : Claude実行状態 + Git情報${NC}"
    echo -e "${CYAN}• タスク完了通知 : 音声・視覚通知システム${NC}"
    echo -e "${CYAN}• Nerd Fonts対応 : アイコン表示サポート${NC}"
fi

echo ""
echo -e "${BLUE}💡 Nerd Fontsインストール:${NC}"
echo -e "${CYAN}フルセットアップでNerd Fontsを自動インストール:${NC}"
echo -e "${YELLOW}./scripts/setup-flutter-dev-env.sh${NC}"

echo ""
echo -e "${BLUE}📚 詳細なドキュメント:${NC}"
echo -e "${CYAN}• FLUTTER_WORKFLOW.md - 完全な開発ガイド${NC}"
echo -e "${CYAN}• FLUTTER_KEYBINDINGS.md - キーバインド一覧${NC}"

echo -e "${GREEN}Happy Coding! 🚀${NC}"