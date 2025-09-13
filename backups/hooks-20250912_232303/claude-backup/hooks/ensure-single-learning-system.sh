#!/bin/bash
# Claude Code Hook: Ensure Single Learning System Instance
# This hook runs when Claude Code starts to connect to the shared learning system

echo "🔍 Checking CAIA Learning System status..."

# Get connection info from singleton manager
RESULT=$(python3 /Users/MAC/Documents/projects/caia/knowledge-system/learning/singleton_manager.py connect 2>&1)

if [ $? -eq 0 ]; then
    # Extract API URL from result
    API_URL=$(echo "$RESULT" | grep -o '"api_url": "[^"]*"' | cut -d'"' -f4)
    PID=$(echo "$RESULT" | grep -o '"pid": [0-9]*' | cut -d' ' -f2)
    
    # Export for use by Claude Code
    export CAIA_LEARNING_API="$API_URL"
    export CAIA_LEARNING_PID="$PID"
    
    echo "✅ Connected to CAIA Learning System"
    echo "   API: $API_URL"
    echo "   PID: $PID"
    
    # Verify health
    if curl -s "$API_URL/health" > /dev/null 2>&1; then
        echo "   Health: 🟢 OK"
    else
        echo "   Health: 🟡 Starting up..."
    fi
else
    echo "❌ Failed to connect to learning system"
    echo "$RESULT"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"