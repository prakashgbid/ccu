#!/bin/bash

# ============================================================================
# ONE-TIME INSTALLATION SCRIPT
# Run this ONCE and NEVER think about it again!
# ============================================================================

echo "🚀 Installing CKS/CLS Autonomous System..."

# 1. Make everything executable
chmod +x /Users/MAC/.claude/*.sh
chmod +x /Users/MAC/.claude/hooks/*.sh

# 2. Add to shell startup (works for both bash and zsh)
AUTOSTART_LINE="[ -f /Users/MAC/.claude/cks-cls-autostart.sh ] && /Users/MAC/.claude/cks-cls-autostart.sh > /dev/null 2>&1 &"

# Add to bashrc
if [ -f ~/.bashrc ]; then
    if ! grep -q "cks-cls-autostart" ~/.bashrc; then
        echo "" >> ~/.bashrc
        echo "# CKS/CLS Autonomous System (Auto-start)" >> ~/.bashrc
        echo "$AUTOSTART_LINE" >> ~/.bashrc
        echo "✅ Added to ~/.bashrc"
    fi
fi

# Add to zshrc
if [ -f ~/.zshrc ]; then
    if ! grep -q "cks-cls-autostart" ~/.zshrc; then
        echo "" >> ~/.zshrc
        echo "# CKS/CLS Autonomous System (Auto-start)" >> ~/.zshrc
        echo "$AUTOSTART_LINE" >> ~/.zshrc
        echo "✅ Added to ~/.zshrc"
    fi
fi

# Add to bash_profile (macOS)
if [ -f ~/.bash_profile ]; then
    if ! grep -q "cks-cls-autostart" ~/.bash_profile; then
        echo "" >> ~/.bash_profile
        echo "# CKS/CLS Autonomous System (Auto-start)" >> ~/.bash_profile
        echo "$AUTOSTART_LINE" >> ~/.bash_profile
        echo "✅ Added to ~/.bash_profile"
    fi
fi

# 3. Create CC configuration file
cat > ~/.claude/config.yml << 'EOF'
# Claude Code Configuration
hooks:
  enabled: true
  path: /Users/MAC/.claude/hooks
  
  session_start: session-start-hook.sh
  user_prompt_submit: user-prompt-submit-hook.sh
  pre_tool_use: pre-tool-use-hook.sh
  
agents:
  knowledge_checker:
    enabled: true
    auto_invoke: true
    path: /Users/MAC/.claude/agents/knowledge-checker
    
environment:
  CC_HOOKS_PATH: /Users/MAC/.claude/hooks
  CKS_API_URL: http://localhost:5000
  CLS_API_URL: http://localhost:5003
  
autostart:
  cks_cls: true
  monitor: true
  recovery: true
EOF

echo "✅ Created CC configuration"

# 4. Create LaunchAgent for macOS (runs at login)
if [[ "$OSTYPE" == "darwin"* ]]; then
    mkdir -p ~/Library/LaunchAgents
    cat > ~/Library/LaunchAgents/com.cks-cls.autostart.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.cks-cls.autostart</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>/Users/MAC/.claude/cks-cls-autostart.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <dict>
        <key>SuccessfulExit</key>
        <false/>
    </dict>
    <key>StandardOutPath</key>
    <string>/tmp/cks-cls-autostart.out</string>
    <key>StandardErrorPath</key>
    <string>/tmp/cks-cls-autostart.err</string>
</dict>
</plist>
EOF
    
    # Load the LaunchAgent
    launchctl load ~/Library/LaunchAgents/com.cks-cls.autostart.plist 2>/dev/null
    echo "✅ Created macOS LaunchAgent (auto-starts at login)"
fi

# 5. Create systemd service for Linux
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    mkdir -p ~/.config/systemd/user/
    cat > ~/.config/systemd/user/cks-cls-autostart.service << 'EOF'
[Unit]
Description=CKS/CLS Autonomous System
After=network.target

[Service]
Type=forking
ExecStart=/bin/bash /Users/MAC/.claude/cks-cls-autostart.sh
Restart=always
RestartSec=10

[Install]
WantedBy=default.target
EOF
    
    systemctl --user daemon-reload
    systemctl --user enable cks-cls-autostart.service
    systemctl --user start cks-cls-autostart.service
    echo "✅ Created systemd service (auto-starts at boot)"
fi

# 6. Start it right now
echo "🔄 Starting the system now..."
/Users/MAC/.claude/cks-cls-autostart.sh

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ INSTALLATION COMPLETE!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "The CKS/CLS system will now:"
echo "  • Start automatically when you log in"
echo "  • Start automatically when you open terminal"
echo "  • Start automatically when you use Claude Code"
echo "  • Monitor and restart itself if it crashes"
echo "  • Capture all learning data automatically"
echo ""
echo "🎯 YOU NEVER HAVE TO DO ANYTHING AGAIN!"
echo ""
echo "To verify it's working:"
echo "  curl http://localhost:5000/api/stats"
echo ""
echo "To see logs:"
echo "  tail -f /tmp/cks_cls_autostart.log"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"