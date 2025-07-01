#!/bin/bash

# ===============================================
# Flutter Development Environment Setup Script
# ===============================================
# Unified setup script for Flutter + Neovim + WezTerm + Starship
# Supports: macOS, Linux (Ubuntu/Debian)

set -e  # Exit on error

# ===============================================
# Configuration and Constants
# ===============================================
SCRIPT_VERSION="2.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Setup modes
MODE_FULL="full"
MODE_QUICK="quick"
MODE_CONFIG_ONLY="config-only"
MODE_STARSHIP_ONLY="starship-only"

# Default settings
INSTALL_WEZTERM=true
INSTALL_STARSHIP=true
INSTALL_FLUTTER=true
BACKUP_EXISTING=true
DRY_RUN=false

# ===============================================
# Utility Functions
# ===============================================

# Logging functions
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

log_step() {
    echo -e "${BLUE}🔄 $1${NC}"
}

# OS Detection
detect_os() {
    case "$(uname -s)" in
        Darwin*)    echo "macOS" ;;
        Linux*)     
            if [[ -f /etc/debian_version ]]; then
                echo "debian"
            elif [[ -f /etc/redhat-release ]]; then
                echo "redhat"
            else
                echo "linux"
            fi
            ;;
        CYGWIN*|MINGW*|MSYS*) echo "windows" ;;
        *)          echo "unknown" ;;
    esac
}

# Package manager detection
detect_package_manager() {
    local os="$1"
    case "$os" in
        macOS)
            if command -v brew &> /dev/null; then
                echo "brew"
            else
                echo "none"
            fi
            ;;
        debian)
            echo "apt"
            ;;
        redhat)
            echo "yum"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Backup existing file/directory
