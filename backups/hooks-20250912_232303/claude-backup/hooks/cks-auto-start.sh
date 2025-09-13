#!/bin/bash
# CKS/CLS Complete Learning System Auto-Start
# This ensures everything starts automatically on new CC sessions

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧠 CKS LEARNING SYSTEM AUTO-INITIALIZATION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Set environment variables
export CKS_PATH="/Users/MAC/Documents/projects/caia/knowledge-system"
export CKS_API_URL="http://localhost:5555"
export ENHANCEMENT_API_URL="http://localhost:5002"
export LEARNING_API_URL="http://localhost:5003"
export CKS_ENFORCEMENT=MANDATORY
export CC_LEARNING_ENABLED=true
export CKS_SESSION_ID="cc_$(date +%s)"

# Function to start service if not running
start_service() {
    local PORT=$1
    local SCRIPT=$2
    local NAME=$3
    
    if ! curl -s http://localhost:$PORT/health > /dev/null 2>&1; then
        echo "  Starting $NAME..."
        cd "$CKS_PATH"
        nohup python3 "$SCRIPT" > "/tmp/${SCRIPT}.log" 2>&1 &
        sleep 2
        
        if curl -s http://localhost:$PORT/health > /dev/null 2>&1; then
            echo "  ✅ $NAME started on port $PORT"
        else
            echo "  ⚠️  $NAME may be starting up..."
        fi
    else
        echo "  ✅ $NAME already running on port $PORT"
    fi
}

echo -e "\n📡 Starting Core Services:"
echo "─────────────────────────"

# Start all services
start_service 5555 "cks-api-bridge.py" "CKS API Bridge"
start_service 5002 "cc-enhancement/cc-enhancement-daemon.py" "Enhancement Systems"
start_service 5003 "unified-learning-api.py" "Unified Learning API"
start_service 5000 "cks_api.py" "Legacy CKS API"

# Start real-time updater
if ! pgrep -f "real-time-updater.py" > /dev/null; then
    echo "  Starting Real-time Updater..."
    cd "$CKS_PATH"
    nohup python3 real-time-updater.py > /tmp/realtime-updater.log 2>&1 &
    echo "  ✅ Real-time updater started"
else
    echo "  ✅ Real-time updater already running"
fi

echo -e "\n📊 System Status:"
echo "─────────────────"

# Get statistics
if STATS=$(curl -s http://localhost:5555/stats 2>/dev/null); then
    FILES=$(echo "$STATS" | python3 -c "import sys, json; print(json.load(sys.stdin).get('total_files', 0))")
    FUNCTIONS=$(echo "$STATS" | python3 -c "import sys, json; print(json.load(sys.stdin).get('total_functions', 0))")
    CLASSES=$(echo "$STATS" | python3 -c "import sys, json; print(json.load(sys.stdin).get('total_classes', 0))")
    
    echo "  📁 Files indexed: $FILES"
    echo "  🔧 Functions: $FUNCTIONS"
    echo "  📦 Classes: $CLASSES"
fi

# Check chat history
if [ -f "$CKS_PATH/data/chat_history.db" ]; then
    INTERACTIONS=$(sqlite3 "$CKS_PATH/data/chat_history.db" "SELECT COUNT(*) FROM chat_interactions;" 2>/dev/null || echo "0")
    echo "  💬 Interactions stored: $INTERACTIONS"
fi

echo -e "\n🔒 Enforcement Status:"
echo "─────────────────────"
echo "  CKS_ENFORCEMENT=$CKS_ENFORCEMENT"
echo "  CC_LEARNING_ENABLED=$CC_LEARNING_ENABLED"
echo "  SESSION_ID=$CKS_SESSION_ID"

# Test functionality
echo -e "\n🧪 Quick Functionality Test:"
echo "─────────────────────────────"

# Test search
if curl -s -X POST http://localhost:5555/search/function \
    -H "Content-Type: application/json" \
    -d '{"query": "init", "limit": 1}' | grep -q "results"; then
    echo "  ✅ CKS search: Working"
else
    echo "  ❌ CKS search: Not working"
fi

# Test learning
if curl -s http://localhost:5003/health | grep -q "healthy"; then
    echo "  ✅ Learning system: Active"
else
    echo "  ❌ Learning system: Not active"
fi

# Test duplicate detection
if curl -s -X POST http://localhost:5555/check/duplicate \
    -H "Content-Type: application/json" \
    -d '{"name": "test", "type": "function"}' | grep -q "exists"; then
    echo "  ✅ Duplicate detection: Working"
else
    echo "  ❌ Duplicate detection: Not working"
fi

echo -e "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ CKS LEARNING SYSTEM READY!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 Quick Test: Ask CC to search for any function"
echo "🔄 Parallel Support: Open multiple terminals - all will share knowledge"
echo "💾 Session Persistence: All learning is preserved across sessions"
echo ""