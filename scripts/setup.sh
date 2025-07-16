#!/bin/bash

# ===============================================
# Flutter Development Environment Setup Script
# ===============================================
# Unified setup script for Flutter + Neovim + Ghostty + Starship
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
MODE_PNPM_ONLY="pnpm-only"
MODE_MCP_ONLY="mcp-only"

# Default settings
INSTALL_STARSHIP=true
INSTALL_FLUTTER=true
INSTALL_PNPM=true
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
    🖥️  Ghostty terminal with modern configuration
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
  pnpm-only           Install and configure pnpm only
  mcp-only            Install and configure MCP servers only

OPTIONS:
  --no-starship       Skip Starship installation
  --no-flutter        Skip Flutter installation
  --no-pnpm           Skip pnpm installation
  --no-backup         Skip backing up existing configs
  --dry-run           Show what would be done without executing
  --help, -h          Show this help message

EXAMPLES:
  $0                          # Full setup with all components
  $0 quick                    # Quick setup (configs only)
  $0 config-only --no-backup # Copy configs without backup
  $0 starship-only            # Install Starship only
  $0 pnpm-only                # Install pnpm only
  $0 full --no-flutter        # Full setup without Flutter
  $0 mcp-only                 # Install MCP servers only

ENVIRONMENT VARIABLES FOR MCP:
  Before running setup, you can set these environment variables to customize MCP:
  
  GitHub MCP Server:
    GITHUB_PERSONAL_ACCESS_TOKEN  - Personal access token for GitHub API
    GITHUB_API_URL               - Custom GitHub API endpoint (for GitHub Enterprise)
    MCP_GITHUB_PATH              - Custom path to local GitHub MCP server
  
  Context7 MCP Server:
    CONTEXT7_DATA_DIR            - Custom context storage location
    MCP_CONTEXT7_PATH            - Custom path to local Context7 MCP server
  
  Playwright MCP Server:
    PLAYWRIGHT_BROWSERS_PATH     - Custom browser download location
    PLAYWRIGHT_HEADLESS          - Headless mode (true/false)
    MCP_PLAYWRIGHT_PATH          - Custom path to local Playwright MCP server
  
  Debug Thinking MCP Server:
    DEBUG_THINKING_LOG_LEVEL     - Log level (debug, info, warn, error)
    DEBUG_THINKING_DATA_DIR      - Custom debug data directory
    MCP_DEBUG_THINKING_PATH      - Custom path to local Debug Thinking MCP server

  These can be set in ~/.zshrc.local or ~/.bashrc.local for persistence.

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
        "sheldon"     # Plugin manager for zsh
        "eza"         # Modern replacement for ls
        "bat"         # Modern replacement for cat
        "dust"        # Modern replacement for du
        "duf"         # Modern replacement for df
        "procs"       # Modern replacement for ps
        "btop"        # Modern replacement for top
        "lazygit"     # Terminal UI for git
        "mise"        # Runtime version manager (formerly rtx)
        "direnv"      # Directory-based environment management
    )
    
    
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
            npm \
            cargo \       # For installing Rust-based tools
            direnv        # Directory-based environment management
            
        # Install Neovim (latest version)
        if ! command_exists nvim; then
            log_step "Installing Neovim (latest)..."
            curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
            sudo rm -rf /opt/nvim
            sudo tar -C /opt -xzf nvim-linux64.tar.gz
            sudo ln -sf /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim
            rm nvim-linux64.tar.gz
        fi
        
        # Install modern CLI tools via cargo
        log_step "Installing modern CLI tools..."
        cargo install eza bat dust duf procs btop
        
        # Install sheldon
        if ! command_exists sheldon; then
            log_step "Installing sheldon..."
            curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh | bash -s -- --repo rossmacarthur/sheldon --to ~/.local/bin
        fi
        
        # Install lazygit
        if ! command_exists lazygit; then
            log_step "Installing lazygit..."
            LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
            curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
            tar xf lazygit.tar.gz lazygit
            sudo install lazygit /usr/local/bin
            rm lazygit.tar.gz lazygit
        fi
        
        # Install mise
        if ! command_exists mise; then
            log_step "Installing mise..."
            curl https://mise.run | sh
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
        "$HOME/.config/ghostty"
        "$HOME/.config/sheldon"
        "$HOME/.local/bin"
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

