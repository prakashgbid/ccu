#!/bin/bash
# CC Enhancement Systems Auto-Start Hook
# Automatically starts daemon on every CC session if not already running

# Configuration
CC_ENHANCEMENT_DIR="/Users/MAC/Documents/projects/caia/knowledge-system/cc-enhancement"
DAEMON_PORT=5002
LOG_FILE="$CC_ENHANCEMENT_DIR/logs/daemon.log"
PID_FILE="$CC_ENHANCEMENT_DIR/daemon.pid"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to check if daemon is running
is_daemon_running() {
    # Check multiple ways to ensure accuracy
    
    # Method 1: Check if port is in use
    if lsof -Pi :$DAEMON_PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 0
    fi
    
    # Method 2: Check if process is running
    if pgrep -f "system-daemon.py" > /dev/null 2>&1; then
        return 0
    fi
    
    # Method 3: Check PID file
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            return 0
        else
            # PID file exists but process is dead, clean up
            rm -f "$PID_FILE"
        fi
    fi
    
    # Method 4: Try health check
    if curl -s -f -m 2 http://localhost:$DAEMON_PORT/health > /dev/null 2>&1; then
        return 0
    fi
    
    return 1
}

# Function to start daemon
start_daemon() {
    echo -e "${YELLOW}Starting CC Enhancement Systems Daemon...${NC}"
    
    # Ensure log directory exists
    mkdir -p "$CC_ENHANCEMENT_DIR/logs"
    
    # Change to enhancement directory
    cd "$CC_ENHANCEMENT_DIR" || {
        echo -e "${RED}❌ Failed to change to enhancement directory${NC}"
        return 1
    }
    
    # Start the daemon
    nohup python3 system-daemon.py > "$LOG_FILE" 2>&1 &
    local daemon_pid=$!
    
    # Save PID
    echo "$daemon_pid" > "$PID_FILE"
    
    # Wait for daemon to start (max 10 seconds)
    local count=0
    while [ $count -lt 10 ]; do
        if curl -s -f -m 1 http://localhost:$DAEMON_PORT/health > /dev/null 2>&1; then
            echo -e "${GREEN}✅ CC Enhancement Daemon started successfully (PID: $daemon_pid)${NC}"
            return 0
        fi
        sleep 1
        count=$((count + 1))
    done
    
    # Check if process is still running
    if ps -p "$daemon_pid" > /dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Daemon started but health check failed (PID: $daemon_pid)${NC}"
        echo "   Check logs at: $LOG_FILE"
        return 1
    else
        echo -e "${RED}❌ Daemon failed to start${NC}"
        echo "   Check logs at: $LOG_FILE"
        rm -f "$PID_FILE"
        return 1
    fi
}

# Function to create session
create_session() {
    local project_path="${1:-$(pwd)}"
    
    # Wait a moment for daemon to be fully ready
    sleep 1
    
    # Create session via API
    local response=$(curl -s -X POST http://localhost:$DAEMON_PORT/api/csm/create_session \
        -H "Content-Type: application/json" \
        -d "{\"args\": [\"$project_path\"], \"kwargs\": {\"context\": {\"start_time\": \"$(date)\", \"user\": \"$USER\"}}}" 2>/dev/null)
    
    if [ $? -eq 0 ] && echo "$response" | grep -q "success.*true"; then
        local session_id=$(echo "$response" | grep -o '"result":"[^"]*' | cut -d'"' -f4)
        if [ -n "$session_id" ]; then
            echo -e "${GREEN}✅ Session created: ${session_id:0:8}...${NC}"
            export CC_SESSION_ID="$session_id"
        fi
    fi
}

# Main execution
main() {
    echo "🔍 CC Enhancement Systems Auto-Start Hook"
    echo "=========================================="
    
    # Check if daemon is already running
    if is_daemon_running; then
        echo -e "${GREEN}✅ Daemon already running${NC}"
        
        # Verify it's healthy
        if curl -s -f -m 2 http://localhost:$DAEMON_PORT/health > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Health check passed${NC}"
        else
            echo -e "${YELLOW}⚠️  Daemon running but health check failed${NC}"
        fi
    else
        echo -e "${YELLOW}⚡ Daemon not running, starting now...${NC}"
        
        # Start the daemon
        if start_daemon; then
            echo -e "${GREEN}✅ Daemon started successfully${NC}"
        else
            echo -e "${RED}⚠️  Daemon start failed - CC will work without enhancements${NC}"
            # Don't exit with error to not block CC session
        fi
    fi
    
    # Create session for current project
    echo ""
    echo "📁 Creating session for: $(pwd)"
    create_session "$(pwd)"
    
    # Show final status
    echo ""
    echo "=========================================="
    if is_daemon_running; then
        echo -e "${GREEN}✅ CC Enhancement Systems: ACTIVE${NC}"
        echo "   API: http://localhost:$DAEMON_PORT"
        echo "   Logs: $LOG_FILE"
        
        # Show available CC instances
        local instances=$(curl -s -X POST http://localhost:$DAEMON_PORT/api/crc/calculate_available_cc_instances \
            -H "Content-Type: application/json" \
            -d '{"args": [], "kwargs": {}}' 2>/dev/null | grep -o '"result":[0-9]*' | cut -d':' -f2)
        
        if [ -n "$instances" ]; then
            echo "   Available CC instances: $instances"
        fi
    else
        echo -e "${YELLOW}⚠️  CC Enhancement Systems: INACTIVE${NC}"
        echo "   Running in standard mode"
    fi
    echo "=========================================="
    echo ""
}

# Run main function
main

# Export enhancement functions for use in CC session
export -f is_daemon_running

# Make enhancement API easily accessible
alias cc-health='curl -s http://localhost:5002/health | python3 -m json.tool'
alias cc-status='curl -s http://localhost:5002/api/status | python3 -m json.tool'
alias cc-resources='curl -s -X POST http://localhost:5002/api/crc/get_current_resources -H "Content-Type: application/json" -d "{\"args\": [], \"kwargs\": {}}" | python3 -m json.tool'