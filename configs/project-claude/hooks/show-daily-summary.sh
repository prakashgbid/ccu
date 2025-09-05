#!/bin/bash
# CC Daily Summary Report
# Shows summary of all auto-approval events for today

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

log_file="/Users/MAC/Documents/projects/.claude/logs/cc-events-$(date '+%Y-%m-%d').log"

echo -e "${CYAN}📊 Claude Code Auto-Approval Daily Summary${NC}"
echo -e "${CYAN}===========================================${NC}"
echo -e "${YELLOW}Date:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
echo -e "${YELLOW}Log File:${NC} $log_file"
echo -e ""

if [ ! -f "$log_file" ]; then
    echo -e "${RED}❌ No events logged today.${NC}"
    echo -e ""
    echo -e "${BLUE}💡 Events will appear here once CC starts executing tools in this project.${NC}"
    exit 0
fi

# Count events by type
pre_tool_events=$(grep '"event": "PreToolUse"' "$log_file" | wc -l | xargs)
post_tool_events=$(grep '"event": "PostToolUse"' "$log_file" | wc -l | xargs)
total_events=$((pre_tool_events + post_tool_events))

echo -e "${GREEN}✅ Total Events:${NC} $total_events"
echo -e "${BLUE}   • Tool Usage Events:${NC} $pre_tool_events"
echo -e "${BLUE}   • Completion Events:${NC} $post_tool_events"
echo -e ""

# Count by tool type
echo -e "${PURPLE}🔧 Tools Used:${NC}"
tools_used=$(grep '"tool_name"' "$log_file" | sed 's/.*"tool_name": *"\([^"]*\)".*/\1/' | sort | uniq -c | sort -nr)
if [ -n "$tools_used" ]; then
    echo "$tools_used" | while read count tool; do
        echo -e "${CYAN}   • $tool:${NC} $count times"
    done
else
    echo -e "${YELLOW}   No tools executed yet${NC}"
fi
echo -e ""

# Count successes and failures
successes=$(grep '"result_status": "SUCCESS"' "$log_file" | wc -l | xargs)
failures=$(grep '"result_status": "FAILED"' "$log_file" | wc -l | xargs)
completed=$(grep '"result_status": "COMPLETED"' "$log_file" | wc -l | xargs)

echo -e "${GREEN}📈 Execution Results:${NC}"
echo -e "${GREEN}   • Successful:${NC} $successes"
echo -e "${YELLOW}   • Completed:${NC} $completed"
echo -e "${RED}   • Failed:${NC} $failures"
echo -e ""

# Show recent events
echo -e "${BLUE}📋 Last 5 Events:${NC}"
tail -n 5 "$log_file" | while read line; do
    if [[ -n "$line" ]]; then
        timestamp=$(echo "$line" | jq -r '.timestamp // "unknown"')
        event=$(echo "$line" | jq -r '.event // "unknown"')
        tool=$(echo "$line" | jq -r '.tool_name // "unknown"')
        
        if [[ "$event" == "PreToolUse" ]]; then
            status=$(echo "$line" | jq -r '.approval_status // "unknown"')
            echo -e "${CYAN}   [$timestamp]${NC} $tool → ${GREEN}$status${NC}"
        elif [[ "$event" == "PostToolUse" ]]; then
            status=$(echo "$line" | jq -r '.result_status // "unknown"')
            case "$status" in
                "SUCCESS") color="${GREEN}" ;;
                "FAILED") color="${RED}" ;;
                *) color="${YELLOW}" ;;
            esac
            echo -e "${CYAN}   [$timestamp]${NC} $tool → ${color}$status${NC}"
        fi
    fi
done

echo -e ""
echo -e "${BLUE}💡 Commands:${NC}"
echo -e "${CYAN}   • Monitor real-time:${NC} ./.claude/hooks/monitor-logs.sh"
echo -e "${CYAN}   • View raw logs:${NC} cat $log_file"
echo -e "${CYAN}   • View today's summary:${NC} ./.claude/hooks/show-daily-summary.sh"