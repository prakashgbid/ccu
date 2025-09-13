#!/bin/bash
# Hook System Test Suite

echo "🧪 Claude Code Hook System Test Suite"
echo "====================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0

# Test function
test_item() {
    local test_name="$1"
    local test_cmd="$2"
    
    echo -n "Testing $test_name: "
    if eval "$test_cmd" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ PASS${NC}"
        ((PASS++))
    else
        echo -e "${RED}❌ FAIL${NC}"
        ((FAIL++))
    fi
}

# 1. Test hook files exist and are executable
echo "1. Hook File Tests"
echo "-------------------"
test_item "session-start.sh exists" "[ -x ~/.config/claude/hooks/session-start.sh ]"
test_item "pre-tool-use.sh exists" "[ -x ~/.config/claude/hooks/pre-tool-use.sh ]"
test_item "post-tool-use.sh exists" "[ -x ~/.config/claude/hooks/post-tool-use.sh ]"
test_item "user-prompt-submit.sh exists" "[ -x ~/.config/claude/hooks/user-prompt-submit.sh ]"
echo ""

# 2. Test service connectivity
echo "2. Service Tests"
echo "----------------"
test_item "CKS health check" "curl -s http://localhost:5555/health"
test_item "Enhancement health check" "curl -s http://localhost:5002/health"
test_item "Service manager exists" "[ -x ~/.claude/services/service-manager.sh ]"
echo ""

# 3. Test hook execution
echo "3. Hook Execution Tests"
echo "-----------------------"
# Clear logs first
rm -f ~/.claude/logs/test-*.log

# Test pre-tool hook
CLAUDE_TOOL_NAME="TestTool" CLAUDE_TOOL_PARAMS="test params" \
    bash ~/.config/claude/hooks/pre-tool-use.sh
test_item "pre-tool-use creates log" "[ -s ~/.claude/logs/tool-usage.log ]"

# Test post-tool hook
CLAUDE_TOOL_NAME="TestTool" CLAUDE_TOOL_EXIT_CODE="0" \
    bash ~/.config/claude/hooks/post-tool-use.sh
test_item "post-tool-use creates log" "[ -s ~/.claude/logs/tool-results.log ]"

# Test user prompt hook
CLAUDE_USER_PROMPT="test prompt" \
    bash ~/.config/claude/hooks/user-prompt-submit.sh > /dev/null
test_item "user-prompt-submit creates log" "[ -s ~/.claude/logs/prompts.log ]"
echo ""

# 4. Test settings.json configuration
echo "4. Configuration Tests"
echo "----------------------"
test_item "settings.json exists" "[ -f ~/.claude/settings.json ]"
test_item "SessionStart hook configured" "grep -q 'SessionStart' ~/.claude/settings.json"
test_item "PreToolUse hook configured" "grep -q 'PreToolUse' ~/.claude/settings.json"
test_item "PostToolUse hook configured" "grep -q 'PostToolUse' ~/.claude/settings.json"
test_item "UserPromptSubmit configured" "grep -q 'UserPromptSubmit' ~/.claude/settings.json"
echo ""

# 5. Test log directories
echo "5. Log Directory Tests"
echo "----------------------"
test_item "~/.claude/logs exists" "[ -d ~/.claude/logs ]"
test_item "Logs are being written" "[ $(find ~/.claude/logs -type f -name '*.log' | wc -l) -gt 0 ]"
echo ""

# 6. Test cleanup of old systems
echo "6. Cleanup Verification"
echo "-----------------------"
test_item "Old hooks archived" "[ -d ~/.claude/archived-hooks-* ]"
test_item "Project hooks removed" "! [ -d /Users/MAC/Documents/projects/.claude/hooks ]"
test_item "Old configs archived" "! [ -f ~/.claude/hooks.json ]"
echo ""

# Summary
echo "====================================="
echo "Test Results Summary"
echo "====================================="
echo -e "Passed: ${GREEN}$PASS${NC}"
echo -e "Failed: ${RED}$FAIL${NC}"

if [ $FAIL -eq 0 ]; then
    echo -e "\n${GREEN}🎉 All tests passed! Hook system is working correctly.${NC}"
    exit 0
else
    echo -e "\n${RED}⚠️  Some tests failed. Please review the configuration.${NC}"
    exit 1
fi