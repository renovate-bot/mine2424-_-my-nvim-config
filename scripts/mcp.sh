#!/bin/bash

# MCP (Model Context Protocol) Setup for Claude Code
# ===============================================
# Adaptive installation with intelligent path detection
# Replaces both setup-mcp.sh and setup-mcp-adaptive.sh

set +e  # Don't exit on error for non-critical operations

echo "🤖 Setting up adaptive MCP configurations for Claude Code..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Claude settings directory
CLAUDE_DIR="$HOME/.claude"

# ===============================================
# Path Detection Functions
# ===============================================

# Function to detect npm global installation path
detect_npm_global_path() {
    local server_name="$1"
    local package_name="$2"
    
    # Check npm global bin directory
    if command -v npm &> /dev/null; then
        local npm_bin=$(npm bin -g 2>/dev/null)
        if [ -n "$npm_bin" ] && [ -f "$npm_bin/$server_name" ]; then
            echo "$npm_bin/$server_name"
            return 0
        fi
    fi
    
    # Check common npm global locations
    local common_paths=(
        "$HOME/.npm-global/bin/$server_name"
        "$HOME/.npm/bin/$server_name"
        "/usr/local/lib/node_modules/.bin/$server_name"
        "/opt/homebrew/lib/node_modules/.bin/$server_name"
    )
    
    for path in "${common_paths[@]}"; do
        if [ -f "$path" ]; then
            echo "$path"
            return 0
        fi
    done
    
    return 1
}

# Function to detect local npm installation
detect_npm_local_path() {
    local package_name="$1"
    
    # Check if package exists in local node_modules
    if [ -d "node_modules/$package_name" ]; then
        local bin_path="node_modules/.bin/$(basename $package_name)"
        if [ -f "$bin_path" ]; then
            echo "$(pwd)/$bin_path"
            return 0
        fi
    fi
    
    return 1
}

# Function to detect homebrew installation
detect_homebrew_path() {
    local formula_name="$1"
    
    if command -v brew &> /dev/null; then
        # Check if formula is installed
        if brew list "$formula_name" &>/dev/null; then
            local brew_prefix=$(brew --prefix)
            local bin_path="$brew_prefix/bin/$formula_name"
            if [ -f "$bin_path" ]; then
                echo "$bin_path"
                return 0
            fi
        fi
    fi
    
    return 1
}

# Function to find executable in PATH
find_in_path() {
    local executable="$1"
    command -v "$executable" 2>/dev/null
}

# Function to detect MCP server installation
detect_mcp_server() {
    local server_name="$1"
    local npm_package="$2"
    local homebrew_formula="$3"
    local env_var="$4"
    
    echo -e "${CYAN}Detecting $server_name installation...${NC}"
    
    # 1. Check environment variable override
    if [ -n "${!env_var}" ] && [ -f "${!env_var}" ]; then
        echo -e "${GREEN}  ✓ Found via environment variable: ${!env_var}${NC}"
        echo "${!env_var}"
        return 0
    fi
    
    # 2. Check if executable is in PATH
    local path_exec=$(find_in_path "$server_name")
    if [ -n "$path_exec" ]; then
        echo -e "${GREEN}  ✓ Found in PATH: $path_exec${NC}"
        echo "$path_exec"
        return 0
    fi
    
    # 3. Check npm global installation
    local npm_global=$(detect_npm_global_path "$server_name" "$npm_package")
    if [ -n "$npm_global" ]; then
        echo -e "${GREEN}  ✓ Found npm global installation: $npm_global${NC}"
        echo "$npm_global"
        return 0
    fi
    
    # 4. Check homebrew installation (if formula provided)
    if [ -n "$homebrew_formula" ]; then
        local brew_path=$(detect_homebrew_path "$homebrew_formula")
        if [ -n "$brew_path" ]; then
            echo -e "${GREEN}  ✓ Found homebrew installation: $brew_path${NC}"
            echo "$brew_path"
            return 0
        fi
    fi
    
    # 5. Check local npm installation
    local npm_local=$(detect_npm_local_path "$npm_package")
    if [ -n "$npm_local" ]; then
        echo -e "${GREEN}  ✓ Found local npm installation: $npm_local${NC}"
        echo "$npm_local"
        return 0
    fi
    
    # Not found - will use npx
    echo -e "${YELLOW}  ⚠️  Not found locally, will use npx for dynamic installation${NC}"
    echo "npx -y $npm_package"
    return 0
}

# ===============================================
# Server Configuration Functions
# ===============================================

# Function to check if server is already configured
is_server_configured() {
    local server_name="$1"
    claude mcp list 2>/dev/null | grep -q "^$server_name\s"
}

