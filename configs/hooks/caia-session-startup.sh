#!/bin/bash
# Dynamic session startup hook with real-time status reporting

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
DIM='\033[2m'
NC='\033[0m'

ADMIN_DIR="/Users/MAC/Documents/projects/admin"
SCRIPT_DIR="$ADMIN_DIR/scripts"
PROJECTS_DIR="/Users/MAC/Documents/projects"

echo -e "${BLUE}🚀 Session Starting...${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Start CKS if not running
echo -e "${YELLOW}🧠 CAIA Knowledge System:${NC}"
if ! curl -s http://localhost:5000/health >/dev/null 2>&1; then
    echo -e "   Status: ${YELLOW}Starting CKS...${NC}"
    # Start CKS in background using simple script
    nohup /Users/MAC/Documents/projects/caia/knowledge-system/scripts/start_cks_simple.sh >/tmp/cks_startup.log 2>&1 &
    CKS_PID=$!
    
    # Wait up to 10 seconds for CKS to start
    for i in {1..10}; do
        if curl -s http://localhost:5000/health >/dev/null 2>&1; then
            echo -e "   Status: ${GREEN}CKS Started Successfully${NC} ${DIM}(PID: $CKS_PID)${NC}"
            break
        fi
        sleep 1
        if [ $i -eq 10 ]; then
            echo -e "   Status: ${RED}CKS Failed to Start${NC} ${DIM}(check /tmp/cks_startup.log)${NC}"
        fi
    done
else
    CKS_PID=$(lsof -ti:5000 2>/dev/null)
    echo -e "   Status: ${GREEN}Already Running${NC} ${DIM}(PID: $CKS_PID)${NC}"
fi

# Real-time system health check
echo -e "${YELLOW}📊 System Status:${NC}"

# Check context daemon
if pgrep -f "capture_context.py --daemon" > /dev/null 2>&1; then
    PID=$(pgrep -f "capture_context.py --daemon")
    UPTIME=$(ps -o etime= -p $PID 2>/dev/null | xargs)
    echo -e "   Context Daemon: ${GREEN}Running${NC} ${DIM}(uptime: $UPTIME)${NC}"
else
    echo -e "   Context Daemon: ${RED}Stopped${NC}"
fi

# Count real projects (directories with .git)
PROJECT_COUNT=$(find "$PROJECTS_DIR" -maxdepth 2 -name ".git" -type d 2>/dev/null | wc -l)
ACTIVE_COUNT=$(find "$PROJECTS_DIR" -maxdepth 2 -name ".git" -type d -mtime -7 2>/dev/null | wc -l)

# Get recent git activity
RECENT_COMMITS=$(find "$PROJECTS_DIR" -maxdepth 3 -name ".git" -type d -execdir git log --since="24 hours ago" --oneline 2>/dev/null \; | wc -l)

# Count actual TODOs in code
TODO_COUNT=$(rg "TODO|FIXME" "$PROJECTS_DIR" --type-add 'code:*.{js,ts,py,sh}' -t code -c 2>/dev/null | wc -l)

echo -e "   Projects: ${GREEN}$PROJECT_COUNT${NC} total, ${GREEN}$ACTIVE_COUNT${NC} active"
echo -e "   Recent commits (24h): ${GREEN}$RECENT_COMMITS${NC}"
echo -e "   Open TODOs: ${YELLOW}$TODO_COUNT${NC} files with tasks"

# Show actual active projects (modified in last 7 days)
echo ""
echo -e "${YELLOW}🔥 Active Projects:${NC}"
for dir in "$PROJECTS_DIR"/*; do
    if [ -d "$dir/.git" ] && [ $(find "$dir" -type f -mtime -7 2>/dev/null | wc -l) -gt 0 ]; then
        PROJECT_NAME=$(basename "$dir")
        LAST_COMMIT=$(cd "$dir" && git log -1 --format="%ar" 2>/dev/null || echo "no commits")
        FILE_COUNT=$(find "$dir" -type f -name "*.js" -o -name "*.ts" -o -name "*.py" 2>/dev/null | wc -l)
        echo -e "   • $PROJECT_NAME ${DIM}($FILE_COUNT files, last: $LAST_COMMIT)${NC}"
    fi
done | head -5

# Check for recent decisions
echo ""
echo -e "${YELLOW}💭 Recent Activity:${NC}"
DECISION_COUNT=0
if [ -d "$ADMIN_DIR/decisions" ]; then
    DECISION_COUNT=$(find "$ADMIN_DIR/decisions" -name "*.json" -mtime -1 2>/dev/null | wc -l)
fi

if [ $DECISION_COUNT -gt 0 ]; then
    echo -e "   ${GREEN}$DECISION_COUNT${NC} decisions logged today"
    # Show last decision title
    LAST_DECISION=$(ls -t "$ADMIN_DIR/decisions"/*.json 2>/dev/null | head -1)
    if [ -f "$LAST_DECISION" ]; then
        TITLE=$(python3 -c "import json; print(json.load(open('$LAST_DECISION'))['title'][:50])" 2>/dev/null || echo "")
        [ -n "$TITLE" ] && echo -e "   Last: ${DIM}\"$TITLE...\"${NC}"
    fi
else
    echo -e "   No decisions logged today"
fi

# Check for running processes
echo ""
echo -e "${YELLOW}🔧 Active Processes:${NC}"
NPM_COUNT=$(pgrep -f "npm|node" 2>/dev/null | wc -l)
PYTHON_COUNT=$(pgrep -f "python" 2>/dev/null | wc -l)
[ $NPM_COUNT -gt 0 ] && echo -e "   Node/npm: ${GREEN}$NPM_COUNT${NC} processes"
[ $PYTHON_COUNT -gt 0 ] && echo -e "   Python: ${GREEN}$PYTHON_COUNT${NC} processes"
[ $NPM_COUNT -eq 0 ] && [ $PYTHON_COUNT -eq 0 ] && echo -e "   ${DIM}No active development processes${NC}"

# Quick tips based on context
echo ""
echo -e "${YELLOW}💡 Quick Actions:${NC}"
if [ $DECISION_COUNT -eq 0 ]; then
    echo -e "   ${DIM}Log decisions with: %l \"title\" \"description\" \"project\"${NC}"
fi
if ! pgrep -f "capture_context.py --daemon" > /dev/null 2>&1; then
    echo -e "   ${DIM}Start context daemon: admin/scripts/start_context_daemon.sh${NC}"
fi
echo -e "   ${DIM}Status: %s | CAIA: %c | All commands: %${NC}"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✓ Ready${NC} ${DIM}(session: $(date +%H:%M:%S))${NC}"