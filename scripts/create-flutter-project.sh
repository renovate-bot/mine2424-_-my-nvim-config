#!/bin/bash

# ===============================================
# Flutter開発環境セットアップスクリプト
# ===============================================

set -e

# カラー出力用の定数
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ロゴ表示
echo -e "${BLUE}"
echo "🎯 Flutter Development Environment Setup"
echo "========================================"
echo -e "${NC}"

# 引数チェック
if [ $# -eq 0 ]; then
    echo -e "${YELLOW}Usage: $0 <project-name> [options]${NC}"
    echo "Options:"
    echo "  --org <org>        Organization name (default: com.example)"
    echo "  --ios             Enable iOS development"
    echo "  --android         Enable Android development"
    echo "  --web             Enable web development"
    echo "  --macos           Enable macOS development"
    echo "  --existing        Setup existing project (don't create new)"
    exit 1
fi

PROJECT_NAME=$1
ORG="com.example"
PLATFORMS=""
EXISTING_PROJECT=false

# オプション解析
shift
while [[ $# -gt 0 ]]; do
    case $1 in
        --org)
            ORG="$2"
            shift 2
            ;;
        --ios)
            PLATFORMS="$PLATFORMS --platforms ios"
            shift
            ;;
        --android)
            PLATFORMS="$PLATFORMS --platforms android"
            shift
            ;;
        --web)
            PLATFORMS="$PLATFORMS --platforms web"
            shift
            ;;
        --macos)
            PLATFORMS="$PLATFORMS --platforms macos"
            shift
            ;;
        --existing)
            EXISTING_PROJECT=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# 必要なツールのチェック
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}❌ $1 is not installed${NC}"
        return 1
    else
        echo -e "${GREEN}✅ $1 is installed${NC}"
        return 0
    fi
}

echo -e "${BLUE}Checking required tools...${NC}"
ALL_GOOD=true

if ! check_command flutter; then ALL_GOOD=false; fi
if ! check_command dart; then ALL_GOOD=false; fi
if ! check_command nvim; then ALL_GOOD=false; fi
if ! check_command git; then ALL_GOOD=false; fi

if [ "$ALL_GOOD" = false ]; then
    echo -e "${RED}❌ Please install missing tools before continuing${NC}"
    exit 1
fi

# Flutter doctor実行
echo -e "${BLUE}Running Flutter doctor...${NC}"
flutter doctor

# プロジェクト作成または既存プロジェクトのセットアップ
if [ "$EXISTING_PROJECT" = false ]; then
    echo -e "${BLUE}Creating new Flutter project: $PROJECT_NAME${NC}"
    flutter create $PROJECT_NAME --org $ORG $PLATFORMS
    cd $PROJECT_NAME
else
    echo -e "${BLUE}Setting up existing Flutter project: $PROJECT_NAME${NC}"
    if [ ! -d "$PROJECT_NAME" ]; then
        echo -e "${RED}❌ Project directory $PROJECT_NAME does not exist${NC}"
        exit 1
    fi
    cd $PROJECT_NAME
fi

# pubspec.yamlが存在することを確認
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ pubspec.yaml not found. This doesn't appear to be a Flutter project.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Flutter project ready${NC}"

# 開発用依存関係の追加
echo -e "${BLUE}Adding development dependencies...${NC}"

# よく使われるFlutter開発用パッケージを追加
flutter pub add dev:flutter_lints
flutter pub add dev:build_runner
flutter pub add dev:json_annotation
flutter pub add dev:json_serializable

# 一般的なプロダクション用パッケージ（オプション）
echo -e "${YELLOW}Would you like to add common production packages? (y/n)${NC}"
read -r ADD_PACKAGES

if [[ $ADD_PACKAGES =~ ^[Yy]$ ]]; then
    flutter pub add http
    flutter pub add shared_preferences
    flutter pub add path_provider
    echo -e "${GREEN}✅ Common packages added${NC}"
fi