# Function to configure GitHub MCP server
configure_github_mcp() {
    if is_server_configured "github"; then
        echo -e "${GREEN}✓ GitHub MCP server already configured${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}Configuring GitHub MCP server...${NC}"
    
    # Detect installation
    local github_cmd=$(detect_mcp_server \
        "mcp-server-github" \
        "@modelcontextprotocol/server-github" \
        "" \
        "MCP_GITHUB_PATH")
    
    # Build environment variables
    local env_args=""
    if [ -n "$GITHUB_PERSONAL_ACCESS_TOKEN" ]; then
        env_args="$env_args -e GITHUB_PERSONAL_ACCESS_TOKEN=\"$GITHUB_PERSONAL_ACCESS_TOKEN\""
    fi
    if [ -n "$GITHUB_API_URL" ]; then
        env_args="$env_args -e GITHUB_API_URL=\"$GITHUB_API_URL\""
    fi
    
    # Add server
    if [ -n "$env_args" ]; then
        eval "claude mcp add github $env_args -- $github_cmd"
    else
        claude mcp add github -- $github_cmd
        echo -e "${YELLOW}Note: Set GITHUB_PERSONAL_ACCESS_TOKEN for full functionality${NC}"
    fi
}

# Function to configure Context7 MCP server
configure_context7_mcp() {
    if is_server_configured "context7"; then
        echo -e "${GREEN}✓ Context7 MCP server already configured${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}Configuring Context7 MCP server...${NC}"
    
    # Detect installation
    local context7_cmd=$(detect_mcp_server \
        "mcp-server-context7" \
        "@context7/mcp-server" \
        "" \
        "MCP_CONTEXT7_PATH")
    
    # Build environment variables
    local env_args=""
    if [ -n "$CONTEXT7_DATA_DIR" ]; then
        env_args="$env_args -e CONTEXT7_DATA_DIR=\"$CONTEXT7_DATA_DIR\""
    fi
    
    # Add server
    if [ -n "$env_args" ]; then
        eval "claude mcp add context7 $env_args -- $context7_cmd"
    else
        claude mcp add context7 -- $context7_cmd
    fi
}

# Function to configure Playwright MCP server
configure_playwright_mcp() {
    if is_server_configured "playwright"; then
        echo -e "${GREEN}✓ Playwright MCP server already configured${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}Configuring Playwright MCP server...${NC}"
    
    # Detect installation
    local playwright_cmd=$(detect_mcp_server \
        "mcp-server-playwright" \
        "@automatalabs/mcp-server-playwright" \
        "" \
        "MCP_PLAYWRIGHT_PATH")
    
    # Build environment variables
    local env_args=""
    if [ -n "$PLAYWRIGHT_BROWSERS_PATH" ]; then
        env_args="$env_args -e PLAYWRIGHT_BROWSERS_PATH=\"$PLAYWRIGHT_BROWSERS_PATH\""
    fi
    if [ -n "$PLAYWRIGHT_HEADLESS" ]; then
        env_args="$env_args -e PLAYWRIGHT_HEADLESS=\"$PLAYWRIGHT_HEADLESS\""
    fi
    
    # Add server
    if [ -n "$env_args" ]; then
        eval "claude mcp add playwright $env_args -- $playwright_cmd"
    else
        claude mcp add playwright -- $playwright_cmd
    fi
}

# Function to configure Debug Thinking MCP server
configure_debug_thinking_mcp() {
    if is_server_configured "debug-thinking"; then
        echo -e "${GREEN}✓ Debug Thinking MCP server already configured${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}Configuring Debug Thinking MCP server...${NC}"
    
    # Detect installation
    local debug_cmd=$(detect_mcp_server \
        "mcp-server-debug-thinking" \
        "mcp-server-debug-thinking" \
        "" \
        "MCP_DEBUG_THINKING_PATH")
    
    # Build environment variables
    local env_args=""
    if [ -n "$DEBUG_THINKING_LOG_LEVEL" ]; then
        env_args="$env_args -e DEBUG_THINKING_LOG_LEVEL=\"$DEBUG_THINKING_LOG_LEVEL\""
    fi
    if [ -n "$DEBUG_THINKING_DATA_DIR" ]; then
        env_args="$env_args -e DEBUG_THINKING_DATA_DIR=\"$DEBUG_THINKING_DATA_DIR\""
    fi
    
    # Add server
    if [ -n "$env_args" ]; then
        eval "claude mcp add debug-thinking $env_args -- $debug_cmd"
    else
        claude mcp add debug-thinking -- $debug_cmd
    fi
}

# ===============================================
# Validation Functions
# ===============================================

