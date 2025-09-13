#!/bin/bash

# ============================================================================
# CKS/CLS COMPLETE AUTOMATION
# This script makes EVERYTHING automatic - you don't need to remember anything
# ============================================================================

echo "🤖 CKS/CLS Complete Automation Starting..."

# Make all scripts executable
chmod +x /Users/MAC/.claude/hooks/*.sh
chmod +x /Users/MAC/.claude/*.sh
chmod +x /Users/MAC/Documents/projects/caia/knowledge-system/*.py

# 1. AUTO-CHECK BEFORE CODE
# This will run automatically when CC is about to write code
echo "✅ Auto-check enabled"
export CKS_AUTO_CHECK=true

# 2. AUTO-TRAINING AFTER RESPONSES
# Start the auto-trainer if not running
if ! pgrep -f "auto-trainer.sh" > /dev/null; then
    /Users/MAC/.claude/auto-trainer.sh &
    echo "✅ Auto-trainer started"
else
    echo "✅ Auto-trainer already running"
fi

# 3. AUTO-STATS DISPLAY
# Create a periodic stats display
(while true; do
    # Every 10 minutes, update dashboard
    /Users/MAC/.claude/cks-stats-dashboard.sh > /tmp/cks_dashboard.txt 2>/dev/null
    sleep 600
done) &
echo "✅ Stats dashboard updating every 10 minutes"

# 4. AUTO-CAPTURE PROMPTS
# Set up prompt capture for training
cat > /Users/MAC/.claude/hooks/capture-prompt.sh << 'EOF'
#!/bin/bash
# Capture user prompts for training
if [ -n "$1" ]; then
    echo "$1" > /tmp/last_user_prompt.txt
    echo "[$(date)] Captured prompt" >> /tmp/cks_capture.log
fi
EOF
chmod +x /Users/MAC/.claude/hooks/capture-prompt.sh

# 5. AUTO-CAPTURE RESPONSES
cat > /Users/MAC/.claude/hooks/capture-response.sh << 'EOF'
#!/bin/bash
# Capture CC responses for training
if [ -n "$1" ]; then
    echo "$1" > /tmp/last_cc_response.txt
    echo "[$(date)] Captured response" >> /tmp/cks_capture.log
fi
EOF
chmod +x /Users/MAC/.claude/hooks/capture-response.sh

# 6. CREATE MASTER COMMAND
cat > /Users/MAC/.claude/cks << 'EOF'
#!/bin/bash

case "$1" in
    stats)
        /Users/MAC/.claude/cks-stats-dashboard.sh
        ;;
    check)
        /Users/MAC/.claude/cks-check "${2:-test}"
        ;;
    train)
        /Users/MAC/.claude/train "${@:2}"
        ;;
    status)
        echo "CKS/CLS System Status:"
        lsof -i :5000 > /dev/null 2>&1 && echo "  ✅ API: Active" || echo "  ❌ API: Down"
        lsof -i :5004 > /dev/null 2>&1 && echo "  ✅ Trainer: Active" || echo "  ❌ Trainer: Down"
        lsof -i :5555 > /dev/null 2>&1 && echo "  ✅ Bridge: Active" || echo "  ❌ Bridge: Down"
        pgrep -f "auto-trainer" > /dev/null && echo "  ✅ Auto-trainer: Running" || echo "  ❌ Auto-trainer: Not running"
        ;;
    *)
        echo "CKS/CLS Commands:"
        echo "  cks stats   - Show learning dashboard"
        echo "  cks check   - Check for duplicates"
        echo "  cks train   - Manual training"
        echo "  cks status  - System status"
        ;;
esac
EOF
chmod +x /Users/MAC/.claude/cks

echo ""
echo "═══════════════════════════════════════════════════"
echo "✨ CKS/CLS AUTOMATION COMPLETE!"
echo "═══════════════════════════════════════════════════"
echo ""
echo "🎯 Everything is now AUTOMATIC:"
echo "  • Duplicate checking before code generation"
echo "  • Training capture after interactions"
echo "  • Stats monitoring every 10 minutes"
echo "  • Zero manual intervention required"
echo ""
echo "📊 Quick Commands (optional):"
echo "  cks stats  - View dashboard"
echo "  cks status - Check services"
echo ""
echo "You don't need to remember anything - it's all automatic!"
echo "═══════════════════════════════════════════════════"