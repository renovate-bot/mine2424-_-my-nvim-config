#!/bin/bash

# MCP (Model Context Protocol) setup script for Claude Code
# This script installs MCP configurations for GitHub, context7, and Playwright

# Don't exit on error for non-critical operations
set +e

echo "🤖 Setting up MCP configurations for Claude Code..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Claude settings directory
CLAUDE_DIR="$HOME/.claude"
CLAUDE_SETTINGS_FILE="$CLAUDE_DIR/settings.json"

# Function to check if jq is installed
check_jq() {
    if ! command -v jq &> /dev/null; then
        echo -e "${YELLOW}jq is not installed. Installing...${NC}"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install jq
        else
            sudo apt-get update && sudo apt-get install -y jq
        fi
    fi
}

# Function to backup existing file
backup_file() {
    local file="$1"
    if [ -f "$file" ]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        echo -e "${YELLOW}Backing up existing $(basename "$file") to $(basename "$backup")${NC}"
        cp "$file" "$backup"
    fi
}

# Function to check if server is already configured
is_server_configured() {
    local server_name="$1"
    claude mcp list 2>/dev/null | grep -q "^$server_name\s"
}

# Function to add MCP servers using Claude CLI
add_mcp_servers() {
    echo -e "${GREEN}Adding MCP servers to Claude Code...${NC}"
    
    # Check if claude command exists
    if ! command -v claude &> /dev/null; then
        echo -e "${RED}Error: Claude Code CLI is not installed${NC}"
        echo -e "${YELLOW}Please install Claude Code first: https://claude.ai/code${NC}"
        return 1
    fi
    
    # Add GitHub MCP server
    if is_server_configured "github"; then
        echo -e "${GREEN}✓ GitHub MCP server already configured${NC}"
    else
        echo -e "${YELLOW}Adding GitHub MCP server...${NC}"
        if [ -n "$GITHUB_PERSONAL_ACCESS_TOKEN" ]; then
            claude mcp add github -e GITHUB_PERSONAL_ACCESS_TOKEN="$GITHUB_PERSONAL_ACCESS_TOKEN" -- npx -y @modelcontextprotocol/server-github
        else
            claude mcp add github -- npx -y @modelcontextprotocol/server-github
            echo -e "${YELLOW}Note: GitHub MCP server added without token. Set GITHUB_PERSONAL_ACCESS_TOKEN to enable full functionality.${NC}"
        fi
    fi
    
    # Add Context7 MCP server
    if is_server_configured "context7"; then
        echo -e "${GREEN}✓ Context7 MCP server already configured${NC}"
    else
        echo -e "${YELLOW}Adding Context7 MCP server...${NC}"
        claude mcp add context7 -- npx -y @context7/mcp-server
    fi
    
    # Add Playwright MCP server
    if is_server_configured "playwright"; then
        echo -e "${GREEN}✓ Playwright MCP server already configured${NC}"
    else
        echo -e "${YELLOW}Adding Playwright MCP server...${NC}"
        claude mcp add playwright -- npx -y @automatalabs/mcp-server-playwright
    fi
    
    # Add Debug Thinking MCP server
    if is_server_configured "debug-thinking"; then
        echo -e "${GREEN}✓ Debug Thinking MCP server already configured${NC}"
    else
        echo -e "${YELLOW}Adding Debug Thinking MCP server...${NC}"
        claude mcp add debug-thinking -- npx -y mcp-server-debug-thinking
    fi
    
    echo -e "${GREEN}✓ All MCP servers have been configured${NC}"
    
    # List configured servers
    echo -e "${GREEN}Configured MCP servers:${NC}"
    claude mcp list
}

# Function to validate GitHub token
validate_github_token() {
    if [ -z "$GITHUB_PERSONAL_ACCESS_TOKEN" ]; then
        echo -e "${YELLOW}⚠️  Warning: GITHUB_PERSONAL_ACCESS_TOKEN is not set${NC}"
        echo -e "${YELLOW}   The GitHub MCP server requires a personal access token to function${NC}"
        echo -e "${YELLOW}   Please set it in your shell configuration:${NC}"
        echo -e "${YELLOW}   export GITHUB_PERSONAL_ACCESS_TOKEN='your-token-here'${NC}"
        echo ""
        echo -e "${YELLOW}   You can create a token at: https://github.com/settings/tokens${NC}"
        echo -e "${YELLOW}   Required scopes: repo, read:org, read:user${NC}"
    else
        echo -e "${GREEN}✓ GitHub personal access token is configured${NC}"
    fi
}

