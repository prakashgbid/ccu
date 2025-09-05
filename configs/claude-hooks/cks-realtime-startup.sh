#!/bin/bash

# CKS Real-Time Updater Auto-Start Hook for Claude Code

# Colors for output
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧠 CKS Real-Time Updater Check...${NC}"

# Check if real-time updater is running
if pgrep -f "real-time-updater.py" > /dev/null; then
    echo -e "   ${GREEN}✅ Real-time updater already running${NC}"
else
    echo -e "   ${YELLOW}Starting real-time updater...${NC}"
    
    # Start using the control script
    /Users/MAC/Documents/projects/caia/knowledge-system/scripts/cks-realtime-control.sh start > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo -e "   ${GREEN}✅ Real-time updater started${NC}"
    else
        # Fallback: Start directly in background
        nohup python3 /Users/MAC/Documents/projects/caia/knowledge-system/real-time-updater.py > /dev/null 2>&1 &
        echo -e "   ${GREEN}✅ Real-time updater started (direct)${NC}"
    fi
fi

# Trigger initial update if CKS hasn't been updated recently
LAST_UPDATE_FILE="/Users/MAC/Documents/projects/caia/knowledge-system/data/.last_update"
CURRENT_TIME=$(date +%s)

if [ -f "$LAST_UPDATE_FILE" ]; then
    LAST_UPDATE=$(cat "$LAST_UPDATE_FILE")
    TIME_DIFF=$((CURRENT_TIME - LAST_UPDATE))
    
    # If more than 1 hour since last update
    if [ $TIME_DIFF -gt 3600 ]; then
        echo -e "   ${YELLOW}Triggering CKS update (last: $((TIME_DIFF / 3600))h ago)...${NC}"
        /Users/MAC/Documents/projects/caia/knowledge-system/scripts/cks-realtime-control.sh update > /dev/null 2>&1 &
    fi
else
    echo -e "   ${YELLOW}Triggering initial CKS update...${NC}"
    /Users/MAC/Documents/projects/caia/knowledge-system/scripts/cks-realtime-control.sh update > /dev/null 2>&1 &
fi

# Update timestamp
echo "$CURRENT_TIME" > "$LAST_UPDATE_FILE"

echo -e "   ${GREEN}✅ CKS Real-time monitoring active${NC}"