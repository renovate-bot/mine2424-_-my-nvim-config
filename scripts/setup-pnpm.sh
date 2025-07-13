#!/bin/bash

# pnpm setup script for macOS
# This script installs pnpm and sets up the workspace configuration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== pnpm Setup Script ===${NC}"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if pnpm is already installed
if command_exists pnpm; then
    echo -e "${GREEN}✓ pnpm is already installed${NC}"
    pnpm --version
else
    echo -e "${YELLOW}Installing pnpm...${NC}"
    
    # Install pnpm using npm (most reliable method)
    if command_exists npm; then
        npm install -g pnpm
    elif command_exists curl; then
        # Alternative: install using curl
        curl -fsSL https://get.pnpm.io/install.sh | sh -
        export PATH="$HOME/.local/share/pnpm:$PATH"
    else
        echo -e "${RED}Error: Neither npm nor curl is available for pnpm installation${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ pnpm installed successfully${NC}"
fi

# Verify installation
echo -e "${YELLOW}Verifying pnpm installation...${NC}"
pnpm --version

# Setup shell integration (for zsh)
if [ -f "$HOME/.zshrc" ]; then
    echo -e "${YELLOW}Setting up pnpm shell integration...${NC}"
    
    # Add pnpm to PATH if not already present
    if ! grep -q "pnpm" "$HOME/.zshrc"; then
        echo '# pnpm' >> "$HOME/.zshrc"
        echo 'export PNPM_HOME="$HOME/.local/share/pnpm"' >> "$HOME/.zshrc"
        echo 'case ":$PATH:" in' >> "$HOME/.zshrc"
        echo '  *":$PNPM_HOME:"*) ;;' >> "$HOME/.zshrc"
        echo '  *) export PATH="$PNPM_HOME:$PATH" ;;' >> "$HOME/.zshrc"
        echo 'esac' >> "$HOME/.zshrc"
        echo '# pnpm end' >> "$HOME/.zshrc"
        
        echo -e "${GREEN}✓ Added pnpm to ~/.zshrc${NC}"
        echo -e "${YELLOW}Please restart your terminal or run 'source ~/.zshrc'${NC}"
    fi
fi

# Create workspace directories if they don't exist
echo -e "${YELLOW}Creating workspace directories...${NC}"
mkdir -p packages apps tools examples

# Initialize basic package.json if it doesn't exist
if [ ! -f "package.json" ]; then
    echo -e "${YELLOW}Creating basic package.json...${NC}"
    cat > package.json << EOF
{
  "name": "my-nvim-config",
  "version": "1.0.0",
  "description": "Neovim configuration with pnpm workspace support",
  "private": true,
  "scripts": {
    "install": "pnpm install",
    "dev": "pnpm run dev --recursive",
    "build": "pnpm run build --recursive",
    "lint": "pnpm run lint --recursive",
    "clean": "pnpm run clean --recursive",
    "test": "pnpm run test --recursive"
  },
  "keywords": ["neovim", "configuration", "development"],
  "author": "",
  "license": "MIT",
  "engines": {
    "node": ">=16.0.0",
    "pnpm": ">=8.0.0"
  },
  "devDependencies": {},
  "dependencies": {}
}
EOF
    echo -e "${GREEN}✓ Created package.json${NC}"
fi

# Install dependencies if package.json exists
# if [ -f "package.json" ]; then
#     echo -e "${YELLOW}Installing dependencies...${NC}"
#     pnpm install
#     echo -e "${GREEN}✓ Dependencies installed${NC}"
# fi

# Setup pnpm aliases
echo -e "${YELLOW}Setting up pnpm aliases...${NC}"
cat > ~/.pnpm-aliases << 'EOF'
# pnpm aliases
alias pi="pnpm install"
alias pa="pnpm add"
alias pad="pnpm add --save-dev"
alias pr="pnpm run"
alias px="pnpm exec"
alias pu="pnpm update"
alias pls="pnpm list"
alias pw="pnpm workspace"
alias pwa="pnpm workspace add"
alias pwr="pnpm workspace run"
EOF

# Add alias source to zshrc if not already present
if [ -f "$HOME/.zshrc" ] && ! grep -q "pnpm-aliases" "$HOME/.zshrc"; then
    echo 'source ~/.pnpm-aliases' >> "$HOME/.zshrc"
    echo -e "${GREEN}✓ Added pnpm aliases to ~/.zshrc${NC}"
fi

echo -e "${GREEN}=== pnpm Setup Complete ===${NC}"
echo -e "${YELLOW}Available commands:${NC}"
echo "  pnpm install          - Install dependencies"
echo "  pnpm add <package>     - Add dependency"
echo "  pnpm workspace add     - Add workspace package"
echo "  pnpm run <script>      - Run script"
echo "  pnpm exec <command>    - Execute command"
echo ""
echo -e "${YELLOW}Workspace structure:${NC}"
echo "  packages/              - Shared packages"
echo "  apps/                  - Applications"
echo "  tools/                 - Development tools"
echo "  examples/              - Example projects"
echo ""
echo -e "${GREEN}Setup completed successfully!${NC}"