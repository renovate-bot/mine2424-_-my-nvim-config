#!/bin/bash

# Migration script from npm/yarn to pnpm
# This script helps migrate existing projects to pnpm

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== NPM/Yarn to pnpm Migration Script ===${NC}"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to backup file
backup_file() {
    local file="$1"
    if [ -f "$file" ]; then
        cp "$file" "$file.backup"
        echo -e "${YELLOW}✓ Backed up $file to $file.backup${NC}"
    fi
}

# Function to remove file with confirmation
remove_file() {
    local file="$1"
    if [ -f "$file" ]; then
        read -p "Remove $file? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm "$file"
            echo -e "${GREEN}✓ Removed $file${NC}"
        fi
    fi
}

# Check if pnpm is installed
if ! command_exists pnpm; then
    echo -e "${RED}Error: pnpm is not installed${NC}"
    echo "Please run ./scripts/setup-pnpm.sh first"
    exit 1
fi

# Check current directory for package.json
if [ ! -f "package.json" ]; then
    echo -e "${RED}Error: No package.json found in current directory${NC}"
    exit 1
fi

echo -e "${BLUE}Current directory: $(pwd)${NC}"
echo -e "${BLUE}Project: $(grep -o '"name": "[^"]*"' package.json | cut -d'"' -f4)${NC}"
echo

# Backup package.json and lock files
echo -e "${YELLOW}Creating backups...${NC}"
backup_file "package.json"
backup_file "package-lock.json"
backup_file "yarn.lock"

# Remove existing lock files and node_modules
echo -e "${YELLOW}Cleaning existing dependencies...${NC}"

if [ -d "node_modules" ]; then
    read -p "Remove node_modules directory? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf node_modules
        echo -e "${GREEN}✓ Removed node_modules${NC}"
    fi
fi

# Handle lock files
if [ -f "package-lock.json" ]; then
    remove_file "package-lock.json"
fi

if [ -f "yarn.lock" ]; then
    remove_file "yarn.lock"
fi

# Convert npm/yarn scripts to pnpm equivalents
echo -e "${YELLOW}Converting package.json scripts...${NC}"

# Create a temporary script to update package.json
cat > /tmp/update_package_json.js << 'EOF'
const fs = require('fs');
const packageJson = JSON.parse(fs.readFileSync('package.json', 'utf8'));

// Update scripts that use npm/yarn to use pnpm
if (packageJson.scripts) {
    for (const [key, value] of Object.entries(packageJson.scripts)) {
        if (typeof value === 'string') {
            // Replace npm run with pnpm run
            packageJson.scripts[key] = value
                .replace(/\bnpm run\b/g, 'pnpm run')
                .replace(/\byarn\b/g, 'pnpm')
                .replace(/\bnpm\b/g, 'pnpm');
        }
    }
}

// Add pnpm engine requirement
if (!packageJson.engines) {
    packageJson.engines = {};
}
if (!packageJson.engines.pnpm) {
    packageJson.engines.pnpm = '>=8.0.0';
}

// Add packageManager field
packageJson.packageManager = 'pnpm@latest';

fs.writeFileSync('package.json', JSON.stringify(packageJson, null, 2));
console.log('Updated package.json');
EOF

node /tmp/update_package_json.js
rm /tmp/update_package_json.js

# Import dependencies using pnpm
echo -e "${YELLOW}Installing dependencies with pnpm...${NC}"
pnpm install

# Generate pnpm-lock.yaml
echo -e "${GREEN}✓ Generated pnpm-lock.yaml${NC}"

# Check for workspace configuration
if [ -f "pnpm-workspace.yaml" ]; then
    echo -e "${GREEN}✓ Found pnpm-workspace.yaml${NC}"
else
    echo -e "${YELLOW}No pnpm-workspace.yaml found${NC}"
    read -p "Create a basic workspace configuration? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cat > pnpm-workspace.yaml << 'EOF'
packages:
  - "packages/*"
  - "apps/*"
  - "tools/*"
  - "!**/node_modules/**"
EOF
        echo -e "${GREEN}✓ Created pnpm-workspace.yaml${NC}"
    fi
fi

# Update .gitignore
echo -e "${YELLOW}Updating .gitignore...${NC}"
if [ -f ".gitignore" ]; then
    if ! grep -q "pnpm-lock.yaml" .gitignore; then
        echo "# pnpm" >> .gitignore
        echo "pnpm-lock.yaml" >> .gitignore
        echo -e "${GREEN}✓ Added pnpm-lock.yaml to .gitignore${NC}"
    fi
    
    # Remove npm/yarn entries if they exist
    if grep -q "package-lock.json" .gitignore; then
        sed -i.bak '/package-lock.json/d' .gitignore
        echo -e "${GREEN}✓ Removed package-lock.json from .gitignore${NC}"
    fi
    
    if grep -q "yarn.lock" .gitignore; then
        sed -i.bak '/yarn.lock/d' .gitignore
        echo -e "${GREEN}✓ Removed yarn.lock from .gitignore${NC}"
    fi
else
    cat > .gitignore << 'EOF'
# Dependencies
node_modules/

# pnpm
pnpm-lock.yaml

# Logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Editor
.vscode/
.idea/
*.swp
*.swo
EOF
    echo -e "${GREEN}✓ Created .gitignore${NC}"
fi

# Create .npmrc if it doesn't exist
if [ ! -f ".npmrc" ]; then
    echo -e "${YELLOW}Creating .npmrc...${NC}"
    cat > .npmrc << 'EOF'
auto-install-peers=true
shamefully-hoist=false
strict-peer-dependencies=false
enable-pre-post-scripts=true
prefer-workspace-packages=true
link-workspace-packages=true
save-workspace-protocol=rolling
EOF
    echo -e "${GREEN}✓ Created .npmrc${NC}"
fi

# Run basic validation
echo -e "${YELLOW}Running validation...${NC}"
if pnpm list >/dev/null 2>&1; then
    echo -e "${GREEN}✓ pnpm list successful${NC}"
else
    echo -e "${RED}⚠ pnpm list failed - please check dependencies${NC}"
fi

# Show migration summary
echo -e "${GREEN}=== Migration Summary ===${NC}"
echo -e "${GREEN}✓ Migrated to pnpm successfully${NC}"
echo -e "${YELLOW}Files created/updated:${NC}"
echo "  - pnpm-lock.yaml"
echo "  - .npmrc (if not exists)"
echo "  - .gitignore (updated)"
echo "  - package.json (updated scripts and engines)"
echo "  - pnpm-workspace.yaml (if created)"
echo
echo -e "${YELLOW}Backup files created:${NC}"
echo "  - package.json.backup"
[ -f "package-lock.json.backup" ] && echo "  - package-lock.json.backup"
[ -f "yarn.lock.backup" ] && echo "  - yarn.lock.backup"
echo
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Test your project with: pnpm run <script>"
echo "2. Verify all dependencies work correctly"
echo "3. Update your CI/CD to use pnpm"
echo "4. Remove backup files when satisfied"
echo
echo -e "${GREEN}Migration completed successfully!${NC}"