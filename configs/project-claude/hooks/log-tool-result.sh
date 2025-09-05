#!/bin/bash
# CC Event Logger - Post Tool Use
# Logs tool execution results and outcomes

# Colors for console output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Read JSON input from stdin
input=$(cat)

# Extract key information
tool_name=$(echo "$input" | jq -r '.tool_name // "unknown"')
session_id=$(echo "$input" | jq -r '.session_id // "unknown"')
timestamp=$(date '+%Y-%m-%d %H:%M:%S')
log_file="/Users/MAC/Documents/projects/.claude/logs/cc-events-$(date '+%Y-%m-%d').log"

# Extract tool response details
tool_response=$(echo "$input" | jq -r '.tool_response // {}')
success_status=$(echo "$tool_response" | jq -r '.success // "unknown"')

# Determine result status
if [ "$success_status" = "true" ]; then
    result_status="${GREEN}✅ SUCCESS${NC}"
    result_code="SUCCESS"
elif [ "$success_status" = "false" ]; then
    result_status="${RED}❌ FAILED${NC}"
    result_code="FAILED"
else
    result_status="${YELLOW}⚠️  COMPLETED${NC}"
    result_code="COMPLETED"
fi

# Extract result details based on tool type
case "$tool_name" in
    "Bash")
        exit_code=$(echo "$tool_response" | jq -r '.exitCode // "unknown"')
        stdout_lines=$(echo "$tool_response" | jq -r '.stdout // ""' | wc -l)
        stderr_lines=$(echo "$tool_response" | jq -r '.stderr // ""' | wc -l)
        detail="Exit: $exit_code | Output: ${stdout_lines} lines | Errors: ${stderr_lines} lines"
        ;;
    "Read")
        lines_read=$(echo "$tool_response" | jq -r '.content // ""' | wc -l)
        detail="Lines read: $lines_read"
        ;;
    "Write"|"Edit"|"MultiEdit")
        file_path=$(echo "$tool_response" | jq -r '.filePath // "unknown"')
        detail="Modified: $file_path"
        ;;
    *)
        detail="Operation completed"
        ;;
esac

# Console output with colors
echo -e "${CYAN}╭─────────────────────────────────────────────────────────────╮${NC}"
echo -e "${CYAN}│${NC} ${PURPLE}📋 CLAUDE CODE EXECUTION RESULT${NC}                           ${CYAN}│${NC}"
echo -e "${CYAN}├─────────────────────────────────────────────────────────────┤${NC}"
echo -e "${CYAN}│${NC} ${YELLOW}Timestamp:${NC} $timestamp                              ${CYAN}│${NC}"
echo -e "${CYAN}│${NC} ${YELLOW}Tool:${NC}      $tool_name                                    ${CYAN}│${NC}"
echo -e "${CYAN}│${NC} ${YELLOW}Result:${NC}    $result_status                               ${CYAN}│${NC}"
echo -e "${CYAN}│${NC} ${YELLOW}Details:${NC}   $detail${NC}"
echo -e "${CYAN}╰─────────────────────────────────────────────────────────────╯${NC}"

# Structured log entry
log_entry=$(cat <<EOF
{
  "timestamp": "$timestamp",
  "session_id": "$session_id",
  "event": "PostToolUse",
  "tool_name": "$tool_name",
  "result_status": "$result_code",
  "details": "$detail",
  "success": "$success_status",
  "project_path": "/Users/MAC/Documents/projects"
}
EOF
)

# Write to log file
echo "$log_entry" >> "$log_file"

# Send to CLS for CKS integration
cls_payload=$(cat <<EOF
{
  "event_type": "cc_execution_result",
  "timestamp": "$timestamp",
  "session_id": "$session_id",
  "tool_name": "$tool_name",
  "result_status": "$result_code",
  "details": "$detail",
  "success": "$success_status",
  "source": "claude_code",
  "project": "caia",
  "project_path": "/Users/MAC/Documents/projects"
}
EOF
)

# Send to CLS (fire and forget - don't block CC execution)
curl -s -X POST "http://localhost:5003/events/cc-result" \
  -H "Content-Type: application/json" \
  -d "$cls_payload" > /dev/null 2>&1 &

echo -e "${GREEN}🧠 Result sent to CKS via CLS${NC}"

# Exit with success
exit 0