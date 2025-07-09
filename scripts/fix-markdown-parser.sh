#!/bin/bash

# ===============================================
# Markdown Parser Fix Script
# markdownパーサーの"can't change language without remark"エラーを修正
# ===============================================

echo "🔧 Fixing markdown parser issue..."

# Neovimのデータディレクトリを取得
NVIM_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"
PARSER_DIR="$NVIM_DATA_DIR/lazy/nvim-treesitter/parser"

# markdownパーサーが存在する場合は削除
if [ -f "$PARSER_DIR/markdown.so" ]; then
    echo "📦 Removing existing markdown parser..."
    rm -f "$PARSER_DIR/markdown.so"
fi

# markdownパーサーのキャッシュをクリア
if [ -d "$NVIM_DATA_DIR/treesitter" ]; then
    echo "🗑️  Clearing treesitter cache..."
    find "$NVIM_DATA_DIR/treesitter" -name "*markdown*" -type f -delete 2>/dev/null || true
fi

# Neovimでパーサーを再インストール
echo "📥 Reinstalling markdown parser in Neovim..."
nvim --headless -c "TSInstall! markdown" -c "qa" 2>/dev/null || {
    echo "⚠️  Could not reinstall parser automatically."
    echo "   Please run ':TSInstall markdown' manually in Neovim."
}

echo "✅ Markdown parser fix complete!"
echo ""
echo "📝 Notes:"
echo "   - The configuration now disables treesitter for markdown files"
echo "   - Traditional vim syntax highlighting will be used instead"
echo "   - This prevents the 'remark' error while maintaining functionality"
echo ""
echo "🔄 If issues persist, restart Neovim and the fix will apply automatically."