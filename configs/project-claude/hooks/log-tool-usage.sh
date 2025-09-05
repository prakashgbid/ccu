#!/bin/bash
# CC Event Logger - Pre Tool Use
# Logs all tool usage attempts with auto-approval decisions

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

# Extract tool-specific details
case "$tool_name" in
    "Bash")
        command=$(echo "$input" | jq -r '.tool_input.command // "unknown"')
        description=$(echo "$input" | jq -r '.tool_input.description // "no description"')
        detail="Command: $command | Description: $description"
        ;;
    "Read")
        file_path=$(echo "$input" | jq -r '.tool_input.file_path // "unknown"')
        detail="File: $file_path"
        ;;
    "Write"|"Edit"|"MultiEdit")
        file_path=$(echo "$input" | jq -r '.tool_input.file_path // "unknown"')
        detail="File: $file_path"
        ;;
    "Glob")
        pattern=$(echo "$input" | jq -r '.tool_input.pattern // "unknown"')
        path=$(echo "$input" | jq -r '.tool_input.path // "current dir"')
        detail="Pattern: $pattern in $path"
        ;;
    "Grep")
        pattern=$(echo "$input" | jq -r '.tool_input.pattern // "unknown"')
        detail="Search: $pattern"
        ;;
    *)
        detail="Tool-specific parameters available"
        ;;
esac

# Determine approval status
approval_status="AUTO-APPROVED"
approval_reason="Project folder permissions configured for autonomous operation"

# Console output with colors
echo -e "${CYAN}╭─────────────────────────────────────────────────────────────╮${NC}"
echo -e "${CYAN}│${NC} ${PURPLE}🤖 CLAUDE CODE AUTO-APPROVAL EVENT${NC}                        ${CYAN}│${NC}"
echo -e "${CYAN}├─────────────────────────────────────────────────────────────┤${NC}"
echo -e "${CYAN}│${NC} ${YELLOW}Timestamp:${NC} $timestamp                              ${CYAN}│${NC}"
echo -e "${CYAN}│${NC} ${YELLOW}Tool:${NC}      $tool_name                                    ${CYAN}│${NC}"
echo -e "${CYAN}│${NC} ${YELLOW}Status:${NC}    ${GREEN}$approval_status${NC}                           ${CYAN}│${NC}"
echo -e "${CYAN}│${NC} ${YELLOW}Reason:${NC}    $approval_reason          ${CYAN}│${NC}"
echo -e "${CYAN}│${NC} ${YELLOW}Details:${NC}   $detail${NC}"
echo -e "${CYAN}╰─────────────────────────────────────────────────────────────╯${NC}"

# Structured log entry
log_entry=$(cat <<EOF
{
  "timestamp": "$timestamp",
  "session_id": "$session_id",
  "event": "PreToolUse",
  "tool_name": "$tool_name",
  "approval_status": "$approval_status",
  "approval_reason": "$approval_reason",
  "details": "$detail",
  "auto_approved": true,
  "project_path": "/Users/MAC/Documents/projects"
}
EOF
)

# Write to log file
echo "$log_entry" >> "$log_file"

# Send to CLS for CKS integration
cls_payload=$(cat <<EOF
{
  "event_type": "cc_auto_approval",
  "timestamp": "$timestamp",
  "session_id": "$session_id",
  "tool_name": "$tool_name",
  "approval_status": "$approval_status",
  "approval_reason": "$approval_reason",
  "details": "$detail",
  "source": "claude_code",
  "project": "caia",
  "auto_approved": true,
  "project_path": "/Users/MAC/Documents/projects"
}
EOF
)

# Send to CLS (fire and forget - don't block CC execution)
curl -s -X POST "http://localhost:5003/events/cc-approval" \
  -H "Content-Type: application/json" \
  -d "$cls_payload" > /dev/null 2>&1 &

# Create a summary for real-time monitoring
echo -e "${BLUE}📝 Event logged to: $log_file${NC}"
echo -e "${GREEN}🧠 Event sent to CKS via CLS${NC}"

# Exit with success (approve the tool use)
exit 0