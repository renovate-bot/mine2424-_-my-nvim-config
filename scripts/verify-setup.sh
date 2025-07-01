#!/bin/bash

# ===============================================
# Flutter開発環境 セットアップテスト
# ===============================================

set -e

# カラー出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧪 Flutter開発環境 セットアップテスト${NC}"
echo "=============================================="

# テスト結果のカウンター
TESTS_PASSED=0
TESTS_FAILED=0

# テスト関数
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_result="$3"
    
    echo -e "${BLUE}🔍 テスト: $test_name${NC}"
    
    if eval "$test_command" >/dev/null 2>&1; then
        if [ "$expected_result" = "pass" ]; then
            echo -e "${GREEN}✅ 成功${NC}"
            ((TESTS_PASSED++))
        else
            echo -e "${RED}❌ 失敗（予期しない成功）${NC}"
            ((TESTS_FAILED++))
        fi
    else
        if [ "$expected_result" = "fail" ]; then
            echo -e "${GREEN}✅ 成功（期待通りの失敗）${NC}"
            ((TESTS_PASSED++))
        else
            echo -e "${RED}❌ 失敗${NC}"
            ((TESTS_FAILED++))
        fi
    fi
}

# 必要なツールの存在チェック
echo -e "${BLUE}📋 必要なツールの確認${NC}"

run_test "Neovim インストール確認" "command -v nvim" "pass"
run_test "Git インストール確認" "command -v git" "pass"
run_test "Flutter インストール確認" "command -v flutter" "pass"
run_test "WezTerm インストール確認" "command -v wezterm" "pass"

# 設定ファイルの存在チェック
echo -e "${BLUE}📁 設定ファイルの確認${NC}"

run_test "Neovim設定ファイル存在確認" "test -f ~/.config/nvim/init.lua" "pass"
run_test "Flutter開発設定存在確認" "test -f ~/.config/nvim/lua/flutter-dev.lua" "pass"
run_test "WezTerm設定ファイル存在確認" "test -f ~/.wezterm.lua" "pass"

# Neovim設定の妥当性チェック
echo -e "${BLUE}⚙️  Neovim設定の確認${NC}"

run_test "Neovim設定構文チェック" "nvim --headless -c 'qa'" "pass"
run_test "Flutter設定読み込み確認" "grep -q 'require.*flutter-dev' ~/.config/nvim/init.lua" "pass"

# プラグイン依存関係の確認
run_test "nvim-nio プラグイン確認" "test -d ~/.local/share/nvim/lazy/nvim-nio" "pass"
run_test "flutter-tools プラグイン確認" "test -d ~/.local/share/nvim/lazy/flutter-tools.nvim" "pass"

# Flutter環境のチェック
echo -e "${BLUE}🎯 Flutter環境の確認${NC}"

if command -v flutter >/dev/null 2>&1; then
    run_test "Flutter Doctor実行" "flutter doctor --version" "pass"
    
    # Dart SDKの確認
    run_test "Dart SDK確認" "command -v dart" "pass"
    
    # Flutter SDKパスの確認
    FLUTTER_ROOT=$(flutter config | grep "flutter-root" | cut -d':' -f2 | xargs)
    if [ -n "$FLUTTER_ROOT" ] && [ -d "$FLUTTER_ROOT" ]; then
        echo -e "${GREEN}✅ Flutter SDK パス確認: $FLUTTER_ROOT${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ Flutter SDK パスが不正${NC}"
        ((TESTS_FAILED++))
    fi
else
    echo -e "${YELLOW}⚠️  Flutter SDKが見つかりません${NC}"
    ((TESTS_FAILED++))
fi

# プラグインディレクトリの確認
echo -e "${BLUE}🔌 プラグイン環境の確認${NC}"

run_test "lazy.nvim ディレクトリ確認" "test -d ~/.local/share/nvim/lazy" "pass"

if [ -d ~/.local/share/nvim/lazy ]; then
    PLUGIN_COUNT=$(ls ~/.local/share/nvim/lazy | wc -l)
    if [ $PLUGIN_COUNT -gt 10 ]; then
        echo -e "${GREEN}✅ プラグイン数確認: $PLUGIN_COUNT 個${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${YELLOW}⚠️  プラグイン数が少ない: $PLUGIN_COUNT 個${NC}"
        ((TESTS_FAILED++))
    fi
fi

# 開発スクリプトの確認
echo -e "${BLUE}🛠️  開発スクリプトの確認${NC}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_test "flutter-utils スクリプト確認" "test -x $SCRIPT_DIR/flutter-utils.sh" "pass"
run_test "flutter-dev-setup スクリプト確認" "test -x $SCRIPT_DIR/flutter-dev-setup.sh" "pass"

# ~/bin の設定確認
if [ -d ~/bin ]; then
    run_test "~/bin/flutter-utils 確認" "test -L ~/bin/flutter-utils" "pass"
    run_test "~/bin/flutter-new 確認" "test -L ~/bin/flutter-new" "pass"
else
    echo -e "${YELLOW}⚠️  ~/bin ディレクトリが見つかりません${NC}"
fi

# 実際のNeovim機能テスト
echo -e "${BLUE}🧪 実機能テスト${NC}"

# 一時的なテストファイルを作成
TEST_DIR=$(mktemp -d)
cat > "$TEST_DIR/test.dart" << 'EOF'
void main() {
  print('Hello, Flutter!');
}
EOF

# Neovimでファイルを開いてすぐ閉じる（プラグイン読み込みテスト）
if nvim --headless -c "edit $TEST_DIR/test.dart" -c "sleep 2" -c "qa" 2>/dev/null; then
    echo -e "${GREEN}✅ Dartファイル読み込みテスト成功${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${RED}❌ Dartファイル読み込みテスト失敗${NC}"
    ((TESTS_FAILED++))
fi

# クリーンアップ
rm -rf "$TEST_DIR"

# 結果サマリー
echo ""
echo -e "${BLUE}📊 テスト結果サマリー${NC}"
echo "=============================="
echo -e "${GREEN}✅ 成功: $TESTS_PASSED${NC}"
echo -e "${RED}❌ 失敗: $TESTS_FAILED${NC}"

TOTAL_TESTS=$((TESTS_PASSED + TESTS_FAILED))
if [ $TOTAL_TESTS -gt 0 ]; then
    SUCCESS_RATE=$((TESTS_PASSED * 100 / TOTAL_TESTS))
    echo -e "${BLUE}📈 成功率: $SUCCESS_RATE%${NC}"
fi

echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 すべてのテストが成功しました！${NC}"
    echo -e "${GREEN}Flutter開発環境は正常に動作しています${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  一部のテストが失敗しました${NC}"
    echo -e "${CYAN}詳細については SETUP_GUIDE.md のトラブルシューティングを参照してください${NC}"
    exit 1
fi