install_ghostty_config() {
    log_step "Installing Ghostty configuration..."
    
    # Backup existing config
    if [[ "$BACKUP_EXISTING" == "true" ]]; then
        backup_file "$HOME/.config/ghostty/config"
    fi
    
    # Copy Ghostty config
    if [[ ! "$DRY_RUN" == "true" ]]; then
        mkdir -p "$HOME/.config/ghostty"
        cp "$PROJECT_ROOT/ghostty/config" "$HOME/.config/ghostty/config"
    fi
    
    log_success "Ghostty configuration installed"
}

install_claude_config() {
    log_step "Installing Claude Desktop configuration..."
    
    # Detect Claude config directory based on OS
    local claude_config_dir=""
    local os=$(detect_os)
    
    case "$os" in
        macOS)
            claude_config_dir="$HOME/Library/Application Support/Claude"
            ;;
        debian|linux)
            claude_config_dir="$HOME/.config/claude"
            ;;
        *)
            log_warning "Claude Desktop configuration not supported on $os"
            return 0
            ;;
    esac
    
    # Backup existing config
    if [[ "$BACKUP_EXISTING" == "true" ]] && [[ -f "$claude_config_dir/claude_desktop_config.json" ]]; then
        backup_file "$claude_config_dir/claude_desktop_config.json"
    fi
    
    # Copy Claude config
    if [[ ! "$DRY_RUN" == "true" ]]; then
        mkdir -p "$claude_config_dir"
        cp "$PROJECT_ROOT/claude/claude_desktop_config.json" "$claude_config_dir/claude_desktop_config.json"
    fi
    
    log_success "Claude Desktop configuration installed"
    
    # Install Claude safety configuration
    log_step "Installing Claude safety configuration..."
    
    # Backup existing Claude settings
    if [[ "$BACKUP_EXISTING" == "true" ]]; then
        backup_file "$HOME/.claude/settings.json"
    fi
    
    # Copy Claude safety configuration
    if [[ ! "$DRY_RUN" == "true" ]]; then
        mkdir -p "$HOME/.claude/scripts"
        cp "$PROJECT_ROOT/claude/settings.json" "$HOME/.claude/settings.json"
        cp "$PROJECT_ROOT/claude/scripts/deny-check.sh" "$HOME/.claude/scripts/deny-check.sh"
        chmod +x "$HOME/.claude/scripts/deny-check.sh"
    fi
    
    log_success "Claude safety configuration installed"
    
    # Install MCP (Model Context Protocol) configuration
    if [[ -f "$PROJECT_ROOT/scripts/setup-mcp.sh" ]]; then
        log_step "Installing MCP configuration..."
        
        # Load local environment configuration if exists
        if [[ -f "$HOME/.zshrc.local" ]]; then
            log_info "Loading local environment from ~/.zshrc.local"
            source "$HOME/.zshrc.local"
        elif [[ -f "$HOME/.bashrc.local" ]]; then
            log_info "Loading local environment from ~/.bashrc.local"
            source "$HOME/.bashrc.local"
        fi
        
        if [[ ! "$DRY_RUN" == "true" ]]; then
            "$PROJECT_ROOT/scripts/setup-mcp.sh"
        fi
        log_success "MCP configuration installed"
    fi
}

