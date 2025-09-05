#!/bin/bash
# CC Event Log Monitor
# Real-time monitoring of CC auto-approval events

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

log_dir="/Users/MAC/Documents/projects/.claude/logs"
today_log="$log_dir/cc-events-$(date '+%Y-%m-%d').log"

echo -e "${CYAN}🔍 CC Auto-Approval Event Monitor${NC}"
echo -e "${CYAN}=================================${NC}"
echo -e "${YELLOW}Log Directory:${NC} $log_dir"
echo -e "${YELLOW}Today's Log:${NC} $today_log"
echo -e ""

if [ ! -f "$today_log" ]; then
    echo -e "${YELLOW}No events logged today yet. Waiting for CC activity...${NC}"
    echo -e ""
fi

# Real-time monitoring
echo -e "${BLUE}📡 Starting real-time monitoring... (Ctrl+C to stop)${NC}"
echo -e ""

# Create log file if it doesn't exist
touch "$today_log"

# Monitor the log file for changes
tail -f "$today_log" | while read line; do
    if [[ -n "$line" ]]; then
        # Parse JSON and display formatted
        event=$(echo "$line" | jq -r '.event // "unknown"')
        tool=$(echo "$line" | jq -r '.tool_name // "unknown"')
        timestamp=$(echo "$line" | jq -r '.timestamp // "unknown"')
        
        if [[ "$event" == "PreToolUse" ]]; then
            status=$(echo "$line" | jq -r '.approval_status // "unknown"')
            echo -e "${GREEN}[${timestamp}]${NC} ${PURPLE}${event}${NC}: ${CYAN}${tool}${NC} → ${GREEN}${status}${NC}"
        elif [[ "$event" == "PostToolUse" ]]; then
            status=$(echo "$line" | jq -r '.result_status // "unknown"')
            echo -e "${BLUE}[${timestamp}]${NC} ${PURPLE}${event}${NC}: ${CYAN}${tool}${NC} → ${YELLOW}${status}${NC}"
        fi
    fi
done