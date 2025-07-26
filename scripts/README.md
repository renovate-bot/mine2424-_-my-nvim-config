# Scripts Directory

This directory contains utility scripts for the Neovim Flutter development environment.

## Main Scripts

### setup.sh
Main installation script for the complete development environment.
```bash
./setup.sh                # Config files only (default)
./setup.sh --full         # Complete installation
./setup.sh --help         # Show all options
```

### flutter.sh
Consolidated Flutter development utilities.
```bash
./flutter.sh create myapp        # Create new project
./flutter.sh setup              # Setup existing project
./flutter.sh clean              # Clean project
./flutter.sh test               # Run tests with coverage
./flutter.sh analyze            # Analyze and format code
./flutter.sh build apk release  # Build for production
```

### pnpm.sh
Package manager utilities for pnpm.
```bash
./pnpm.sh install    # Install pnpm
./pnpm.sh setup      # Configure pnpm
./pnpm.sh migrate    # Migrate npm/yarn project to pnpm
./pnpm.sh workspace  # Show workspace info
```

### mcp.sh
Model Context Protocol setup for Claude Code.
```bash
./mcp.sh    # Adaptive installation of MCP servers
```

### verify-setup.sh
Verify the development environment setup.
```bash
./verify-setup.sh    # Run all verification tests
```

### setup-claude-monitor.sh
Install Claude Code usage monitor.
```bash
./setup-claude-monitor.sh    # Install monitor via pipx
```

## Removed Scripts

The following scripts have been consolidated:
- `flutter-utils.sh` → `flutter.sh`
- `create-flutter-project.sh` → `flutter.sh create`
- `setup-pnpm.sh` → `pnpm.sh install/setup`
- `migrate-to-pnpm.sh` → `pnpm.sh migrate`
- `setup-mcp.sh` → `mcp.sh`
- `setup-mcp-adaptive.sh` → `mcp.sh`

## Script Organization

Scripts are now organized by functionality:
- **Environment Setup**: setup.sh
- **Development Tools**: flutter.sh, pnpm.sh
- **Claude Integration**: mcp.sh, setup-claude-monitor.sh
- **Verification**: verify-setup.sh