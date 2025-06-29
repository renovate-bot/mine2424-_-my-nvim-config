#!/bin/bash

# ===============================================
# Flutter開発ユーティリティスクリプト
# ===============================================

# カラー出力用の定数
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# 現在のディレクトリがFlutterプロジェクトかチェック
check_flutter_project() {
    if [ ! -f "pubspec.yaml" ]; then
        echo -e "${RED}❌ Not a Flutter project (pubspec.yaml not found)${NC}"
        exit 1
    fi
}

# 使用方法を表示
show_usage() {
    echo -e "${BLUE}Flutter Development Utilities${NC}"
    echo "============================"
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo -e "  ${GREEN}setup${NC}      - Quick project setup and dependency installation"
    echo -e "  ${GREEN}clean${NC}      - Clean project (flutter clean + pub get)"
    echo -e "  ${GREEN}devices${NC}    - List available devices"
    echo -e "  ${GREEN}emulators${NC}  - List and start emulators"
    echo -e "  ${GREEN}run${NC}        - Run app with device selection"
    echo -e "  ${GREEN}test${NC}       - Run tests with coverage"
    echo -e "  ${GREEN}build${NC}      - Build for production"
    echo -e "  ${GREEN}analyze${NC}    - Analyze and format code"
    echo -e "  ${GREEN}deps${NC}       - Dependency management"
    echo -e "  ${GREEN}workspace${NC}  - Setup WezTerm workspace"
    echo -e "  ${GREEN}doctor${NC}     - Run Flutter doctor and diagnostics"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -v, --verbose  Verbose output"
    echo ""
    echo "Examples:"
    echo "  $0 setup                    # Quick project setup"
    echo "  $0 run --device chrome      # Run on Chrome"
    echo "  $0 build --release          # Production build"
    echo "  $0 test --coverage          # Test with coverage"
}

# プロジェクトセットアップ
cmd_setup() {
    echo -e "${BLUE}🔧 Setting up Flutter project...${NC}"
    check_flutter_project
    
    flutter pub get
    flutter pub upgrade
    
    # 依存関係のキャッシュクリア
    flutter pub deps
    
    # コード生成（もしbuild_runnerがある場合）
    if grep -q "build_runner" pubspec.yaml; then
        echo -e "${BLUE}Running code generation...${NC}"
        flutter packages pub run build_runner build --delete-conflicting-outputs
    fi
    
    echo -e "${GREEN}✅ Project setup complete${NC}"
}

# プロジェクトクリーン
cmd_clean() {
    echo -e "${BLUE}🧹 Cleaning Flutter project...${NC}"
    check_flutter_project
    
    flutter clean
    flutter pub get
    
    # iOS/Androidの特定クリーンアップ
    if [ -d "ios" ]; then
        echo -e "${BLUE}Cleaning iOS...${NC}"
        cd ios
        rm -rf Pods/ Podfile.lock .symlinks/
        cd ..
    fi
    
    if [ -d "android" ]; then
        echo -e "${BLUE}Cleaning Android...${NC}"
        cd android
        ./gradlew clean 2>/dev/null || true
        cd ..
    fi
    
    echo -e "${GREEN}✅ Project cleaned${NC}"
}

# デバイス一覧表示
cmd_devices() {
    echo -e "${BLUE}📱 Available devices:${NC}"
    flutter devices
}

# エミュレータ管理
cmd_emulators() {
    echo -e "${BLUE}🖥️  Available emulators:${NC}"
    flutter emulators
    
    if [ "$2" = "--start" ] && [ -n "$3" ]; then
        echo -e "${BLUE}Starting emulator: $3${NC}"
        flutter emulators --launch $3
    elif [ "$2" = "--start" ]; then
        echo -e "${YELLOW}Available emulators to start:${NC}"
        flutter emulators --list | grep -E '^\s*•' | sed 's/^.*• //'
        echo ""
        echo "Usage: $0 emulators --start <emulator-id>"
    fi
}

# アプリ実行
cmd_run() {
    echo -e "${BLUE}🚀 Running Flutter app...${NC}"
    check_flutter_project
    
    local device=""
    local flavor=""
    local mode="debug"
    
    # オプション解析
    while [[ $# -gt 1 ]]; do
        shift
        case $1 in
            --device)
                device="--device-id $2"
                shift
                ;;
            --flavor)
                flavor="--flavor $2"
                shift
                ;;
            --release)
                mode="release"
                ;;
            --profile)
                mode="profile"
                ;;
        esac
    done
    
    local cmd="flutter run"
    if [ -n "$device" ]; then cmd="$cmd $device"; fi
    if [ -n "$flavor" ]; then cmd="$cmd $flavor"; fi
    if [ "$mode" != "debug" ]; then cmd="$cmd --$mode"; fi
    
    echo -e "${BLUE}Executing: $cmd${NC}"
    eval $cmd
}

# テスト実行
cmd_test() {
    echo -e "${BLUE}🧪 Running tests...${NC}"
    check_flutter_project
    
    local coverage=false
    local specific_test=""
    
    while [[ $# -gt 1 ]]; do
        shift
        case $1 in
            --coverage)
                coverage=true
                ;;
            --test)
                specific_test="$2"
                shift
                ;;
        esac
    done
    
    if [ "$coverage" = true ]; then
        flutter test --coverage
        if command -v genhtml &> /dev/null; then
            genhtml coverage/lcov.info -o coverage/html
            echo -e "${GREEN}✅ Coverage report generated in coverage/html/${NC}"
        fi
    elif [ -n "$specific_test" ]; then
        flutter test $specific_test
    else
        flutter test
    fi
}

