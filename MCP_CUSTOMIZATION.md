# MCP Customization Guide

This guide explains how to customize Claude MCP (Model Context Protocol) settings for different local environments.

## Overview

The setup scripts now support environment-based customization for MCP servers, allowing you to:
- Use custom GitHub tokens for different accounts
- Configure proxy settings for corporate environments
- Use locally installed MCP servers instead of npx
- Customize data directories and settings per environment

## Quick Start

1. **Set environment variables before running setup:**
   ```bash
   export GITHUB_PERSONAL_ACCESS_TOKEN='your-token-here'
   ./scripts/setup.sh
   ```

2. **Or add them to your shell configuration:**
   ```bash
   # In ~/.zshrc.local or ~/.bashrc.local
   export GITHUB_PERSONAL_ACCESS_TOKEN='your-token-here'
   export PLAYWRIGHT_HEADLESS=true
   ```

## Available Environment Variables

### GitHub MCP Server
- `GITHUB_PERSONAL_ACCESS_TOKEN` - Personal access token for GitHub API (required for full functionality)
- `GITHUB_API_URL` - Custom GitHub API endpoint (for GitHub Enterprise)
- `MCP_GITHUB_PATH` - Custom path to local GitHub MCP server

### Context7 MCP Server
- `CONTEXT7_DATA_DIR` - Custom context storage location (default: `~/.context7/data`)
- `MCP_CONTEXT7_PATH` - Custom path to local Context7 MCP server

### Playwright MCP Server
- `PLAYWRIGHT_BROWSERS_PATH` - Custom browser download location
- `PLAYWRIGHT_HEADLESS` - Headless mode (`true`/`false`)
- `MCP_PLAYWRIGHT_PATH` - Custom path to local Playwright MCP server

### Debug Thinking MCP Server
- `DEBUG_THINKING_LOG_LEVEL` - Log level (`debug`, `info`, `warn`, `error`)
- `DEBUG_THINKING_DATA_DIR` - Custom debug data directory
- `MCP_DEBUG_THINKING_PATH` - Custom path to local Debug Thinking MCP server

### Proxy Configuration
- `HTTP_PROXY` - HTTP proxy URL
- `HTTPS_PROXY` - HTTPS proxy URL
- `NO_PROXY` - Comma-separated list of no-proxy hosts

## Usage Examples

### Example 1: Basic GitHub Token Setup
```bash
export GITHUB_PERSONAL_ACCESS_TOKEN='ghp_xxxxxxxxxxxxxxxxxxxx'
./scripts/setup.sh
```

### Example 2: Corporate Environment with Proxy
```bash
export HTTP_PROXY='http://proxy.company.com:8080'
export HTTPS_PROXY='http://proxy.company.com:8080'
export NO_PROXY='localhost,127.0.0.1,*.company.internal'
export GITHUB_PERSONAL_ACCESS_TOKEN='your-token'
./scripts/setup.sh
```

### Example 3: Using Local MCP Server Installations
```bash
# If you have MCP servers installed locally
export MCP_GITHUB_PATH='/usr/local/bin/github-mcp-server'
export MCP_CONTEXT7_PATH='/usr/local/bin/context7-mcp-server'
./scripts/setup.sh
```

### Example 4: Custom Data Directories
```bash
export CONTEXT7_DATA_DIR="$HOME/Documents/context7-data"
export DEBUG_THINKING_DATA_DIR="$HOME/Documents/debug-thinking"
export PLAYWRIGHT_BROWSERS_PATH="$HOME/.local/share/playwright"
./scripts/setup.sh
```

## Persistent Configuration

The setup script automatically creates `~/.zshrc.local` with a template for MCP environment variables. Edit this file to make your configuration persistent:

```bash
# Edit your local configuration
vim ~/.zshrc.local

# Add your environment variables
export GITHUB_PERSONAL_ACCESS_TOKEN='your-token-here'
export PLAYWRIGHT_HEADLESS=true

# Reload your shell configuration
source ~/.zshrc
```

## Troubleshooting

### Token Not Working
If your GitHub token isn't working:
1. Ensure it has the required scopes: `repo`, `read:org`, `read:user`
2. Check if it's exported correctly: `echo $GITHUB_PERSONAL_ACCESS_TOKEN`
3. Restart Claude Code after setting the token

### Proxy Issues
For proxy environments:
1. Ensure proxy URLs include the protocol: `http://proxy:8080`
2. Add internal domains to `NO_PROXY`
3. Test connectivity: `curl -I https://api.github.com`

### Custom Path Not Found
If using custom MCP paths:
1. Ensure the path is absolute: `/full/path/to/server`
2. Check file permissions: `ls -la /path/to/server`
3. Verify the executable works: `/path/to/server --help`

## Advanced Usage

### Multiple Environments
You can create multiple configuration files for different environments:

```bash
# Work configuration
cat > ~/.zshrc.work << EOF
export GITHUB_PERSONAL_ACCESS_TOKEN='work-token'
export GITHUB_API_URL='https://github.company.com/api/v3'
export HTTP_PROXY='http://proxy.company.com:8080'
EOF

# Personal configuration
cat > ~/.zshrc.personal << EOF
export GITHUB_PERSONAL_ACCESS_TOKEN='personal-token'
unset HTTP_PROXY
unset HTTPS_PROXY
EOF

# Switch environments
source ~/.zshrc.work    # For work
source ~/.zshrc.personal # For personal projects
```

### Checking Current Configuration
To see which MCP servers are configured:
```bash
claude mcp list
```

To verify environment variables:
```bash
./scripts/setup.sh --dry-run
```

## Security Notes

1. **Never commit tokens**: Keep your tokens in local configuration files
2. **Use appropriate scopes**: Only grant necessary permissions to tokens
3. **Rotate tokens regularly**: Update tokens periodically for security
4. **Secure local files**: Ensure `.zshrc.local` has appropriate permissions:
   ```bash
   chmod 600 ~/.zshrc.local
   ```