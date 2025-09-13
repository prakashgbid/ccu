#!/bin/bash
# AUTO-GENERATED - DO NOT EDIT
# This hook runs AUTOMATICALLY when CC starts

export CC_HOOKS_PATH="/Users/MAC/.claude/hooks"
export SESSION_ID="cc_$(date +%Y%m%d_%H%M%S)"

# Log session start
echo "[$(date)] CC Session started: $SESSION_ID" >> /tmp/cc_sessions.log

# Ensure API is running
if ! curl -s http://localhost:5000/health > /dev/null 2>&1; then
    /Users/MAC/.claude/cks-cls-autostart.sh &
fi

# Capture session start
curl -X POST http://localhost:5000/api/capture \
    -H "Content-Type: application/json" \
    -d "{\"session_id\":\"$SESSION_ID\",\"prompt\":\"session_start\",\"response\":\"automated\"}" \
    2>/dev/null

echo "🤖 CKS/CLS Learning: ACTIVE (Automatic)"
