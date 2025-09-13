#!/bin/bash

# ============================================================================
# REAL-TIME CKS/CLS TRAINING HOOK
# Captures EVERY CC interaction and trains the system automatically
# ============================================================================

# Configuration
TRAINER_URL="http://localhost:5004/train"
BUFFER_FILE="/tmp/cc_training_buffer.json"
LOG_FILE="/tmp/realtime_training.log"
SESSION_FILE="/tmp/cc_current_session.txt"

# Get or create session ID
if [ ! -f "$SESSION_FILE" ]; then
    echo "rt_$(date +%Y%m%d_%H%M%S)" > "$SESSION_FILE"
fi
SESSION_ID=$(cat "$SESSION_FILE")

# Function to log
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Capture interaction data
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
USER_PROMPT="${USER_PROMPT:-}"
ASSISTANT_RESPONSE="${ASSISTANT_RESPONSE:-}"
TOOLS_USED="${TOOLS_USED:-[]}"

# Skip if no data
if [ -z "$USER_PROMPT" ] && [ -z "$ASSISTANT_RESPONSE" ]; then
    exit 0
fi

# Create JSON payload
PAYLOAD=$(cat <<EOF
{
    "session_id": "$SESSION_ID",
    "timestamp": "$TIMESTAMP",
    "user_prompt": $(echo "$USER_PROMPT" | jq -Rs .),
    "assistant_response": $(echo "$ASSISTANT_RESPONSE" | jq -Rs .),
    "tools_used": $TOOLS_USED
}
EOF
)

# Send to trainer in background (non-blocking)
{
    # Try to send to trainer
    RESPONSE=$(curl -s -X POST "$TRAINER_URL" \
        -H "Content-Type: application/json" \
        -d "$PAYLOAD" \
        --max-time 2 \
        2>/dev/null)
    
    if [ $? -eq 0 ]; then
        log_message "✅ Trained on interaction (session: $SESSION_ID)"
    else
        # If trainer is down, save to buffer
        echo "$PAYLOAD" >> "$BUFFER_FILE"
        log_message "⚠️ Trainer offline, buffered interaction"
        
        # Try to start trainer if not running
        if ! curl -s "$TRAINER_URL/health" > /dev/null 2>&1; then
            cd /Users/MAC/Documents/projects/caia/knowledge-system
            python3 realtime_trainer.py > /tmp/realtime_trainer.out 2>&1 &
            log_message "🔄 Starting trainer service..."
        fi
    fi
} &

# Return immediately (don't block CC)
exit 0