install_pnpm_config() {
    log_step "Installing pnpm configuration..."
    
    # Check if pnpm setup script exists
    if [[ -f "$PROJECT_ROOT/scripts/setup-pnpm.sh" ]]; then
        if [[ ! "$DRY_RUN" == "true" ]]; then
            "$PROJECT_ROOT/scripts/setup-pnpm.sh"
        fi
        log_success "pnpm installed and configured"
    else
        log_warning "pnpm setup script not found"
    fi
    
    # Copy pnpm configuration files
    if [[ ! "$DRY_RUN" == "true" ]]; then
        if [[ -f "$PROJECT_ROOT/.npmrc" ]]; then
            cp "$PROJECT_ROOT/.npmrc" "$HOME/.npmrc"
            log_success "pnpm configuration (.npmrc) installed"
        fi
    fi
}

install_mcp_only() {
    log_step "Installing MCP servers..."
    
    # Check for Claude CLI
    if ! command_exists claude; then
        log_warning "Claude Code CLI not found. Installing..."
        if [[ ! "$DRY_RUN" == "true" ]]; then
            npm install -g @anthropic-ai/claude-code
        fi
    fi
    
    # Run MCP setup script
    if [[ -f "$PROJECT_ROOT/scripts/setup-mcp.sh" ]]; then
        # Load local environment configuration if exists
        if [[ -f "$HOME/.zshrc.local" ]]; then
            log_info "Loading local environment from ~/.zshrc.local"
            source "$HOME/.zshrc.local"
        elif [[ -f "$HOME/.bashrc.local" ]]; then
            log_info "Loading local environment from ~/.bashrc.local"
            source "$HOME/.bashrc.local"
        fi
        
        if [[ ! "$DRY_RUN" == "true" ]]; then
            "$PROJECT_ROOT/scripts/setup-mcp.sh"
        fi
        log_success "MCP servers configured"
    else
        log_error "MCP setup script not found"
        return 1
    fi
}

