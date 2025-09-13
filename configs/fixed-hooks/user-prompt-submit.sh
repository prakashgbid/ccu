#!/bin/bash
# User Prompt Submit Hook - Captures and enhances user prompts

LOG_FILE="$HOME/.claude/logs/prompts.log"
mkdir -p "$(dirname "$LOG_FILE")"

# Get prompt from environment
USER_PROMPT="${CLAUDE_USER_PROMPT:-}"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Log the prompt
echo "[$TIMESTAMP] PROMPT: ${USER_PROMPT:0:500}" >> "$LOG_FILE"

# Also log to /tmp for compatibility
echo "[$TIMESTAMP] USER PROMPT: ${USER_PROMPT:0:200}" >> /tmp/cc-prompts.log

# Send to learning system if available
if curl -s http://localhost:5003/health >/dev/null 2>&1; then
    curl -s -X POST http://localhost:5003/capture/prompt \
         -H "Content-Type: application/json" \
         -d "{\"prompt\":\"${USER_PROMPT:0:1000}\",\"timestamp\":\"$TIMESTAMP\"}" \
         >> "$LOG_FILE" 2>&1
fi

# Check for specific keywords and provide context
if [[ "$USER_PROMPT" == *"test"* ]]; then
    cat << EOF
{
  "decision": "allow",
  "context": "Remember to run tests after implementation. Check package.json for test scripts.",
  "notification": "Test mode detected"
}
EOF
elif [[ "$USER_PROMPT" == *"hook"* ]]; then
    cat << EOF
{
  "decision": "allow",
  "context": "Hook system is now properly configured. Logs are in ~/.claude/logs/",
  "notification": "Hook-related query detected"
}
EOF
elif curl -s http://localhost:5555/health >/dev/null 2>&1; then
    # Query CKS for context if available and no specific keyword matched
    CONTEXT=$(curl -s http://localhost:5555/context/get 2>/dev/null)
    if [ -n "$CONTEXT" ] && [ "$CONTEXT" != "null" ]; then
        echo "{\"decision\":\"allow\",\"context\":$CONTEXT}"
    else
        echo "{\"decision\":\"allow\"}"
    fi
else
    # Default: allow without modification
    echo "{\"decision\":\"allow\"}"
fi

exit 0