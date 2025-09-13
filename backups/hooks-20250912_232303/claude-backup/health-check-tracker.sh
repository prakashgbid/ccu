#!/bin/bash
#
# System Health Check Tracker
# Tracks when thorough health checks are performed
#

TRACKER_FILE="$HOME/.claude/last_health_check"
TRACKER_DIR="$HOME/.claude/health-check-logs"
CURRENT_TIME=$(date +%s)
CHECK_INTERVAL=$((4 * 60 * 60))  # 4 hours in seconds

# Create tracker directory if it doesn't exist
mkdir -p "$TRACKER_DIR"

# Function to record health check
record_health_check() {
    echo "$CURRENT_TIME" > "$TRACKER_FILE"
    echo "$(date '+%Y-%m-%d %H:%M:%S')" > "$TRACKER_DIR/last_check_time.txt"
}

# Function to check if health check is needed
needs_health_check() {
    if [ ! -f "$TRACKER_FILE" ]; then
        echo "1"  # First time, needs check
        return
    fi
    
    LAST_CHECK=$(cat "$TRACKER_FILE" 2>/dev/null || echo "0")
    TIME_DIFF=$((CURRENT_TIME - LAST_CHECK))
    
    if [ $TIME_DIFF -gt $CHECK_INTERVAL ]; then
        echo "1"  # More than 4 hours, needs check
    else
        echo "0"  # Recent check, skip
    fi
}

# Function to get time since last check
time_since_last_check() {
    if [ ! -f "$TRACKER_FILE" ]; then
        echo "Never"
        return
    fi
    
    LAST_CHECK=$(cat "$TRACKER_FILE" 2>/dev/null || echo "0")
    TIME_DIFF=$((CURRENT_TIME - LAST_CHECK))
    
    if [ $TIME_DIFF -lt 60 ]; then
        echo "${TIME_DIFF} seconds ago"
    elif [ $TIME_DIFF -lt 3600 ]; then
        echo "$((TIME_DIFF / 60)) minutes ago"
    elif [ $TIME_DIFF -lt 86400 ]; then
        echo "$((TIME_DIFF / 3600)) hours ago"
    else
        echo "$((TIME_DIFF / 86400)) days ago"
    fi
}

# Function to perform thorough health check
perform_thorough_check() {
    local LOG_FILE="$TRACKER_DIR/health_check_$(date +%Y%m%d_%H%M%S).log"
    
    {
        echo "=== System Health Check ==="
        echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""
        
        # Check all critical services
        echo "Service Status:"
        echo -n "  CKS API (5555): "
        timeout 1 curl -s http://localhost:5555/health &>/dev/null && echo "✓ Running" || echo "✗ Stopped"
        
        echo -n "  CKS Core (5000): "
        timeout 1 curl -s http://localhost:5000/health &>/dev/null && echo "✓ Running" || echo "✗ Stopped"
        
        echo -n "  CLS Learning (5003): "
        timeout 1 curl -s http://localhost:5003/health &>/dev/null && echo "✓ Running" || echo "✗ Stopped"
        
        echo -n "  Enhancement (5002): "
        timeout 1 curl -s http://localhost:5002/health &>/dev/null && echo "✓ Running" || echo "✗ Stopped"
        
        echo -n "  Context Daemon: "
        pgrep -f "capture_context.py --daemon" &>/dev/null && echo "✓ Running" || echo "✗ Stopped"
        
        echo ""
        echo "Database Status:"
        
        # Check database sizes
        if [ -f "$HOME/Documents/projects/caia/knowledge-system/data/caia_knowledge.db" ]; then
            SIZE=$(du -h "$HOME/Documents/projects/caia/knowledge-system/data/caia_knowledge.db" | cut -f1)
            echo "  Knowledge DB: $SIZE"
        fi
        
        if [ -f "$HOME/Documents/projects/caia/knowledge-system/data/chat_history.db" ]; then
            SIZE=$(du -h "$HOME/Documents/projects/caia/knowledge-system/data/chat_history.db" | cut -f1)
            echo "  Chat History: $SIZE"
        fi
        
        echo ""
        echo "System Resources:"
        echo "  CPU Load: $(uptime | awk -F'load average:' '{print $2}')"
        echo "  Memory: $(vm_stat | grep 'Pages free' | awk '{print $3}' | sed 's/\.//')"
        
    } | tee "$LOG_FILE"
    
    record_health_check
    return 0
}

# Export functions for use
export -f record_health_check
export -f needs_health_check
export -f time_since_last_check
export -f perform_thorough_check

# Handle command line arguments
case "${1:-}" in
    check)
        needs_health_check
        ;;
    time)
        time_since_last_check
        ;;
    perform)
        perform_thorough_check
        ;;
    record)
        record_health_check
        ;;
    *)
        echo "Usage: $0 {check|time|perform|record}"
        ;;
esac