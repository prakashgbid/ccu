#!/bin/bash
# Check if CC configuration is being loaded properly

echo "🔍 Checking Claude Code Configuration Loading"
echo "============================================="
echo ""

echo "📍 Current Directory: $(pwd)"
echo ""

echo "📋 Configuration Files Found:"
if [ -f ".claude/settings.json" ]; then
    echo "✅ Project settings: .claude/settings.json"
    echo "   Permissions configured: $(grep -c 'allowedTools' .claude/settings.json) sets"
    echo "   Hooks configured: $(grep -c 'PreToolUse\|PostToolUse' .claude/settings.json) types"
else
    echo "❌ No project settings found"
fi

if [ -f "$HOME/.claude/settings.json" ]; then
    echo "✅ User settings: ~/.claude/settings.json"
else
    echo "❌ No user settings found"
fi

echo ""
echo "🔧 To activate auto-approval:"
echo "1. Exit this CC session completely (Ctrl+D or 'exit')"
echo "2. Start a new CC session from this directory: /Users/MAC/Documents/projects"
echo "3. The new session will load the project settings automatically"
echo ""

echo "🧪 Test command to run after restart:"
echo "   ./test-auto-approval.sh"
echo ""

echo "📊 Monitor events with:"
echo "   ./.claude/hooks/show-daily-summary.sh"