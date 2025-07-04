# Claude Desktop Configuration

This directory contains shared configuration for Claude Desktop to ensure safe and consistent usage across all environments.

## 📋 Configuration Files

### claude_desktop_config.json
Main configuration file for Claude Desktop containing:
- **Prohibited Commands**: Comprehensive list of dangerous commands that are blocked
- **Safety Settings**: Options for confirming destructive actions
- **Model Settings**: Default model selection and parameters
- **Workspace Settings**: History and autosave configuration
- **Keyboard Shortcuts**: Common shortcuts for productivity

## 🚨 Prohibited Commands

The configuration blocks various forms of dangerous commands, particularly:
- `rm -rf /` and variations (system-wide deletion)
- `rm -rf ~` and variations (home directory deletion)
- Wildcard deletions at root or home level
- Sudo variations of the above commands

These restrictions prevent accidental deletion of:
- System files
- User documents and photos
- Application data
- Configuration files

## 🔧 Installation

### Automatic (via setup script)
```bash
./scripts/setup.sh
```

### Manual Installation

#### macOS
```bash
cp claude/claude_desktop_config.json ~/Library/Application\ Support/Claude/
```

#### Linux
```bash
cp claude/claude_desktop_config.json ~/.config/claude/
```

#### Windows
```powershell
Copy-Item claude/claude_desktop_config.json -Destination "$env:APPDATA\Claude\"
```

## 📝 Customization

You can modify the configuration to add:
- Additional prohibited commands
- Custom prompts for specific workflows
- Keyboard shortcut preferences
- Model selection defaults

## 🔒 Safety Features

1. **Command Blocking**: Prevents execution of destructive commands
2. **Confirmation Prompts**: Requires confirmation for potentially dangerous actions
3. **Sudo Protection**: Blocks sudo variations of dangerous commands
4. **System Modification Protection**: Prevents unauthorized system changes

## 📚 References

- [Claude Safe Command Configuration](https://zenn.dev/taiyogakuse/articles/claude-safe-command)
- [Claude Desktop Documentation](https://docs.anthropic.com/claude/docs/claude-desktop)