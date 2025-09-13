#!/bin/bash

# ============================================================================
# CC RESPONSE LOGGER
# Logs all CC interactions to a file for later training
# ============================================================================

# Configuration
LOG_DIR="/Users/MAC/.claude/cc_interaction_logs"
LOG_FILE="$LOG_DIR/interactions_$(date +%Y%m%d).jsonl"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Function to escape JSON strings
json_escape() {
    echo "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\n/\\n/g; s/\r/\\r/g; s/\t/\\t/g'
}

# Capture whatever information CC provides
# These might be empty if CC doesn't set them
USER_PROMPT="${USER_PROMPT:-}"
ASSISTANT_RESPONSE="${ASSISTANT_RESPONSE:-}"
TOOL_NAME="${TOOL_NAME:-}"
FILE_PATH="${FILE_PATH:-}"
COMMAND="${COMMAND:-}"
OUTPUT="${OUTPUT:-}"
SESSION_ID="${SESSION_ID:-cc_$(date +%Y%m%d_%H%M%S)}"

# Try to capture from various possible sources
if [ -n "$1" ]; then
    HOOK_ARG1="$1"
fi
if [ -n "$2" ]; then
    HOOK_ARG2="$2"
fi

# Log whatever we can capture
if [ -n "$USER_PROMPT" ] || [ -n "$ASSISTANT_RESPONSE" ] || [ -n "$TOOL_NAME" ] || [ -n "$FILE_PATH" ] || [ -n "$COMMAND" ] || [ -n "$HOOK_ARG1" ]; then
    # Create JSON log entry
    cat >> "$LOG_FILE" << EOF
{"timestamp":"$TIMESTAMP","session_id":"$SESSION_ID","user_prompt":"$(json_escape "$USER_PROMPT")","assistant_response":"$(json_escape "$ASSISTANT_RESPONSE")","tool_name":"$(json_escape "$TOOL_NAME")","file_path":"$(json_escape "$FILE_PATH")","command":"$(json_escape "$COMMAND")","output":"$(json_escape "$OUTPUT")","hook_arg1":"$(json_escape "$HOOK_ARG1")","hook_arg2":"$(json_escape "$HOOK_ARG2")"}
EOF
fi

# Also try to capture from CC's own logs if they exist
CC_LOG_PATTERNS=(
    "/tmp/claude_code*.log"
    "/tmp/cc_*.log"
    "~/.claude/logs/*.log"
    "/var/log/claude*.log"
)

for pattern in "${CC_LOG_PATTERNS[@]}"; do
    for logfile in $pattern; do
        if [ -f "$logfile" ]; then
            # Mark that we found a CC log
            echo "{\"timestamp\":\"$TIMESTAMP\",\"log_found\":\"$logfile\"}" >> "$LOG_FILE"
            break 2
        fi
    done
done

# Return immediately (non-blocking)
exit 0