# ビルド
cmd_build() {
    echo -e "${BLUE}🏗️  Building Flutter app...${NC}"
    check_flutter_project
    
    local platform="apk"
    local mode="debug"
    
    while [[ $# -gt 1 ]]; do
        shift
        case $1 in
            --platform)
                platform="$2"
                shift
                ;;
            --release)
                mode="release"
                ;;
            --ios)
                platform="ios"
                ;;
            --web)
                platform="web"
                ;;
            --macos)
                platform="macos"
                ;;
        esac
    done
    
    case $platform in
        apk)
            if [ "$mode" = "release" ]; then
                flutter build apk --release
            else
                flutter build apk --debug
            fi
            ;;
        ios)
            flutter build ios --$mode
            ;;
        web)
            flutter build web --$mode
            ;;
        macos)
            flutter build macos --$mode
            ;;
        *)
            echo -e "${RED}❌ Unknown platform: $platform${NC}"
            exit 1
            ;;
    esac
    
    echo -e "${GREEN}✅ Build complete${NC}"
}

# コード解析・フォーマット
cmd_analyze() {
    echo -e "${BLUE}🔍 Analyzing code...${NC}"
    check_flutter_project
    
    echo -e "${BLUE}Running dart analyze...${NC}"
    dart analyze
    
    echo -e "${BLUE}Formatting code...${NC}"
    dart format .
    
    # Import整理（もしimport_sorterがある場合）
    if grep -q "import_sorter" pubspec.yaml; then
        echo -e "${BLUE}Sorting imports...${NC}"
        flutter packages pub run import_sorter:main
    fi
    
    echo -e "${GREEN}✅ Code analysis complete${NC}"
}

# 依存関係管理
cmd_deps() {
    echo -e "${BLUE}📦 Managing dependencies...${NC}"
    check_flutter_project
    
    case $2 in
        update|upgrade)
            flutter pub upgrade
            ;;
        add)
            if [ -n "$3" ]; then
                flutter pub add $3
            else
                echo -e "${RED}❌ Package name required${NC}"
                echo "Usage: $0 deps add <package-name>"
            fi
            ;;
        remove)
            if [ -n "$3" ]; then
                flutter pub remove $3
            else
                echo -e "${RED}❌ Package name required${NC}"
                echo "Usage: $0 deps remove <package-name>"
            fi
            ;;
        outdated)
            flutter pub outdated
            ;;
        *)
            echo "Dependency management options:"
            echo "  update/upgrade  - Update all dependencies"
            echo "  add <package>   - Add a new dependency"
            echo "  remove <package> - Remove a dependency"
            echo "  outdated        - Show outdated dependencies"
            ;;
    esac
}

# WezTermワークスペース設定
cmd_workspace() {
    echo -e "${BLUE}🖥️  Setting up WezTerm workspace...${NC}"
    check_flutter_project
    
    # WezTermワークスペース設定ファイルを作成
    cat > .wezterm_workspace.lua << 'EOF'
-- Flutter プロジェクト専用 WezTerm ワークスペース設定
local wezterm = require 'wezterm'

return {
  default_prog = { 'bash', '-c', 'nvim .' },
  initial_cols = 120,
  initial_rows = 40,
  
  keys = {
    -- Flutter 専用ホットキー
    { key = 'r', mods = 'CMD|SHIFT', action = wezterm.action.SendString 'flutter run\r' },
    { key = 'h', mods = 'CMD|SHIFT', action = wezterm.action.SendString 'r' },
    { key = 'R', mods = 'CMD|SHIFT', action = wezterm.action.SendString 'R' },
    { key = 'q', mods = 'CMD|SHIFT', action = wezterm.action.SendString 'q' },
  }
}
EOF
    
    echo -e "${GREEN}✅ WezTerm workspace configuration created${NC}"
    echo "Start with: wezterm --config-file .wezterm_workspace.lua"
}

# Flutter Doctor と診断
cmd_doctor() {
    echo -e "${BLUE}👨‍⚕️ Running Flutter diagnostics...${NC}"
    
    echo -e "${PURPLE}=== Flutter Doctor ===${NC}"
    flutter doctor -v
    
    echo -e "${PURPLE}=== Project Dependencies ===${NC}"
    if [ -f "pubspec.yaml" ]; then
        flutter pub deps
    else
        echo "No pubspec.yaml found - not in a Flutter project"
    fi
    
    echo -e "${PURPLE}=== Available Devices ===${NC}"
    flutter devices
    
    echo -e "${PURPLE}=== Environment Variables ===${NC}"
    echo "FLUTTER_ROOT: $FLUTTER_ROOT"
    echo "ANDROID_HOME: $ANDROID_HOME"
    echo "JAVA_HOME: $JAVA_HOME"
    
    echo -e "${GREEN}✅ Diagnostics complete${NC}"
}

# メイン処理
main() {
    case $1 in
        setup)
            cmd_setup "$@"
            ;;
        clean)
            cmd_clean "$@"
            ;;
        devices)
            cmd_devices "$@"
            ;;
        emulators)
            cmd_emulators "$@"
            ;;
        run)
            cmd_run "$@"
            ;;
        test)
            cmd_test "$@"
            ;;
        build)
            cmd_build "$@"
            ;;
        analyze)
            cmd_analyze "$@"
            ;;
        deps)
            cmd_deps "$@"
            ;;
        workspace)
            cmd_workspace "$@"
            ;;
        doctor)
            cmd_doctor "$@"
            ;;
        -h|--help|help|"")
            show_usage
            ;;
        *)
            echo -e "${RED}❌ Unknown command: $1${NC}"
            echo ""
            show_usage
            exit 1
            ;;
    esac
}

main "$@"