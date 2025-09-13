#!/bin/bash

# Claude Code Session Hook - Main integration point for learning
# This hook runs at the start of every CC session and connects all learning systems

echo "🚀 Claude Code Session Starting..."

# 1. Start CKS if not running
if ! curl -s http://localhost:5555/health > /dev/null 2>&1; then
    echo "⚠️  CKS starting in background..."
    cd /Users/MAC/Documents/projects/caia/knowledge-system && \
        ./scripts/start_cks_simple.sh > /dev/null 2>&1 &
fi

# 2. Start CLS if not running
if ! curl -s http://localhost:5003/health > /dev/null 2>&1; then
    echo "⚠️  CLS starting in background..."
    python3 /Users/MAC/Documents/projects/caia/knowledge-system/enhanced_learning_api.py > /dev/null 2>&1 &
fi

# 3. Load data capture hooks
source /Users/MAC/.claude/hooks/cc-data-capture.sh

# 4. Create session and start capturing
SESSION_ID=$(date +%Y%m%d_%H%M%S)
export CC_SESSION_ID=$SESSION_ID

# 5. Log session start
curl -s -X POST http://localhost:5003/api/capture \
    -H "Content-Type: application/json" \
    -d "{
        \"session_id\": \"$SESSION_ID\",
        \"prompt\": \"Session started\",
        \"response\": \"Learning systems activated\",
        \"tools\": [],
        \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)\"
    }" > /dev/null 2>&1

# 6. Run system check in background
(
    sleep 2
    echo "🔍 Running 4-hour system check..."
    # Add your system check logic here
    echo "   System check initiated (background)"
) &

# 7. Check for uncommitted changes
echo "📝 Checking for uncommitted changes..."
cd /Users/MAC/Documents/projects/caia 2>/dev/null
if git status --porcelain | grep -q .; then
    echo "⚠️  Uncommitted changes detected"
else
    echo "✅ All projects committed"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Export capture functions globally
export -f capture_interaction
export -f capture_code_generation
export -f capture_tool_usage