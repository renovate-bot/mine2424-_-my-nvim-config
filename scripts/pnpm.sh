#!/bin/bash

# ===============================================
# pnpm Package Manager Utilities
# ===============================================
# Consolidated pnpm utilities
# Combines: setup-pnpm.sh, migrate-to-pnpm.sh

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

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

command_exists() {
    command -v "$1" &> /dev/null
}

# ===============================================
# Command: Install pnpm
# ===============================================

install_pnpm() {
    if command_exists pnpm; then
        log_success "pnpm is already installed ($(pnpm --version))"
        return 0
    fi
    
    log_info "Installing pnpm..."
    
    # Try corepack first (recommended method)
    if command_exists corepack; then
        log_info "Using corepack to install pnpm..."
        corepack enable
        corepack prepare pnpm@latest --activate
    # Fall back to npm
    elif command_exists npm; then
        log_info "Using npm to install pnpm..."
        npm install -g pnpm
    # Fall back to curl
    else
        log_info "Using standalone installer..."
        curl -fsSL https://get.pnpm.io/install.sh | sh -
    fi
    
    # Verify installation
    if command_exists pnpm; then
        log_success "pnpm installed successfully ($(pnpm --version))"
    else
        log_error "Failed to install pnpm"
        return 1
    fi
}

# ===============================================
# Command: Setup pnpm Configuration
# ===============================================

setup_config() {
    log_info "Setting up pnpm configuration..."
    
    # Create .npmrc if it doesn't exist
    if [ ! -f "$HOME/.npmrc" ]; then
        cat > "$HOME/.npmrc" << 'EOF'
# pnpm configuration
auto-install-peers=true
strict-peer-dependencies=false
shamefully-hoist=true
prefer-workspace-packages=true
link-workspace-packages=true
shared-workspace-lockfile=true
save-workspace-protocol=rolling
resolution-mode=highest

# Performance optimizations
fetch-retries=2
fetch-retry-factor=2
fetch-retry-mintimeout=10000
fetch-retry-maxtimeout=60000

# Store configuration
store-dir=~/.pnpm-store
EOF
        log_success "Created ~/.npmrc with pnpm configuration"
    else
        log_info "~/.npmrc already exists, skipping"
    fi
    
    # Setup shell integration
    local shell_rc=""
    if [ -n "$ZSH_VERSION" ]; then
        shell_rc="$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ]; then
        shell_rc="$HOME/.bashrc"
    fi
    
    if [ -n "$shell_rc" ] && [ -f "$shell_rc" ]; then
        if ! grep -q "pnpm setup" "$shell_rc"; then
            echo "" >> "$shell_rc"
            echo "# pnpm" >> "$shell_rc"
            echo 'export PNPM_HOME="$HOME/.local/share/pnpm"' >> "$shell_rc"
            echo 'case ":$PATH:" in' >> "$shell_rc"
            echo '  *":$PNPM_HOME:"*) ;;' >> "$shell_rc"
            echo '  *) export PATH="$PNPM_HOME:$PATH" ;;' >> "$shell_rc"
            echo 'esac' >> "$shell_rc"
            echo "# pnpm end" >> "$shell_rc"
            log_success "Added pnpm to PATH in $shell_rc"
        fi
    fi
}

# ===============================================
# Command: Migrate from npm/yarn to pnpm
# ===============================================

migrate_project() {
    # Check if we're in a Node.js project
    if [ ! -f "package.json" ]; then
        log_error "No package.json found in current directory"
        return 1
    fi
    
    log_info "Migrating project to pnpm..."
    
    # Backup existing lock files
    if [ -f "package-lock.json" ]; then
        log_info "Backing up package-lock.json..."
        cp package-lock.json package-lock.json.backup
    fi
    
    if [ -f "yarn.lock" ]; then
        log_info "Backing up yarn.lock..."
        cp yarn.lock yarn.lock.backup
    fi
    
    # Import from existing lock file
    if [ -f "package-lock.json" ]; then
        log_info "Importing from package-lock.json..."
        pnpm import
    elif [ -f "yarn.lock" ]; then
        log_info "Importing from yarn.lock..."
        pnpm import
    else
        log_info "No existing lock file found, installing fresh..."
        pnpm install
    fi
    
    # Create pnpm-workspace.yaml if it's a monorepo
    if [ -d "packages" ] || [ -d "apps" ] || [ -d "libs" ]; then
        if [ ! -f "pnpm-workspace.yaml" ]; then
            log_info "Detected potential monorepo structure, creating pnpm-workspace.yaml..."
            cat > pnpm-workspace.yaml << 'EOF'
packages:
  # Include all packages in subdirs of packages/ and apps/
  - 'packages/*'
  - 'apps/*'
  - 'libs/*'
  # Include packages in subdirs of components/
  - 'components/*'
  # Include all packages in subdirs of examples/
  - 'examples/*'
EOF
            log_success "Created pnpm-workspace.yaml"
        fi
    fi
    
    # Update scripts in package.json
    log_info "Updating package.json scripts..."
    if command_exists jq; then
        # Update install commands
        jq '.scripts |= with_entries(
            if .value | test("npm install|yarn install") then
                .value |= gsub("npm install|yarn install"; "pnpm install")
            else . end
        )' package.json > package.json.tmp && mv package.json.tmp package.json
        
        # Update run commands
        jq '.scripts |= with_entries(
            if .value | test("npm run|yarn run") then
                .value |= gsub("npm run|yarn run"; "pnpm")
            else . end
        )' package.json > package.json.tmp && mv package.json.tmp package.json
    else
        log_warning "jq not installed, please manually update npm/yarn commands to pnpm in package.json"
    fi
    
    # Clean up old files
    log_info "Cleaning up old lock files..."
    rm -f package-lock.json yarn.lock
    
    # Remove node_modules and reinstall
    log_info "Removing node_modules and reinstalling with pnpm..."
    rm -rf node_modules
    pnpm install
    
    log_success "Migration to pnpm complete!"
    log_info "Old lock files have been backed up with .backup extension"
}

# ===============================================
# Command: Workspace Management
# ===============================================

workspace_info() {
    if [ ! -f "pnpm-workspace.yaml" ]; then
        log_error "Not a pnpm workspace (pnpm-workspace.yaml not found)"
        return 1
    fi
    
    log_info "Workspace information:"
    pnpm list --recursive --depth=-1
}

# ===============================================
# Help and Usage
# ===============================================

show_help() {
    cat << EOF
pnpm Package Manager Utilities
==============================

Usage: $0 <command> [options]

Commands:
  install          Install pnpm globally
  setup            Setup pnpm configuration
  migrate          Migrate npm/yarn project to pnpm
  workspace        Show workspace information
  help             Show this help message

Examples:
  $0 install       # Install pnpm
  $0 setup         # Configure pnpm
  $0 migrate       # Migrate current project to pnpm

Features:
  - Fast, disk space efficient package manager
  - Strict dependency resolution
  - Built-in monorepo support
  - Compatible with npm registry

EOF
}

# ===============================================
# Main Entry Point
# ===============================================

main() {
    local command="${1:-help}"
    
    case "$command" in
        install)
            install_pnpm
            ;;
        setup)
            setup_config
            ;;
        migrate)
            if ! command_exists pnpm; then
                log_error "pnpm is not installed. Run '$0 install' first"
                exit 1
            fi
            migrate_project
            ;;
        workspace)
            workspace_info
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