#!/bin/bash
# Post-Tool Use Hook - Runs after tool execution

LOG_FILE="$HOME/.claude/logs/tool-results.log"
mkdir -p "$(dirname "$LOG_FILE")"

# Get tool information (using both possible env var names)
TOOL_NAME="${CLAUDE_TOOL_NAME:-unknown}"
EXIT_CODE="${CLAUDE_TOOL_EXIT_CODE:-${CLAUDE_EXIT_CODE:-0}}"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Log tool result
echo "[$TIMESTAMP] POST-TOOL: $TOOL_NAME | Exit Code: $EXIT_CODE" >> "$LOG_FILE"

# Also log to /tmp for compatibility
echo "[$TIMESTAMP] Post-tool: $TOOL_NAME completed with status $EXIT_CODE" >> /tmp/cc-tool-usage.log

# Update metrics
METRICS_FILE="$HOME/.claude/logs/metrics.log"
echo "[$TIMESTAMP] METRIC: tool_use,$TOOL_NAME,$EXIT_CODE" >> "$METRICS_FILE"

# Track specific tool types in /tmp for compatibility
if [ "$TOOL_NAME" == "Bash" ]; then
    echo "[$TIMESTAMP] Bash command executed" >> /tmp/cc-metrics.log
elif [ "$TOOL_NAME" == "Write" ] || [ "$TOOL_NAME" == "Edit" ] || [ "$TOOL_NAME" == "MultiEdit" ]; then
    echo "[$TIMESTAMP] File modified" >> /tmp/cc-metrics.log
fi

# If code was successfully written/edited, update CKS
if [[ "$TOOL_NAME" =~ ^(Write|Edit|MultiEdit)$ ]] && [ "$EXIT_CODE" == "0" ]; then
    if curl -s http://localhost:5555/health >/dev/null 2>&1; then
        echo "  Updating CKS knowledge base..." >> "$LOG_FILE"
        RESPONSE=$(curl -s -X POST http://localhost:5555/update/knowledge \
             -H "Content-Type: application/json" \
             -d "{\"tool\":\"$TOOL_NAME\",\"result\":\"success\",\"timestamp\":\"$TIMESTAMP\"}" 2>&1)
        echo "  CKS Update: ${RESPONSE:0:100}" >> "$LOG_FILE"
    fi
fi

# Track error patterns
if [ "$EXIT_CODE" != "0" ]; then
    ERROR_LOG="$HOME/.claude/logs/errors.log"
    echo "[$TIMESTAMP] ERROR: Tool $TOOL_NAME failed with exit code $EXIT_CODE" >> "$ERROR_LOG"
fi

exit 0