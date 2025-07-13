# MCP (Model Context Protocol) Setup Guide

This guide explains how to set up and use MCP servers with Claude Code in this project.

## Overview

MCP (Model Context Protocol) servers extend Claude Code's capabilities by providing access to external tools and services. This project includes configuration for four MCP servers:

- **GitHub MCP**: Repository operations, issues, PRs, and GitHub API access
- **Context7 MCP**: Enhanced context management and memory persistence
- **Playwright MCP**: Web automation, scraping, and browser testing
- **Debug Thinking MCP**: Enhanced debugging and thought process visualization

## Installation

### Automatic Setup

The MCP configuration is automatically installed when you run the main setup script:

```bash
./scripts/setup.sh
```

### Manual Setup

To install only the MCP configuration:

```bash
./scripts/setup-mcp.sh
```

## Configuration Files

### MCP Server Configuration

The MCP server definitions are stored in:
- `claude/mcp_config.json` - Basic configuration
- `claude/mcp_servers_detailed.json` - Detailed configuration with descriptions

### Integration with Claude Code

The setup script automatically merges the MCP configuration into your Claude Code settings at:
- macOS: `~/.claude/settings.json`
- Linux: `~/.claude/settings.json`

## GitHub MCP Setup

The GitHub MCP server requires a personal access token to function properly.

### Creating a GitHub Token

1. Go to [GitHub Settings > Tokens](https://github.com/settings/tokens)
2. Click "Generate new token (classic)"
3. Select the following scopes:
   - `repo` (Full control of private repositories)
   - `read:org` (Read org and team membership)
   - `read:user` (Read user profile data)
4. Generate the token and copy it

### Setting the Token

Add the token to your shell configuration:

```bash
# In ~/.zshrc or ~/.bashrc
export GITHUB_PERSONAL_ACCESS_TOKEN='your-token-here'
```

Then reload your shell:
```bash
source ~/.zshrc  # or ~/.bashrc
```

## Using MCP Servers

### GitHub MCP

Once configured, you can use GitHub operations in Claude Code:

```
# Examples of what you can ask Claude Code:
- "Create a new issue in this repository"
- "List all open PRs"
- "Search for issues related to Flutter"
- "Create a pull request for the current branch"
```

### Context7 MCP

Context7 provides enhanced context management:

```
# Examples of usage:
- Preserves context across sessions
- Manages memory and session history
- Enables context switching between different tasks
```

### Playwright MCP

Playwright enables web automation:

```
# Examples of what you can ask Claude Code:
- "Take a screenshot of https://example.com"
- "Extract all links from this webpage"
- "Fill out and submit this web form"
- "Test the login flow of my web app"
```

### Debug Thinking MCP

Debug Thinking provides enhanced debugging capabilities:

```
# Examples of what you can ask Claude Code:
- "Show me your thinking process for solving this problem"
- "Debug this code with step-by-step reasoning"
- "Explain your thought process while analyzing this issue"
- "Visualize the problem-solving steps for this algorithm"
```

This server helps visualize Claude's cognitive process and provides detailed debugging information for complex problem-solving tasks.

## Troubleshooting

### MCP Servers Not Loading

1. Ensure Claude Code is restarted after installation
2. Check if the settings file exists:
   ```bash
   cat ~/.claude/settings.json | jq '.mcpServers'
   ```

### GitHub Token Issues

1. Verify the token is set:
   ```bash
   echo $GITHUB_PERSONAL_ACCESS_TOKEN
   ```
2. Ensure the token has the required scopes
3. Check if the token hasn't expired

### Testing MCP Servers

You can test if the MCP servers are accessible:

```bash
# Test GitHub MCP
npx -y @modelcontextprotocol/server-github --help

# Test Context7 MCP  
npx -y @context7/mcp-server --help

# Test Playwright MCP
npx -y @automatalabs/mcp-server-playwright --help
```

## Environment Variables

Create a `.env.mcp` file for local environment variables:

```bash
cp .env.mcp.template .env.mcp
# Edit .env.mcp with your values
```

Note: `.env.mcp` is gitignored to prevent accidental commits of sensitive data.

## Security Considerations

- Never commit your GitHub personal access token
- The token is only stored in your shell environment
- MCP servers run locally and communicate with Claude Code via the MCP protocol
- Each MCP server has its own security model and permissions

## Additional Resources

- [MCP Documentation](https://modelcontextprotocol.io/docs)
- [GitHub MCP Server](https://github.com/modelcontextprotocol/servers/tree/main/src/github)
- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)