install_zsh_config() {
    log_step "Installing Zsh configuration..."
    
    # Check if zsh is installed
    if ! command_exists zsh; then
        log_warning "Zsh is not installed. Please install zsh first."
        return 1
    fi
    
    # Backup existing zshrc
    if [[ "$BACKUP_EXISTING" == "true" ]]; then
        backup_file "$HOME/.zshrc"
        backup_file "$HOME/.config/sheldon"
    fi
    
    # Copy zsh configuration
    if [[ ! "$DRY_RUN" == "true" ]]; then
        # Install main zshrc
        cp "$PROJECT_ROOT/zsh/zshrc" "$HOME/.zshrc"
        
        # Install sheldon plugins configuration
        mkdir -p "$HOME/.config/sheldon"
        cp "$PROJECT_ROOT/zsh/sheldon/plugins.toml" "$HOME/.config/sheldon/plugins.toml"
        
        # Create local zshrc for user customizations
        if [[ ! -f "$HOME/.zshrc.local" ]]; then
            cat > "$HOME/.zshrc.local" << 'EOF'
# Local zsh customizations
# Add your personal configurations here

# ===== MCP Environment Variables =====
# Uncomment and configure as needed for your environment

# GitHub MCP Server
# export GITHUB_PERSONAL_ACCESS_TOKEN='your-github-token-here'
# export GITHUB_API_URL='https://api.github.com'  # For GitHub Enterprise

# Context7 MCP Server
# export CONTEXT7_DATA_DIR="$HOME/.context7/data"

# Playwright MCP Server
# export PLAYWRIGHT_BROWSERS_PATH="$HOME/.cache/playwright"
# export PLAYWRIGHT_HEADLESS=true

# Debug Thinking MCP Server
# export DEBUG_THINKING_LOG_LEVEL=info
# export DEBUG_THINKING_DATA_DIR="$HOME/.debug-thinking-mcp"

# Custom MCP Server Paths (if using local installations)
# export MCP_GITHUB_PATH="/path/to/local/github-mcp-server"
# export MCP_CONTEXT7_PATH="/path/to/local/context7-mcp-server"
# export MCP_PLAYWRIGHT_PATH="/path/to/local/playwright-mcp-server"
# export MCP_DEBUG_THINKING_PATH="/path/to/local/debug-thinking-mcp-server"

# Proxy Configuration (if behind corporate proxy)
# export HTTP_PROXY="http://proxy.example.com:8080"
# export HTTPS_PROXY="http://proxy.example.com:8080"
# export NO_PROXY="localhost,127.0.0.1"

# ===== Your Personal Customizations =====

EOF
            log_success "Created ~/.zshrc.local with MCP environment template"
        fi
    fi
    
    log_success "Zsh configuration installed"
    
    # Install sheldon if not already installed
    if ! command_exists sheldon; then
        log_step "Installing sheldon plugin manager..."
        if [[ ! "$DRY_RUN" == "true" ]]; then
            local os=$(detect_os)
            case "$os" in
                macOS)
                    brew install sheldon
                    ;;
                debian|linux)
                    curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh | bash -s -- --repo rossmacarthur/sheldon --to ~/.local/bin
                    ;;
            esac
        fi
    fi
    
    log_success "Zsh setup completed"
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
    
    # Check Ghostty config
    if [[ -f "$HOME/.config/ghostty/config" ]]; then
        log_success "Ghostty config: ✓"
    else
        log_error "Ghostty config not found"
        ((errors++))
    fi
    
    # Check Claude Desktop config
    local os=$(detect_os)
    local claude_config_path=""
    case "$os" in
        macOS)
            claude_config_path="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
            ;;
        debian|linux)
            claude_config_path="$HOME/.config/claude/claude_desktop_config.json"
            ;;
    esac
    
    if [[ -n "$claude_config_path" ]] && [[ -f "$claude_config_path" ]]; then
        log_success "Claude Desktop config: ✓"
    elif [[ -n "$claude_config_path" ]]; then
        log_error "Claude Desktop config not found"
        ((errors++))
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
    echo "• Modern Zsh configuration with plugins and aliases"
    if [[ "$INSTALL_STARSHIP" == "true" ]]; then
        echo "• Starship prompt with Flutter/Dart integration"
    fi
    echo "• Ghostty terminal configuration"
    echo "• Claude Desktop safety configuration"
    echo "• Claude Code safety features (command blocking)"
    echo "• Claude Code MCP servers (GitHub, context7, Playwright)"
    if [[ "$INSTALL_PNPM" == "true" ]]; then
        echo "• pnpm package manager with workspace support"
    fi
    echo "• Modern CLI tools (eza, bat, dust, etc.)"
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
            full|quick|config-only|starship-only|pnpm-only|mcp-only)
                mode="$1"
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
            --no-pnpm)
                INSTALL_PNPM=false
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
            install_zsh_config
            install_starship_config
            install_ghostty_config
            install_claude_config
            install_pnpm_config
            ;;
            
        "$MODE_QUICK")
            # Quick setup (dependencies assumed)
            setup_directories
            install_neovim_config
            install_zsh_config
            install_starship_config
            install_ghostty_config
            install_claude_config
            install_pnpm_config
            ;;
            
        "$MODE_CONFIG_ONLY")
            # Configuration files only
            setup_directories
            install_neovim_config
            install_ghostty_config
            install_claude_config
            ;;
            
        "$MODE_STARSHIP_ONLY")
            # Starship only
            install_starship_config
            ;;
            
        "$MODE_PNPM_ONLY")
            # pnpm only
            install_pnpm_config
            ;;
            
        "$MODE_MCP_ONLY")
            # MCP only
            install_mcp_only
            ;;
    esac
    
    # Verify installation
    if [[ "$mode" != "$MODE_STARSHIP_ONLY" ]] && [[ "$mode" != "$MODE_PNPM_ONLY" ]] && [[ "$mode" != "$MODE_MCP_ONLY" ]]; then
        verify_installation
    fi
    
    # Show completion message
    show_completion_message
}

# Run main function with all arguments
main "$@"