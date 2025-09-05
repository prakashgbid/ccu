#!/bin/bash
# CAIA Unified Startup Hook for Claude Code
# Starts CKS, CLS, and CC Enhancement Systems with duplicate prevention

KNOWLEDGE_BASE="/Users/MAC/Documents/projects/caia/knowledge-system"
UNIFIED_SCRIPT="$KNOWLEDGE_BASE/unified-auto-start.sh"

# Check if unified script exists and is executable
if [ -f "$UNIFIED_SCRIPT" ]; then
    # Make it executable if not already
    chmod +x "$UNIFIED_SCRIPT" 2>/dev/null
    
    # Run the unified startup
    "$UNIFIED_SCRIPT"
else
    echo "⚠️  Unified startup script not found at: $UNIFIED_SCRIPT"
    echo "    Falling back to CC Enhancement only..."
    
    # Fallback to just CC Enhancement
    if [ -f "/Users/MAC/.claude/hooks/cc-enhancement-auto-start.sh" ]; then
        /Users/MAC/.claude/hooks/cc-enhancement-auto-start.sh
    fi
fi

# Create CC session after all systems are running
PROJECT_PATH=$(pwd)
echo ""
echo "📁 Creating CC session for: $PROJECT_PATH"

# Try CC Enhancement session first
if curl -s -f http://localhost:5002/health > /dev/null 2>&1; then
    curl -s -X POST http://localhost:5002/api/csm/create_session \
        -H "Content-Type: application/json" \
        -d "{\"args\": [\"$PROJECT_PATH\"], \"kwargs\": {}}" > /dev/null 2>&1
fi

# Export environment for easy access
export CKS_API="http://localhost:5000"
export CLS_API="http://localhost:5001"
export CC_ENHANCEMENT_API="http://localhost:5002"

echo "✅ CAIA Systems ready for use!"