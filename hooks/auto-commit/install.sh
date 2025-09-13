#!/bin/bash

# Auto-Commit Hook System Installer
# Part of Claude Code Ultimate (CCU)

echo "🚀 Installing Auto-Commit Hook System for Claude Code"
echo "======================================================"

HOOKS_DIR="$HOME/.config/claude/hooks"
CONFIG_DIR="$HOME/.claude"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Create directories
echo "📁 Creating directories..."
mkdir -p "$HOOKS_DIR"
mkdir -p "$CONFIG_DIR/logs"

# Copy hook scripts
echo "📝 Installing hooks..."
cp "$SCRIPT_DIR/auto-commit-hook.sh" "$HOOKS_DIR/"
cp "$SCRIPT_DIR/task-completion-commit.sh" "$HOOKS_DIR/"
cp "$SCRIPT_DIR/configure-auto-commit.sh" "$HOOKS_DIR/"

# Make executable
chmod +x "$HOOKS_DIR"/*.sh

# Install configuration
if [ ! -f "$CONFIG_DIR/auto-commit.conf" ]; then
    echo "⚙️  Installing default configuration..."
    cp "$SCRIPT_DIR/auto-commit.conf.example" "$CONFIG_DIR/auto-commit.conf"
else
    echo "⚙️  Configuration already exists, skipping..."
fi

# Update post-tool-use hook
POST_HOOK="$HOOKS_DIR/post-tool-use.sh"
if [ -f "$POST_HOOK" ]; then
    echo "🔗 Integrating with post-tool-use hook..."
    
    # Check if already integrated
    if ! grep -q "auto-commit-hook.sh" "$POST_HOOK"; then
        cat >> "$POST_HOOK" << 'EOF'

# Auto-commit functionality
# Check for task completion and auto-commit changes
if [ -f "$HOME/.config/claude/hooks/task-completion-commit.sh" ]; then
    export CLAUDE_TOOL_NAME="$TOOL_NAME"
    export CLAUDE_TOOL_INPUT="$CLAUDE_TOOL_INPUT"
    "$HOME/.config/claude/hooks/task-completion-commit.sh" 2>/dev/null &
fi

# General auto-commit for file modifications
if [[ "$TOOL_NAME" =~ ^(Write|Edit|MultiEdit)$ ]] && [ "$EXIT_CODE" == "0" ]; then
    if [ -f "$HOME/.config/claude/hooks/auto-commit-hook.sh" ]; then
        export CLAUDE_TOOL_NAME="$TOOL_NAME"
        "$HOME/.config/claude/hooks/auto-commit-hook.sh" 2>/dev/null &
    fi
fi
EOF
        echo "✅ Integration complete"
    else
        echo "✅ Already integrated"
    fi
else
    echo "⚠️  Post-tool-use hook not found, manual integration needed"
fi

# Test installation
echo ""
echo "🧪 Testing installation..."
if [ -f "$HOOKS_DIR/auto-commit-hook.sh" ] && [ -f "$CONFIG_DIR/auto-commit.conf" ]; then
    echo "✅ Installation successful!"
    echo ""
    echo "📋 Configuration:"
    grep "^ENABLED" "$CONFIG_DIR/auto-commit.conf"
    grep "^COMMIT_THRESHOLD" "$CONFIG_DIR/auto-commit.conf"
    grep "^AUTO_MERGE_THRESHOLD" "$CONFIG_DIR/auto-commit.conf"
    echo ""
    echo "📖 Documentation: $SCRIPT_DIR/README.md"
    echo ""
    echo "🎯 Quick Commands:"
    echo "  Enable:  sed -i 's/ENABLED=false/ENABLED=true/' ~/.claude/auto-commit.conf"
    echo "  Disable: sed -i 's/ENABLED=true/ENABLED=false/' ~/.claude/auto-commit.conf"
    echo "  Logs:    tail -f ~/.claude/logs/auto-commit.log"
else
    echo "❌ Installation failed"
    exit 1
fi

echo ""
echo "✨ Auto-Commit Hook System is ready!"
echo "Changes will be automatically committed after CC operations."