backup_file() {
    local file="$1"
    if [[ -e "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        log_step "Backing up $file to $backup"
        if [[ ! "$DRY_RUN" == "true" ]]; then
            mv "$file" "$backup"
        fi
        log_success "Backup created: $backup"
    fi
}

# ===============================================
# Display Functions
# ===============================================

show_banner() {
    echo -e "${BLUE}${BOLD}"
    cat << 'EOF'
    🚀 Flutter Development Environment Setup
    =========================================
    
    Complete setup for modern Flutter development:
    ✨ Neovim with LSP + Copilot + Flutter-tools
    🖥️  WezTerm with transparency and Zenn-style tabs
    ⭐ Starship prompt with Flutter/Dart integration
    🔧 All configs and key bindings optimized
    
EOF
    echo -e "${NC}"
    echo -e "${CYAN}Version: $SCRIPT_VERSION${NC}"
    echo -e "${CYAN}Project: $(basename "$PROJECT_ROOT")${NC}"
    echo ""
}

show_help() {
    cat << EOF
Usage: $0 [MODE] [OPTIONS]

MODES:
  full                Complete setup (default)
  quick               Config files only (assumes dependencies installed)
  config-only         Only copy configuration files
  starship-only       Install and configure Starship only

OPTIONS:
  --no-wezterm        Skip WezTerm installation and configuration
  --no-starship       Skip Starship installation
  --no-flutter        Skip Flutter installation
  --no-backup         Skip backing up existing configs
  --dry-run           Show what would be done without executing
  --help, -h          Show this help message

EXAMPLES:
  $0                          # Full setup with all components
  $0 quick                    # Quick setup (configs only)
  $0 config-only --no-backup # Copy configs without backup
  $0 starship-only            # Install Starship only
  $0 full --no-wezterm        # Full setup without WezTerm

EOF
}

# ===============================================
# Installation Functions
# ===============================================

install_homebrew() {
    if ! command_exists brew; then
        log_step "Installing Homebrew..."
        if [[ ! "$DRY_RUN" == "true" ]]; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        log_success "Homebrew installed"
    else
        log_success "Homebrew already installed"
    fi
}

install_packages_macos() {
    log_step "Installing packages via Homebrew..."
    
    local packages=(
        "neovim"
        "git"
        "ripgrep"
        "fd"
        "fzf"
        "node"
        "tmux"
    )
    
    if [[ "$INSTALL_WEZTERM" == "true" ]]; then
        packages+=("--cask wezterm")
    fi
    
    if [[ "$INSTALL_FLUTTER" == "true" ]]; then
        packages+=("--cask flutter")
    fi
    
    if [[ ! "$DRY_RUN" == "true" ]]; then
        brew update
        for package in "${packages[@]}"; do
            if [[ "$package" == "--cask"* ]]; then
                brew install $package || log_warning "Failed to install $package"
            else
                brew install "$package" || log_warning "Failed to install $package"
            fi
        done
    fi
    
    log_success "Package installation completed"
}

install_packages_debian() {
    log_step "Installing packages via apt..."
    
    if [[ ! "$DRY_RUN" == "true" ]]; then
        sudo apt update
        sudo apt install -y \
            curl \
            git \
            build-essential \
            ripgrep \
            fd-find \
            fzf \
            tmux \
            nodejs \
            npm
            
        # Install Neovim (latest version)
        if ! command_exists nvim; then
            log_step "Installing Neovim (latest)..."
            curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
            sudo rm -rf /opt/nvim
            sudo tar -C /opt -xzf nvim-linux64.tar.gz
            sudo ln -sf /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim
            rm nvim-linux64.tar.gz
        fi
    fi
    
    log_success "Package installation completed"
}

install_starship() {
    if command_exists starship; then
        log_success "Starship already installed ($(starship --version))"
        return 0
    fi
    
    log_step "Installing Starship..."
    if [[ ! "$DRY_RUN" == "true" ]]; then
        curl -sS https://starship.rs/install.sh | sh -s -- --yes
    fi
    log_success "Starship installed"
}

# ===============================================
# Configuration Functions
# ===============================================

setup_directories() {
    log_step "Setting up configuration directories..."
    
    local dirs=(
        "$HOME/.config/nvim"
        "$HOME/.config/nvim/lua"
    )
    
    for dir in "${dirs[@]}"; do
        if [[ ! "$DRY_RUN" == "true" ]]; then
            mkdir -p "$dir"
        fi
    done
    
    log_success "Directories created"
}

install_neovim_config() {
    log_step "Installing Neovim configuration..."
    
    # Backup existing config
    if [[ "$BACKUP_EXISTING" == "true" ]]; then
        backup_file "$HOME/.config/nvim"
    fi
    
    # Copy configuration files
    if [[ ! "$DRY_RUN" == "true" ]]; then
        mkdir -p "$HOME/.config/nvim/lua"
        cp "$PROJECT_ROOT/init.lua" "$HOME/.config/nvim/"
        cp -r "$PROJECT_ROOT/lua/"* "$HOME/.config/nvim/lua/"
        chmod +x "$PROJECT_ROOT/scripts/"*.sh
    fi
    
    log_success "Neovim configuration installed"
}

install_wezterm_config() {
    if [[ "$INSTALL_WEZTERM" != "true" ]]; then
        log_info "Skipping WezTerm configuration"
        return 0
    fi
    
    log_step "Installing WezTerm configuration..."
    
    # Backup existing config
    if [[ "$BACKUP_EXISTING" == "true" ]]; then
        backup_file "$HOME/.wezterm.lua"
    fi
    
    # Copy WezTerm config
    if [[ ! "$DRY_RUN" == "true" ]]; then
        cp "$PROJECT_ROOT/wezterm.lua" "$HOME/.wezterm.lua"
    fi
    
    log_success "WezTerm configuration installed"
}

install_starship_config() {
    if [[ "$INSTALL_STARSHIP" != "true" ]]; then
        log_info "Skipping Starship configuration"
        return 0
    fi
    
    log_step "Installing Starship configuration..."
    
    # Install Starship if not installed
    install_starship
    
    # Backup existing config
    if [[ "$BACKUP_EXISTING" == "true" ]]; then
        backup_file "$HOME/.config/starship.toml"
    fi
    
    # Copy Starship config
    if [[ ! "$DRY_RUN" == "true" ]]; then
        mkdir -p "$HOME/.config"
        cp "$PROJECT_ROOT/starship.toml" "$HOME/.config/starship.toml"
    fi
    
    # Configure shell integration
    configure_starship_shell
    
    log_success "Starship configuration installed"
}

configure_starship_shell() {
    local shell_name=$(basename "$SHELL")
    local shell_rc=""
    local init_command=""
    
    case "$shell_name" in
        zsh)
            shell_rc="$HOME/.zshrc"
            init_command='eval "$(starship init zsh)"'
            ;;
        bash)
            shell_rc="$HOME/.bashrc"
            init_command='eval "$(starship init bash)"'
            ;;
        fish)
            shell_rc="$HOME/.config/fish/config.fish"
            init_command='starship init fish | source'
            ;;
        *)
            log_warning "Unsupported shell: $shell_name"
            return 1
            ;;
    esac
    
    # Check if already configured
    if [[ -f "$shell_rc" ]] && grep -q "starship init" "$shell_rc"; then
        log_success "Shell already configured for Starship"
        return 0
    fi
    
    # Add initialization to shell config
    if [[ ! "$DRY_RUN" == "true" ]]; then
        echo "" >> "$shell_rc"
        echo "# Starship prompt initialization" >> "$shell_rc"
        echo "$init_command" >> "$shell_rc"
    fi
    
    log_success "Added Starship initialization to $shell_rc"
}

# ===============================================
# Verification Functions
# ===============================================