# Git初期化
if [ ! -d ".git" ]; then
    echo -e "${BLUE}Initializing Git repository...${NC}"
    git init
    git add .
    git commit -m "Initial commit: Flutter project setup"
    echo -e "${GREEN}✅ Git repository initialized${NC}"
fi

# 開発環境用設定ファイルの作成
echo -e "${BLUE}Creating development configuration files...${NC}"

# .vscode/settings.jsonの作成（Neovim互換性のため）
mkdir -p .vscode
cat > .vscode/settings.json << EOF
{
  "dart.flutterSdkPath": "/opt/homebrew/bin/flutter",
  "dart.lineLength": 120,
  "editor.rulers": [120],
  "editor.formatOnSave": true,
  "dart.debugExternalPackageLibraries": false,
  "dart.debugSdkLibraries": false
}
EOF

# analysis_options.yamlの作成/更新
cat > analysis_options.yaml << EOF
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_single_quotes: true
    avoid_print: false
    avoid_unnecessary_containers: true
    avoid_web_libraries_in_flutter: true
    cancel_subscriptions: true
    close_sinks: true
    comment_references: true
    one_member_abstracts: true
    only_throw_errors: true
    package_api_docs: true
    prefer_const_constructors: true
    prefer_const_declarations: true
    prefer_final_fields: true
    prefer_final_locals: true
    sort_constructors_first: true
    sort_unnamed_constructors_first: true
    unawaited_futures: true
    unnecessary_await_in_return: true
    unnecessary_lambdas: true
    unnecessary_null_aware_assignments: true
    unnecessary_parenthesis: true
    unnecessary_statements: true

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
  errors:
    invalid_annotation_target: ignore
EOF

# README.mdの作成
cat > README.md << EOF
# $PROJECT_NAME

A Flutter application optimized for WezTerm + Neovim development.

## Development Setup

This project is configured for development with:
- **Neovim** with flutter-tools.nvim
- **WezTerm** with Flutter-optimized workspace
- **Hot Reload** for rapid development

### Quick Start

1. Open project in WezTerm:
   \`\`\`bash
   cd $PROJECT_NAME
   wezterm
   \`\`\`

2. WezTerm will automatically detect this as a Flutter project and set up the workspace.

3. In Neovim, use these key mappings:
   - \`<Leader>Fr\` - Flutter run
   - \`<Leader>Fh\` - Hot reload
   - \`<Leader>FR\` - Hot restart
   - \`<Leader>Fq\` - Quit Flutter app

### Development Commands

| Command | Description |
|---------|-------------|
| \`flutter run\` | Start the app in debug mode |
| \`flutter test\` | Run unit tests |
| \`flutter build apk\` | Build APK for Android |
| \`dart analyze\` | Analyze code for issues |
| \`dart format .\` | Format all Dart files |

### Project Structure

\`\`\`
$PROJECT_NAME/
├── lib/                 # Main application code
│   ├── main.dart       # App entry point
│   ├── models/         # Data models
│   ├── screens/        # UI screens
│   ├── widgets/        # Reusable widgets
│   └── services/       # Business logic
├── test/               # Unit tests
├── integration_test/   # Integration tests
└── pubspec.yaml        # Dependencies
\`\`\`

## Getting Started

Run the following commands to get started:

\`\`\`bash
flutter pub get
flutter run
\`\`\`

For help getting started with Flutter, view the
[online documentation](https://flutter.dev/docs).
EOF

echo -e "${GREEN}✅ Configuration files created${NC}"

# 依存関係のインストール
echo -e "${BLUE}Installing dependencies...${NC}"
flutter pub get

# プロジェクト完了メッセージ
echo -e "${GREEN}"
echo "🎉 Flutter development environment setup complete!"
echo "=================================================="
echo ""
echo "Project: $PROJECT_NAME"
echo "Location: $(pwd)"
echo ""
echo "Next steps:"
echo "1. Open WezTerm in this directory"
echo "2. Start coding with 'nvim .'"
echo "3. Run your app with '<Leader>Fr' in Neovim"
echo ""
echo "Happy coding! 🚀"
echo -e "${NC}"