#!/bin/bash
# CC Auto-Approval Setup Verification Script

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🔍 Claude Code Auto-Approval Setup Verification${NC}"
echo -e "${CYAN}===============================================${NC}"
echo -e ""

# Check project directory
echo -e "${BLUE}📁 Project Directory:${NC}"
echo -e "   Location: $(pwd)"
echo -e ""

# Check settings.json
echo -e "${BLUE}⚙️  Configuration Files:${NC}"
if [ -f ".claude/settings.json" ]; then
    echo -e "${GREEN}   ✅ .claude/settings.json exists${NC}"
    
    # Check permissions
    if grep -q '"allowedTools"' .claude/settings.json; then
        echo -e "${GREEN}   ✅ Auto-approval permissions configured${NC}"
    else
        echo -e "${RED}   ❌ Auto-approval permissions not found${NC}"
    fi
    
    # Check hooks
    if grep -q '"hooks"' .claude/settings.json; then
        echo -e "${GREEN}   ✅ Event logging hooks configured${NC}"
    else
        echo -e "${RED}   ❌ Event logging hooks not found${NC}"
    fi
else
    echo -e "${RED}   ❌ .claude/settings.json not found${NC}"
fi
echo -e ""

# Check hook scripts
echo -e "${BLUE}🪝 Hook Scripts:${NC}"
hooks_dir=".claude/hooks"
if [ -d "$hooks_dir" ]; then
    echo -e "${GREEN}   ✅ Hooks directory exists${NC}"
    
    for script in "log-tool-usage.sh" "log-tool-result.sh" "monitor-logs.sh" "show-daily-summary.sh"; do
        if [ -f "$hooks_dir/$script" ]; then
            if [ -x "$hooks_dir/$script" ]; then
                echo -e "${GREEN}   ✅ $script (executable)${NC}"
            else
                echo -e "${YELLOW}   ⚠️  $script (not executable)${NC}"
            fi
        else
            echo -e "${RED}   ❌ $script missing${NC}"
        fi
    done
else
    echo -e "${RED}   ❌ Hooks directory not found${NC}"
fi
echo -e ""

# Check logs directory
echo -e "${BLUE}📋 Logging Setup:${NC}"
logs_dir=".claude/logs"
if [ -d "$logs_dir" ]; then
    echo -e "${GREEN}   ✅ Logs directory exists${NC}"
    
    today_log="$logs_dir/cc-events-$(date '+%Y-%m-%d').log"
    if [ -f "$today_log" ]; then
        events_count=$(wc -l < "$today_log" 2>/dev/null || echo "0")
        echo -e "${GREEN}   ✅ Today's log file exists ($events_count events)${NC}"
    else
        echo -e "${YELLOW}   ⚠️  No events logged today yet${NC}"
    fi
else
    echo -e "${RED}   ❌ Logs directory not found${NC}"
fi
echo -e ""

# Check test script
echo -e "${BLUE}🧪 Test Scripts:${NC}"
if [ -f "test-auto-approval.sh" ]; then
    if [ -x "test-auto-approval.sh" ]; then
        echo -e "${GREEN}   ✅ test-auto-approval.sh (ready to run)${NC}"
    else
        echo -e "${YELLOW}   ⚠️  test-auto-approval.sh (not executable)${NC}"
    fi
else
    echo -e "${RED}   ❌ test-auto-approval.sh not found${NC}"
fi
echo -e ""

# Environment check
echo -e "${BLUE}🌍 Environment Variables:${NC}"
env_vars=("CLAUDE_AUTO_APPROVE" "CLAUDE_NO_CONFIRM" "CLAUDE_BATCH_MODE" "CC_LOG_DECISIONS")
for var in "${env_vars[@]}"; do
    if [ -n "${!var}" ]; then
        echo -e "${GREEN}   ✅ $var=${!var}${NC}"
    else
        echo -e "${YELLOW}   ⚠️  $var not set (will be set by CC)${NC}"
    fi
done
echo -e ""

# Dependencies check
echo -e "${BLUE}🔧 Dependencies:${NC}"
if command -v jq &> /dev/null; then
    echo -e "${GREEN}   ✅ jq (JSON processor) available${NC}"
else
    echo -e "${RED}   ❌ jq not found (required for log parsing)${NC}"
fi
echo -e ""

# Quick commands
echo -e "${PURPLE}🚀 Quick Commands:${NC}"
echo -e "${CYAN}   • Test auto-approval:${NC} ./test-auto-approval.sh"
echo -e "${CYAN}   • Monitor real-time:${NC} ./.claude/hooks/monitor-logs.sh"
echo -e "${CYAN}   • View daily summary:${NC} ./.claude/hooks/show-daily-summary.sh"
echo -e "${CYAN}   • Verify setup again:${NC} ./.claude/verify-setup.sh"
echo -e ""

echo -e "${GREEN}✨ Setup verification complete!${NC}"