# Function to validate environment
validate_environment() {
    echo -e "${CYAN}Validating environment...${NC}"
    
    # Check Claude CLI
    if ! command -v claude &> /dev/null; then
        echo -e "${RED}❌ Error: Claude Code CLI is not installed${NC}"
        echo -e "${YELLOW}   Please install Claude Code first: https://claude.ai/code${NC}"
        return 1
    fi
    echo -e "${GREEN}  ✓ Claude Code CLI found${NC}"
    
    # Check npm (optional)
    if command -v npm &> /dev/null; then
        echo -e "${GREEN}  ✓ npm found ($(npm --version))${NC}"
    else
        echo -e "${YELLOW}  ⚠️  npm not found - MCP servers will be installed on demand${NC}"
    fi
    
    # Check GitHub token
    if [ -n "$GITHUB_PERSONAL_ACCESS_TOKEN" ]; then
        echo -e "${GREEN}  ✓ GitHub token configured${NC}"
    else
        echo -e "${YELLOW}  ⚠️  GitHub token not set - limited functionality${NC}"
    fi
    
    return 0
}

# Function to generate environment template
generate_env_template() {
    local template_file="$HOME/.mcp-env-template"
    
    echo -e "${CYAN}Generating environment template...${NC}"
    
    cat > "$template_file" << 'EOF'
# MCP Environment Configuration Template
# Copy this to ~/.zshrc.local or ~/.bashrc.local and customize

# ===== GitHub MCP Server =====
# export GITHUB_PERSONAL_ACCESS_TOKEN='your-github-token-here'
# export GITHUB_API_URL='https://api.github.com'  # For GitHub Enterprise
# export MCP_GITHUB_PATH='/custom/path/to/mcp-server-github'

# ===== Context7 MCP Server =====
# export CONTEXT7_DATA_DIR="$HOME/.context7/data"
# export MCP_CONTEXT7_PATH='/custom/path/to/mcp-server-context7'

# ===== Playwright MCP Server =====
# export PLAYWRIGHT_BROWSERS_PATH="$HOME/.cache/playwright"
# export PLAYWRIGHT_HEADLESS=true
# export MCP_PLAYWRIGHT_PATH='/custom/path/to/mcp-server-playwright'

# ===== Debug Thinking MCP Server =====
# export DEBUG_THINKING_LOG_LEVEL=info
# export DEBUG_THINKING_DATA_DIR="$HOME/.debug-thinking-mcp"
# export MCP_DEBUG_THINKING_PATH='/custom/path/to/mcp-server-debug-thinking'

# ===== Proxy Configuration =====
# export HTTP_PROXY="http://proxy.example.com:8080"
# export HTTPS_PROXY="http://proxy.example.com:8080"
# export NO_PROXY="localhost,127.0.0.1"
EOF
    
    echo -e "${GREEN}  ✓ Template saved to: $template_file${NC}"
}

# ===============================================
# Main Setup Process
# ===============================================

main() {
    echo -e "${GREEN}=== Adaptive MCP Setup for Claude Code ===${NC}"
    echo ""
    
    # Load local environment if exists
    if [ -f "$HOME/.zshrc.local" ]; then
        echo -e "${CYAN}Loading environment from ~/.zshrc.local...${NC}"
        source "$HOME/.zshrc.local"
    elif [ -f "$HOME/.bashrc.local" ]; then
        echo -e "${CYAN}Loading environment from ~/.bashrc.local...${NC}"
        source "$HOME/.bashrc.local"
    fi
    
    # Validate environment
    if ! validate_environment; then
        exit 1
    fi
    
    echo ""
    echo -e "${CYAN}Configuring MCP servers...${NC}"
    
    # Configure each server
    configure_github_mcp
    configure_context7_mcp
    configure_playwright_mcp
    configure_debug_thinking_mcp
    
    echo ""
    echo -e "${GREEN}=== MCP Setup Complete ===${NC}"
    
    # List configured servers
    echo ""
    echo -e "${CYAN}Configured MCP servers:${NC}"
    claude mcp list
    
    # Generate environment template
    generate_env_template
    
    echo ""
    echo -e "${GREEN}Next steps:${NC}"
    echo "1. Review the environment template: ~/.mcp-env-template"
    echo "2. Copy needed variables to ~/.zshrc.local or ~/.bashrc.local"
    echo "3. Set your GitHub token for full functionality:"
    echo "   export GITHUB_PERSONAL_ACCESS_TOKEN='your-token-here'"
    echo "4. Restart Claude Code to load the new configuration"
    
    echo ""
    echo -e "${GREEN}Happy coding with adaptive MCP! 🚀${NC}"
}

# Run main function
main "$@"