# Function to test MCP server availability (non-blocking)
test_mcp_servers() {
    echo -e "${GREEN}Testing MCP server availability (optional)...${NC}"
    
    # Check if npm is installed
    if ! command -v npm &> /dev/null; then
        echo -e "${YELLOW}⚠️  npm is not installed. Skipping MCP server tests.${NC}"
        echo -e "${YELLOW}   MCP servers will be downloaded when Claude Code first uses them.${NC}"
        return 0
    fi
    
    # Create a temporary directory for testing MCP servers
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Test each MCP server with timeout
    echo -e "${YELLOW}Note: This is just a connectivity test. MCP servers will be installed automatically by Claude Code.${NC}"
    
    # GitHub MCP server
    echo -n "  GitHub MCP server: "
    if timeout 10s npx -y @modelcontextprotocol/server-github --help &> /dev/null; then
        echo -e "${GREEN}✓ Available${NC}"
    else
        echo -e "${YELLOW}⚠️  Not tested (will be installed on first use)${NC}"
    fi
    
    # Context7 MCP server
    echo -n "  Context7 MCP server: "
    if timeout 10s npx -y @context7/mcp-server --help &> /dev/null; then
        echo -e "${GREEN}✓ Available${NC}"
    else
        echo -e "${YELLOW}⚠️  Not tested (will be installed on first use)${NC}"
    fi
    
    # Playwright MCP server
    echo -n "  Playwright MCP server: "
    if timeout 10s npx -y @automatalabs/mcp-server-playwright --help &> /dev/null; then
        echo -e "${GREEN}✓ Available${NC}"
    else
        echo -e "${YELLOW}⚠️  Not tested (will be installed on first use)${NC}"
    fi
    
    # Clean up
    cd - > /dev/null
    rm -rf "$temp_dir"
    
    echo -e "${GREEN}✓ MCP configuration has been installed successfully${NC}"
}

# Function to create environment template
create_env_template() {
    local env_template="$PROJECT_ROOT/.env.mcp.template"
    cat > "$env_template" << 'EOF'
# MCP Environment Variables Template
# Copy this file to .env.mcp and fill in your values

# GitHub Personal Access Token
# Required for GitHub MCP server
# Create at: https://github.com/settings/tokens
# Required scopes: repo, read:org, read:user
GITHUB_PERSONAL_ACCESS_TOKEN=your-github-token-here

# Additional MCP server environment variables can be added here
EOF
    
    echo -e "${GREEN}✓ Created environment template at .env.mcp.template${NC}"
    
    # Create .gitignore entry if not exists
    if ! grep -q "^.env.mcp$" "$PROJECT_ROOT/.gitignore" 2>/dev/null; then
        echo ".env.mcp" >> "$PROJECT_ROOT/.gitignore"
        echo -e "${GREEN}✓ Added .env.mcp to .gitignore${NC}"
    fi
}

# Main setup process
main() {
    echo -e "${GREEN}=== MCP Setup for Claude Code ===${NC}"
    echo ""
    
    # Check dependencies
    check_jq
    
    # Add MCP servers using Claude CLI
    add_mcp_servers
    
    # Validate GitHub token
    validate_github_token
    
    # Create environment template
    create_env_template
    
    echo ""
    echo -e "${GREEN}=== MCP Setup Complete ===${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Set your GitHub personal access token:"
    echo "   export GITHUB_PERSONAL_ACCESS_TOKEN='your-token-here'"
    echo ""
    echo "2. Restart Claude Code to load the new MCP servers"
    echo ""
    echo "3. The following MCP servers are now configured:"
    echo "   - GitHub: Repository operations, issues, PRs"
    echo "   - Context7: Enhanced context management"
    echo "   - Playwright: Web automation and testing"
    echo "   - Debug Thinking: Enhanced debugging and thought process visualization"
    echo ""
    echo -e "${GREEN}Happy coding with MCP! 🚀${NC}"
}

# Run main function
main