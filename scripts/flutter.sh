#!/bin/bash

# ===============================================
# Flutter Development Utilities
# ===============================================
# Consolidated Flutter development utilities
# Combines: flutter-utils.sh, create-flutter-project.sh

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# ===============================================
# Utility Functions
# ===============================================

log_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if current directory is a Flutter project
check_flutter_project() {
    if [ ! -f "pubspec.yaml" ]; then
        return 1
    fi
    return 0
}

# ===============================================
# Command: Create New Flutter Project
# ===============================================

create_project() {
    local project_name="$1"
    shift
    
    local org="com.example"
    local platforms=""
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --org)
                org="$2"
                shift 2
                ;;
            --ios)
                platforms="$platforms --platforms ios"
                shift
                ;;
            --android)
                platforms="$platforms --platforms android"
                shift
                ;;
            --web)
                platforms="$platforms --platforms web"
                shift
                ;;
            --macos)
                platforms="$platforms --platforms macos"
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                return 1
                ;;
        esac
    done
    
    # Create Flutter project
    log_info "Creating Flutter project: $project_name"
    if [ -z "$platforms" ]; then
        flutter create --org "$org" "$project_name"
    else
        flutter create --org "$org" $platforms "$project_name"
    fi
    
    cd "$project_name"
    
    # Create basic directory structure
    log_info "Setting up project structure..."
    mkdir -p lib/{models,services,screens,widgets,utils}
    mkdir -p test/{models,services,widgets}
    mkdir -p assets/{images,fonts}
    
    # Create .vscode directory with launch.json
    mkdir -p .vscode
    cat > .vscode/launch.json << 'EOF'
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter Debug",
      "request": "launch",
      "type": "dart",
      "flutterMode": "debug"
    },
    {
      "name": "Flutter Profile",
      "request": "launch",
      "type": "dart",
      "flutterMode": "profile"
    },
    {
      "name": "Flutter Release",
      "request": "launch",
      "type": "dart",
      "flutterMode": "release"
    }
  ]
}
EOF
    
    # Initial dependencies
    log_info "Installing dependencies..."
    flutter pub get
    
    # Open in Neovim
    log_success "Project created successfully!"
    log_info "Opening in Neovim..."
    nvim .
}

# ===============================================
# Command: Clean Project
# ===============================================

clean_project() {
    if ! check_flutter_project; then
        log_error "Not a Flutter project (pubspec.yaml not found)"
        return 1
    fi
    
    log_info "Cleaning Flutter project..."
    flutter clean
    flutter pub get
    log_success "Project cleaned"
}

# ===============================================
# Command: Run Tests
# ===============================================

run_tests() {
    if ! check_flutter_project; then
        log_error "Not a Flutter project (pubspec.yaml not found)"
        return 1
    fi
    
    log_info "Running tests with coverage..."
    flutter test --coverage
    
    if command -v lcov &> /dev/null; then
        log_info "Generating coverage report..."
        genhtml coverage/lcov.info -o coverage/html
        log_success "Coverage report generated at coverage/html/index.html"
    fi
}

# ===============================================
# Command: Analyze Code
# ===============================================

analyze_code() {
    if ! check_flutter_project; then
        log_error "Not a Flutter project (pubspec.yaml not found)"
        return 1
    fi
    
    log_info "Analyzing code..."
    flutter analyze
    
    log_info "Formatting code..."
    dart format .
    
    log_success "Code analysis complete"
}

# ===============================================
# Command: Build Project
# ===============================================

build_project() {
    if ! check_flutter_project; then
        log_error "Not a Flutter project (pubspec.yaml not found)"
        return 1
    fi
    
    local platform="${1:-apk}"
    local mode="${2:-release}"
    
    log_info "Building for $platform in $mode mode..."
    flutter build "$platform" "--$mode"
    
    log_success "Build complete"
}

# ===============================================
# Command: Setup Existing Project
# ===============================================

setup_project() {
    if ! check_flutter_project; then
        log_error "Not a Flutter project (pubspec.yaml not found)"
        return 1
    fi
    
    log_info "Setting up Flutter project..."
    
    # Get dependencies
    flutter pub get
    
    # Create .vscode directory if not exists
    if [ ! -d ".vscode" ]; then
        mkdir -p .vscode
        cat > .vscode/launch.json << 'EOF'
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter Debug",
      "request": "launch",
      "type": "dart",
      "flutterMode": "debug"
    },
    {
      "name": "Flutter Profile",
      "request": "launch",
      "type": "dart",
      "flutterMode": "profile"
    },
    {
      "name": "Flutter Release",
      "request": "launch",
      "type": "dart",
      "flutterMode": "release"
    }
  ]
}
EOF
        log_success "Created .vscode/launch.json"
    fi
    
    # Run doctor
    flutter doctor -v
    
    log_success "Project setup complete"
}

# ===============================================
# Help and Usage
# ===============================================

show_help() {
    cat << EOF
Flutter Development Utilities
============================

Usage: $0 <command> [options]

Commands:
  create <name>    Create new Flutter project
  setup            Setup existing Flutter project
  clean            Clean project (flutter clean + pub get)
  test             Run tests with coverage
  analyze          Analyze and format code
  build [platform] Build for production
  help             Show this help message

Create Options:
  --org <org>      Organization name (default: com.example)
  --ios            Enable iOS development
  --android        Enable Android development
  --web            Enable web development
  --macos          Enable macOS development

Build Options:
  Platform: apk, appbundle, ios, web, macos
  Mode: debug, profile, release

Examples:
  $0 create myapp --org com.company
  $0 setup
  $0 test
  $0 build apk release

EOF
}

# ===============================================
# Main Entry Point
# ===============================================

main() {
    local command="${1:-help}"
    shift || true
    
    case "$command" in
        create)
            if [ $# -eq 0 ]; then
                log_error "Project name required"
                show_help
                exit 1
            fi
            create_project "$@"
            ;;
        setup)
            setup_project
            ;;
        clean)
            clean_project
            ;;
        test)
            run_tests
            ;;
        analyze)
            analyze_code
            ;;
        build)
            build_project "$@"
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"