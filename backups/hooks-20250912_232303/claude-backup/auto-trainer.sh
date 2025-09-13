#!/bin/bash

# ============================================================================
# AUTOMATIC TRAINING SYSTEM
# Captures and trains on CC interactions automatically
# ============================================================================

LOG_DIR="/Users/MAC/.claude/cc_interaction_logs"
SESSION_FILE="/tmp/cc_current_session.txt"
LAST_PROMPT_FILE="/tmp/last_user_prompt.txt"
LAST_RESPONSE_FILE="/tmp/last_cc_response.txt"

# Create log directory
mkdir -p "$LOG_DIR"

# Function to auto-capture from various sources
auto_capture() {
    local TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local SESSION_ID=$(cat "$SESSION_FILE" 2>/dev/null || echo "auto_$(date +%Y%m%d_%H%M%S)")
    
    # Try to get last interaction from different sources
    local PROMPT=""
    local RESPONSE=""
    
    # 1. Check if we have stored prompt/response
    if [ -f "$LAST_PROMPT_FILE" ]; then
        PROMPT=$(cat "$LAST_PROMPT_FILE" | head -100)
    fi
    
    if [ -f "$LAST_RESPONSE_FILE" ]; then
        RESPONSE=$(cat "$LAST_RESPONSE_FILE" | head -100)
    fi
    
    # 2. Try to extract from CC logs if they exist
    if [ -z "$PROMPT" ]; then
        # Check various log locations
        for log in /tmp/claude*.log /tmp/cc*.log ~/.claude/logs/*.log; do
            if [ -f "$log" ]; then
                # Extract last user input (this is approximate)
                PROMPT=$(grep -i "user\|prompt\|request" "$log" 2>/dev/null | tail -1 | cut -c1-100)
                break
            fi
        done
    fi
    
    # 3. If we have something to log, save it
    if [ -n "$PROMPT" ] || [ -n "$RESPONSE" ]; then
        # Quick training via API
        python3 /Users/MAC/Documents/projects/caia/knowledge-system/log_interaction.py quick \
            "${PROMPT:-auto-captured}" \
            "${RESPONSE:-auto-captured}" \
            "auto" 2>/dev/null
            
        # Clear the files
        rm -f "$LAST_PROMPT_FILE" "$LAST_RESPONSE_FILE"
        
        return 0
    fi
    
    return 1
}

# Function to show stats periodically
show_stats() {
    local STATS=$(curl -s http://localhost:5004/stats 2>/dev/null)
    if [ -n "$STATS" ]; then
        local INTERACTIONS=$(echo "$STATS" | jq -r '.total_interactions // 0')
        local PATTERNS=$(echo "$STATS" | jq -r '.total_patterns // 0')
        echo "[CKS/CLS] 📊 Learning Stats: $INTERACTIONS interactions, $PATTERNS patterns"
    fi
}

# Main auto-training loop
main() {
    # Run in background
    while true; do
        # Try to auto-capture every 30 seconds
        auto_capture
        
        # Show stats every 5 minutes
        if [ $(($(date +%s) % 300)) -lt 30 ]; then
            show_stats >> /tmp/cks_stats.log
        fi
        
        sleep 30
    done &
    
    echo "✅ Auto-trainer started (PID: $!)"
}

# Start if not already running
if ! pgrep -f "auto-trainer.sh" > /dev/null; then
    main
fi