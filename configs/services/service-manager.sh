#!/bin/bash
# Service Manager - Start, stop, and monitor enhancement services

# Service configuration
CKS_PORT=5555
ENHANCEMENT_PORT=5002
LEARNING_PORT=5003

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

start_services() {
    echo "Starting enhancement services..."
    
    # CKS Bridge
    if ! pgrep -f "cks_bridge.py" > /dev/null; then
        if [ -f "$HOME/Documents/projects/caia/knowledge-system/cks_bridge.py" ]; then
            cd "$HOME/Documents/projects/caia/knowledge-system"
            python3 cks_bridge.py > "$HOME/.claude/logs/cks_bridge.log" 2>&1 &
            echo "  Started CKS Bridge"
        fi
    else
        echo "  CKS Bridge already running"
    fi
    
    # Enhancement System
    if ! curl -s "http://localhost:$ENHANCEMENT_PORT/health" > /dev/null 2>&1; then
        if [ -d "$HOME/Documents/projects/caia/knowledge-system/cc-enhancement" ]; then
            cd "$HOME/Documents/projects/caia/knowledge-system/cc-enhancement"
            node server.js > "$HOME/.claude/logs/enhancement.log" 2>&1 &
            echo "  Started Enhancement System"
        fi
    else
        echo "  Enhancement System already running"
    fi
    
    # Learning System (if exists)
    if ! curl -s "http://localhost:$LEARNING_PORT/health" > /dev/null 2>&1; then
        if [ -d "$HOME/Documents/projects/caia/knowledge-system/learning" ]; then
            cd "$HOME/Documents/projects/caia/knowledge-system/learning"
            npm start > "$HOME/.claude/logs/learning.log" 2>&1 &
            echo "  Started Learning System"
        fi
    else
        echo "  Learning System already running"
    fi
    
    sleep 2
    status_services
}

stop_services() {
    echo "Stopping enhancement services..."
    
    # Kill processes
    pkill -f "cks_bridge.py" && echo "  Stopped CKS Bridge" || echo "  CKS Bridge not running"
    pkill -f "node.*$ENHANCEMENT_PORT" && echo "  Stopped Enhancement System" || echo "  Enhancement not running"
    pkill -f "node.*$LEARNING_PORT" && echo "  Stopped Learning System" || echo "  Learning not running"
    
    sleep 1
    status_services
}

status_services() {
    echo ""
    echo "Service Status:"
    
    # CKS
    if curl -s "http://localhost:$CKS_PORT/health" > /dev/null 2>&1; then
        echo -e "  CKS (5555): ${GREEN}✅ Running${NC}"
    else
        echo -e "  CKS (5555): ${RED}❌ Not running${NC}"
    fi
    
    # Enhancement
    if curl -s "http://localhost:$ENHANCEMENT_PORT/health" > /dev/null 2>&1; then
        echo -e "  Enhancement (5002): ${GREEN}✅ Running${NC}"
    else
        echo -e "  Enhancement (5002): ${RED}❌ Not running${NC}"
    fi
    
    # Learning
    if curl -s "http://localhost:$LEARNING_PORT/health" > /dev/null 2>&1; then
        echo -e "  Learning (5003): ${GREEN}✅ Running${NC}"
    else
        echo -e "  Learning (5003): ${YELLOW}⚠ Not running${NC}"
    fi
    
    # Check processes
    echo ""
    echo "Related Processes:"
    ps aux | grep -E "(cks|enhancement|learning)" | grep -v grep | wc -l | xargs echo "  Active processes:"
}

# Main command handler
case "$1" in
    start)
        start_services
        ;;
    stop)
        stop_services
        ;;
    status)
        status_services
        ;;
    restart)
        stop_services
        sleep 2
        start_services
        ;;
    *)
        echo "Usage: $0 {start|stop|status|restart}"
        exit 1
        ;;
esac

exit 0