verify_installation() {
    log_step "Verifying installation..."
    
    local errors=0
    
    # Check Neovim
    if command_exists nvim; then
        log_success "Neovim: $(nvim --version | head -n1)"
    else
        log_error "Neovim not found"
        ((errors++))
    fi
    
    # Check configuration files
    if [[ -f "$HOME/.config/nvim/init.lua" ]]; then
        log_success "Neovim config: ✓"
    else
        log_error "Neovim config not found"
        ((errors++))
    fi
    
    # Check WezTerm (if enabled)
    if [[ "$INSTALL_WEZTERM" == "true" ]]; then
        if [[ -f "$HOME/.wezterm.lua" ]]; then
            log_success "WezTerm config: ✓"
        else
            log_error "WezTerm config not found"
            ((errors++))
        fi
    fi
    
    # Check Starship (if enabled)
    if [[ "$INSTALL_STARSHIP" == "true" ]]; then
        if command_exists starship; then
            log_success "Starship: $(starship --version)"
        else
            log_error "Starship not found"
            ((errors++))
        fi
        
        if [[ -f "$HOME/.config/starship.toml" ]]; then
            log_success "Starship config: ✓"
        else
            log_error "Starship config not found"
            ((errors++))
        fi
    fi
    
    if [[ $errors -eq 0 ]]; then
        log_success "All components verified successfully!"
        return 0
    else
        log_error "Verification failed with $errors errors"
        return 1
    fi
}

show_completion_message() {
    echo ""
    echo -e "${GREEN}${BOLD}🎉 Setup completed successfully!${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Restart your terminal or run: source ~/.$(basename $SHELL)rc"
    echo "2. Open Neovim and let plugins install automatically"
    echo "3. For Flutter development, run: flutter doctor"
    if [[ "$INSTALL_STARSHIP" == "true" ]]; then
        echo "4. Test Starship prompt in a Git repository"
    fi
    echo ""
    echo -e "${CYAN}Key features installed:${NC}"
    echo "• Neovim with LSP, Copilot, and Flutter tools"
    if [[ "$INSTALL_WEZTERM" == "true" ]]; then
        echo "• WezTerm with transparency and Zenn-style tabs"
    fi
    if [[ "$INSTALL_STARSHIP" == "true" ]]; then
        echo "• Starship prompt with Flutter/Dart integration"
    fi
    echo "• Optimized key bindings and development workflow"
    echo ""
    echo -e "${PURPLE}Documentation: Check SETUP_GUIDE.md and FLUTTER_KEYBINDINGS.md${NC}"
}

# ===============================================
# Main Setup Logic
# ===============================================

main() {
    show_banner
    
    # Parse arguments
    local mode="$MODE_FULL"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            full|quick|config-only|starship-only)
                mode="$1"
                shift
                ;;
            --no-wezterm)
                INSTALL_WEZTERM=false
                shift
                ;;
            --no-starship)
                INSTALL_STARSHIP=false
                shift
                ;;
            --no-flutter)
                INSTALL_FLUTTER=false
                shift
                ;;
            --no-backup)
                BACKUP_EXISTING=false
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Show dry run warning
    if [[ "$DRY_RUN" == "true" ]]; then
        log_warning "DRY RUN MODE - No changes will be made"
        echo ""
    fi
    
    # Detect OS and package manager
    local os=$(detect_os)
    local pkg_mgr=$(detect_package_manager "$os")
    
    log_info "Detected OS: $os"
    log_info "Package Manager: $pkg_mgr"
    log_info "Setup Mode: $mode"
    echo ""
    
    # Confirm before proceeding
    if [[ "$DRY_RUN" != "true" ]]; then
        echo -e "${YELLOW}This will modify your system and configuration files.${NC}"
        read -p "Continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Setup cancelled by user"
            exit 0
        fi
        echo ""
    fi
    
    # Execute setup based on mode
    case "$mode" in
        "$MODE_FULL")
            # Full installation
            case "$os" in
                macOS)
                    install_homebrew
                    install_packages_macos
                    ;;
                debian)
                    install_packages_debian
                    ;;
                *)
                    log_error "Unsupported OS for full installation: $os"
                    exit 1
                    ;;
            esac
            
            setup_directories
            install_neovim_config
            install_wezterm_config
            install_starship_config
            ;;
            
        "$MODE_QUICK")
            # Quick setup (dependencies assumed)
            setup_directories
            install_neovim_config
            install_wezterm_config
            install_starship_config
            ;;
            
        "$MODE_CONFIG_ONLY")
            # Configuration files only
            setup_directories
            install_neovim_config
            if [[ "$INSTALL_WEZTERM" == "true" ]]; then
                install_wezterm_config
            fi
            ;;
            
        "$MODE_STARSHIP_ONLY")
            # Starship only
            install_starship_config
            ;;
    esac
    
    # Verify installation
    if [[ "$mode" != "$MODE_STARSHIP_ONLY" ]]; then
        verify_installation
    fi
    
    # Show completion message
    show_completion_message
}

# Run main function with all arguments
main "$@"