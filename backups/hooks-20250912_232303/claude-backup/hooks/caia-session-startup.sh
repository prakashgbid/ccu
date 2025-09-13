#!/bin/bash

# CKS Session Startup Hook
# Ensures CKS is fully operational when CC starts

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧠 CKS Integration Starting...${NC}"
echo "================================"

# 1. Check and start CKS API Bridge
if ! curl -s http://localhost:5555/health > /dev/null 2>&1; then
    echo -e "${YELLOW}Starting CKS API Bridge...${NC}"
    cd /Users/MAC/Documents/projects/caia/knowledge-system
    nohup python3 cks-api-bridge.py > /tmp/cks-api.log 2>&1 &
    sleep 2
    
    if curl -s http://localhost:5555/health > /dev/null 2>&1; then
        echo -e "  ${GREEN}✅ CKS API Bridge started${NC}"
    else
        echo -e "  ${RED}❌ Failed to start CKS API${NC}"
    fi
else
    echo -e "  ${GREEN}✅ CKS API Bridge already running${NC}"
fi

# 2. Check CKS database stats
STATS=$(curl -s http://localhost:5555/stats 2>/dev/null)
if [ ! -z "$STATS" ]; then
    FILES=$(echo "$STATS" | grep -o '"total_files":[0-9]*' | cut -d: -f2)
    FUNCTIONS=$(echo "$STATS" | grep -o '"total_functions":[0-9]*' | cut -d: -f2)
    CLASSES=$(echo "$STATS" | grep -o '"total_classes":[0-9]*' | cut -d: -f2)
    
    echo -e "${BLUE}📊 CKS Database Status:${NC}"
    echo -e "  Files: ${GREEN}$FILES${NC}"
    echo -e "  Functions: ${GREEN}$FUNCTIONS${NC}"
    echo -e "  Classes: ${GREEN}$CLASSES${NC}"
fi

# 3. Check real-time updater
if pgrep -f "real-time-updater.py" > /dev/null; then
    echo -e "  ${GREEN}✅ Real-time updater running${NC}"
else
    echo -e "${YELLOW}Starting real-time updater...${NC}"
    cd /Users/MAC/Documents/projects/caia/knowledge-system
    nohup python3 real-time-updater.py > /dev/null 2>&1 &
    echo -e "  ${GREEN}✅ Real-time updater started${NC}"
fi

# 4. Test CKS search functionality
TEST_RESULT=$(curl -s -X POST http://localhost:5555/search/function \
    -H "Content-Type: application/json" \
    -d '{"query": "init", "limit": 1}' 2>/dev/null)

if echo "$TEST_RESULT" | grep -q '"results"'; then
    echo -e "  ${GREEN}✅ CKS search functional${NC}"
else
    echo -e "  ${YELLOW}⚠️  CKS search may need reindexing${NC}"
fi

# 5. Enable enforcement
if [ ! -f /Users/MAC/.claude/cks-integration/.enforcement_enabled ]; then
    touch /Users/MAC/.claude/cks-integration/.enforcement_enabled
    echo -e "  ${GREEN}✅ CKS enforcement enabled${NC}"
else
    echo -e "  ${GREEN}✅ CKS enforcement already enabled${NC}"
fi

# 6. Export environment variables
export CKS_API_URL="http://localhost:5555"
export CKS_ENFORCEMENT=MANDATORY
export CKS_DB="/Users/MAC/Documents/projects/caia/knowledge-system/data/caia_knowledge.db"

echo "================================"
echo -e "${GREEN}✅ CKS Integration Active!${NC}"
echo -e "${BLUE}CC will now check CKS before any code generation${NC}"
echo ""
echo -e "${YELLOW}Quick Commands:${NC}"
echo "  Search: curl -X POST http://localhost:5555/search/function -d '{\"query\":\"name\"}'"
echo "  Stats:  curl http://localhost:5555/stats"
echo "  Check:  python3 /Users/MAC/.claude/cks-integration/cc-enforcement.py stats"