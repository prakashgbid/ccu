#!/bin/bash
# Claude Code Session Start Hook - Initialize services and environment

LOG_DIR="$HOME/.claude/logs"
mkdir -p "$LOG_DIR"

# Function to check and start service
start_service() {
    local name="$1"
    local port="$2"
    local start_cmd="$3"
    local log_file="$4"
    
    if curl -s "http://localhost:$port/health" >/dev/null 2>&1; then
        echo "✓ $name already running on port $port"
    else
        echo "Starting $name..."
        eval "$start_cmd > '$LOG_DIR/$log_file' 2>&1 &"
        sleep 2
        if curl -s "http://localhost:$port/health" >/dev/null 2>&1; then
            echo "✓ $name started successfully"
        else
            echo "⚠ $name failed to start (check $LOG_DIR/$log_file)"
        fi
    fi
}

echo "🚀 Claude Code Enhanced Session Starting..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Start CKS if available
if [ -d "$HOME/Documents/projects/caia/knowledge-system" ]; then
    start_service "CKS" 5555 \
        "cd $HOME/Documents/projects/caia/knowledge-system && npm start" \
        "cks.log"
fi

# Start Enhancement System if available
if [ -d "$HOME/Documents/projects/caia/knowledge-system/cc-enhancement" ]; then
    start_service "Enhancement" 5002 \
        "cd $HOME/Documents/projects/caia/knowledge-system/cc-enhancement && node server.js" \
        "enhancement.log"
fi

# Start Learning System if available
if [ -d "$HOME/Documents/projects/caia/knowledge-system/learning" ]; then
    start_service "Learning" 5003 \
        "cd $HOME/Documents/projects/caia/knowledge-system/learning && npm start" \
        "learning.log"
fi

# Show service status
echo ""
echo "📊 Service Status:"
curl -s http://localhost:5555/health >/dev/null 2>&1 && echo "  CKS: ✅ Running (port 5555)" || echo "  CKS: ❌ Not running"
curl -s http://localhost:5002/health >/dev/null 2>&1 && echo "  Enhancement: ✅ Running (port 5002)" || echo "  Enhancement: ❌ Not running"
curl -s http://localhost:5003/health >/dev/null 2>&1 && echo "  Learning: ✅ Running (port 5003)" || echo "  Learning: ❌ Not running"

# Check for uncommitted changes
echo ""
echo "📝 Repository Status:"
for dir in caia claude-code-ultimate; do
    if [ -d "$HOME/Documents/projects/$dir" ]; then
        cd "$HOME/Documents/projects/$dir"
        STATUS=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
        if [ "$STATUS" -gt 0 ]; then
            echo "  $dir: ⚠ $STATUS uncommitted changes"
        else
            echo "  $dir: ✅ Clean"
        fi
    fi
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Session ID: session_$(date +%Y%m%d_%H%M%S)"
export CC_SESSION_ID="session_$(date +%Y%m%d_%H%M%S)"

exit 0