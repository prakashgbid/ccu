#!/bin/bash
# Claude Code Hook System v2.0 Installation Script

echo "🚀 Installing Claude Code Hook System v2.0..."
echo "============================================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 1. Backup existing configuration
if [ -d ~/.claude ] || [ -d ~/.config/claude ]; then
    echo "📦 Backing up existing configuration..."
    BACKUP_DIR="$HOME/.claude-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    [ -d ~/.claude ] && cp -r ~/.claude "$BACKUP_DIR/"
    [ -d ~/.config/claude ] && cp -r ~/.config/claude "$BACKUP_DIR/"
    echo "  Backup saved to: $BACKUP_DIR"
fi

# 2. Create directory structure
echo ""
echo "📁 Creating directory structure..."
mkdir -p ~/.config/claude/hooks
mkdir -p ~/.claude/{logs,services,test,archived-hooks-migration}

# 3. Archive old hooks if they exist
if [ -d ~/.claude/hooks ] && [ "$(ls -A ~/.claude/hooks)" ]; then
    echo ""
    echo "📦 Archiving old hooks..."
    mv ~/.claude/hooks/* ~/.claude/archived-hooks-migration/ 2>/dev/null
    echo "  Old hooks archived to ~/.claude/archived-hooks-migration/"
fi

# 4. Install new hooks
echo ""
echo "🔧 Installing hooks..."
cp configs/fixed-hooks/* ~/.config/claude/hooks/
chmod +x ~/.config/claude/hooks/*.sh
echo "  ✅ Hooks installed to ~/.config/claude/hooks/"

# 5. Install service manager
echo ""
echo "🔧 Installing service manager..."
cp configs/services/* ~/.claude/services/
chmod +x ~/.claude/services/*.sh
echo "  ✅ Service manager installed"

# 6. Install test suite
echo ""
echo "🔧 Installing test suite..."
cp configs/test/* ~/.claude/test/
chmod +x ~/.claude/test/*.sh
echo "  ✅ Test suite installed"

# 7. Update settings.json
echo ""
echo "📝 Updating settings.json..."
if [ -f ~/.claude/settings.json ]; then
    cp ~/.claude/settings.json ~/.claude/settings.json.backup
    echo "  Backed up existing settings.json"
fi
cp configs/settings-with-hooks.json ~/.claude/settings.json
echo "  ✅ Settings updated with hook configuration"

# 8. Clean up project-level hooks if they exist
if [ -d ~/Documents/projects/.claude/hooks ]; then
    echo ""
    echo "🧹 Cleaning up project-level hooks..."
    rm -rf ~/Documents/projects/.claude/hooks
    echo "  ✅ Project-level hooks removed"
fi

# 9. Test the installation
echo ""
echo "🧪 Running tests..."
if ~/.claude/test/test-hooks.sh > /tmp/hook-test-results.txt 2>&1; then
    echo -e "  ${GREEN}✅ All tests passed!${NC}"
else
    echo -e "  ${YELLOW}⚠️  Some tests failed. Check /tmp/hook-test-results.txt${NC}"
fi

# 10. Check service status
echo ""
echo "📊 Checking services..."
~/.claude/services/service-manager.sh status

echo ""
echo "============================================"
echo -e "${GREEN}✅ Hook System v2.0 Installation Complete!${NC}"
echo ""
echo "📚 Quick Reference:"
echo "  • Hooks location: ~/.config/claude/hooks/"
echo "  • Logs location: ~/.claude/logs/"
echo "  • Service manager: ~/.claude/services/service-manager.sh"
echo "  • Test suite: ~/.claude/test/test-hooks.sh"
echo ""
echo "🔧 Commands:"
echo "  • Check services: ~/.claude/services/service-manager.sh status"
echo "  • Start services: ~/.claude/services/service-manager.sh start"
echo "  • Run tests: ~/.claude/test/test-hooks.sh"
echo ""
echo "📝 Note: Restart Claude Code for hooks to take full effect."
echo ""