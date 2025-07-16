#!/bin/bash

# Claude Monitor MCP Setup Script
# Based on: https://zenn.dev/karaage0703/articles/3bd2957807f311
# This script sets up Claude Monitor MCP server for Claude Code

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print with color
print_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to check if MCP server is already configured
is_mcp_configured() {
    local server_name="$1"
    claude mcp list 2>/dev/null | grep -q "^$server_name\s"
}

# Function to show banner
show_banner() {
    echo -e "${BLUE}"
    cat << 'EOF'
    ╔═══════════════════════════════════════════╗
    ║     Claude Monitor MCP Setup Script       ║
    ║                                           ║
    ║  Based on Zenn article by karaage0703     ║
    ╚═══════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Main setup function
setup_claude_monitor() {
    show_banner
    
    print_info "Claude Monitor MCPサーバーのセットアップを開始します..."
    
    # Check if claude command exists
    if ! command_exists claude; then
        print_error "Claude Code CLIがインストールされていません"
        print_info "先に以下のコマンドでClaude Codeをインストールしてください:"
        echo -e "${YELLOW}npm install -g @anthropic-ai/claude-code${NC}"
        exit 1
    fi
    
    # Check if npm/npx exists
    if ! command_exists npm || ! command_exists npx; then
        print_error "npm/npxがインストールされていません"
        print_info "Node.jsをインストールしてください"
        exit 1
    fi
    
    # Show current MCP servers
    print_info "現在設定されているMCPサーバー:"
    claude mcp list
    echo ""
    
    # Add Claude Monitor MCP server
    if is_mcp_configured "claude-monitor"; then
        print_warning "Claude Monitor MCPサーバーは既に設定されています"
        read -p "再設定しますか? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "スキップします"
            return 0
        fi
        # Remove existing configuration
        print_info "既存の設定を削除しています..."
        claude mcp remove claude-monitor
    fi
    
    print_info "Claude Monitor MCPサーバーを追加しています..."
    
    # Add the server using Claude CLI
    # Note: Using npx -y to auto-install without prompting
    claude mcp add claude-monitor -s local -- npx -y claude-monitor-mcp
    
    if [ $? -eq 0 ]; then
        print_success "Claude Monitor MCPサーバーが正常に追加されました!"
    else
        print_error "Claude Monitor MCPサーバーの追加に失敗しました"
        exit 1
    fi
    
    # Verify installation
    print_info "設定を確認しています..."
    if is_mcp_configured "claude-monitor"; then
        print_success "Claude Monitor MCPサーバーが正しく設定されています"
    else
        print_error "設定の確認に失敗しました"
        exit 1
    fi
    
    # Show final configuration
    echo ""
    print_info "最終的なMCPサーバー設定:"
    claude mcp list
    
    # Show usage instructions
    echo ""
    print_success "セットアップが完了しました! 🎉"
    echo ""
    echo -e "${CYAN}使用方法:${NC}"
    echo "1. Claude Codeを再起動してください"
    echo "2. チャット内で '/mcp' と入力してMCPサーバーを確認できます"
    echo "3. Claude MonitorのMCPツールが利用可能になります"
    echo ""
    echo -e "${YELLOW}注意事項:${NC}"
    echo "- Claude Monitorの詳細なドキュメントは公式リポジトリを参照してください"
    echo "- 問題が発生した場合は、'claude mcp remove claude-monitor' で削除できます"
    echo ""
}

# Additional MCP servers setup function
setup_additional_mcp_servers() {
    echo ""
    print_info "追加のMCPサーバーをセットアップしますか?"
    echo ""
    echo "利用可能なMCPサーバー:"
    echo "1. GitHub MCP - GitHubリポジトリ操作"
    echo "2. Context7 MCP - コンテキスト管理"
    echo "3. Playwright MCP - ブラウザ自動化"
    echo "4. Debug Thinking MCP - デバッグ支援"
    echo "5. ArXiv MCP - 論文検索"
    echo "6. Markitdown MCP - PDF/PPTXをMarkdownに変換"
    echo "7. YouTube MCP - YouTube動画分析"
    echo "0. スキップ"
    echo ""
    
    read -p "番号を選択してください (複数選択可、スペース区切り): " -a selections
    
    for selection in "${selections[@]}"; do
        case $selection in
            1)
                if ! is_mcp_configured "github"; then
                    print_info "GitHub MCPサーバーを追加しています..."
                    claude mcp add github -s local -- npx -y @modelcontextprotocol/server-github
                    print_success "GitHub MCPサーバーを追加しました"
                else
                    print_warning "GitHub MCPサーバーは既に設定されています"
                fi
                ;;
            2)
                if ! is_mcp_configured "context7"; then
                    print_info "Context7 MCPサーバーを追加しています..."
                    claude mcp add context7 -s local -- npx -y @context7/mcp-server
                    print_success "Context7 MCPサーバーを追加しました"
                else
                    print_warning "Context7 MCPサーバーは既に設定されています"
                fi
                ;;
            3)
                if ! is_mcp_configured "playwright"; then
                    print_info "Playwright MCPサーバーを追加しています..."
                    claude mcp add playwright -s local -- npx -y @automatalabs/mcp-server-playwright
                    print_success "Playwright MCPサーバーを追加しました"
                else
                    print_warning "Playwright MCPサーバーは既に設定されています"
                fi
                ;;
            4)
                if ! is_mcp_configured "debug-thinking"; then
                    print_info "Debug Thinking MCPサーバーを追加しています..."
                    claude mcp add debug-thinking -s local -- npx -y mcp-server-debug-thinking
                    print_success "Debug Thinking MCPサーバーを追加しました"
                else
                    print_warning "Debug Thinking MCPサーバーは既に設定されています"
                fi
                ;;
            5)
                if ! is_mcp_configured "arxiv"; then
                    print_info "ArXiv MCPサーバーを追加しています..."
                    claude mcp add arxiv -s local -- npx -y @modelcontextprotocol/server-arxiv
                    print_success "ArXiv MCPサーバーを追加しました"
                else
                    print_warning "ArXiv MCPサーバーは既に設定されています"
                fi
                ;;
            6)
                if ! is_mcp_configured "markitdown"; then
                    print_info "Markitdown MCPサーバーを追加しています..."
                    # Check if uv is installed
                    if ! command_exists uv; then
                        print_warning "uvがインストールされていません"
                        print_info "uvをインストールしています..."
                        curl -LsSf https://astral.sh/uv/install.sh | sh
                    fi
                    claude mcp add markitdown -s local -- uvx markitdown-mcp
                    print_success "Markitdown MCPサーバーを追加しました"
                else
                    print_warning "Markitdown MCPサーバーは既に設定されています"
                fi
                ;;
            7)
                if ! is_mcp_configured "youtube"; then
                    print_info "YouTube MCPサーバーを追加しています..."
                    claude mcp add youtube -s local -- npx -y @modelcontextprotocol/server-youtube
                    print_success "YouTube MCPサーバーを追加しました"
                else
                    print_warning "YouTube MCPサーバーは既に設定されています"
                fi
                ;;
            0)
                print_info "追加のMCPサーバーのセットアップをスキップします"
                break
                ;;
            *)
                print_warning "無効な選択: $selection"
                ;;
        esac
    done
}

# Show environment setup tips
show_environment_tips() {
    echo ""
    print_info "環境変数の設定について:"
    echo ""
    echo -e "${YELLOW}GitHub MCPを使用する場合:${NC}"
    echo "export GITHUB_PERSONAL_ACCESS_TOKEN='your-github-token'"
    echo ""
    echo -e "${YELLOW}プロキシ環境の場合:${NC}"
    echo "export HTTP_PROXY='http://proxy.example.com:8080'"
    echo "export HTTPS_PROXY='http://proxy.example.com:8080'"
    echo ""
    echo "これらの環境変数は ~/.zshrc.local または ~/.bashrc.local に設定できます"
}

# Main execution
main() {
    # Setup Claude Monitor
    setup_claude_monitor
    
    # Ask for additional MCP servers
    setup_additional_mcp_servers
    
    # Show environment tips
    show_environment_tips
    
    echo ""
    print_success "すべてのセットアップが完了しました! 🚀"
    echo ""
    echo "Claude Codeを再起動して、新しいMCPサーバーを使用してください。"
}

# Run main function
main