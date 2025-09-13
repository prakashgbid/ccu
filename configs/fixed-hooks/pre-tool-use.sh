#!/bin/bash
# Pre-Tool Use Hook - Runs before any tool is executed

LOG_FILE="$HOME/.claude/logs/tool-usage.log"
mkdir -p "$(dirname "$LOG_FILE")"

# Get tool information from environment
TOOL_NAME="${CLAUDE_TOOL_NAME:-unknown}"
TOOL_PARAMS="${CLAUDE_TOOL_PARAMS:-}"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Log tool usage
echo "[$TIMESTAMP] PRE-TOOL: $TOOL_NAME" >> "$LOG_FILE"

# Log first 200 chars of params for debugging
if [ -n "$TOOL_PARAMS" ]; then
    echo "  Params: ${TOOL_PARAMS:0:200}" >> "$LOG_FILE"
fi

# Query CKS for code redundancy if writing/editing code
if [[ "$TOOL_NAME" =~ ^(Write|Edit|MultiEdit)$ ]]; then
    # Try to check with CKS if it's running
    if curl -s http://localhost:5555/health >/dev/null 2>&1; then
        echo "  Checking CKS for redundancy..." >> "$LOG_FILE"
        RESPONSE=$(curl -s -X POST http://localhost:5555/check/redundancy \
             -H "Content-Type: application/json" \
             -d "{\"action\":\"$TOOL_NAME\",\"params\":\"${TOOL_PARAMS:0:500}\"}" 2>&1)
        echo "  CKS Response: ${RESPONSE:0:100}" >> "$LOG_FILE"
    fi
fi

# Dangerous operation check
if [[ "$TOOL_PARAMS" == *"rm -rf"* ]] || [[ "$TOOL_PARAMS" == *"sudo rm"* ]]; then
    echo "  ⚠️ WARNING: Potentially dangerous operation detected" >> "$LOG_FILE"
    # Could block with exit 1, but for now just warn
fi

# Always allow execution
exit 0