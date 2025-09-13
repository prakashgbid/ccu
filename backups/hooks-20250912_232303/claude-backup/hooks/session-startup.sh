#!/bin/bash
# Session startup hook for CC Enhancement Systems

echo "🚀 Initializing CC Enhancement Systems..."

# Start critical systems
"$CC_ENHANCEMENT_DIR/auto-startup.sh" > /dev/null 2>&1

# Create new session
SESSION_ID=$(python3 "$CC_ENHANCEMENT_DIR/csm/csm_system.py" create_session 2>/dev/null)
export CC_SESSION_ID="$SESSION_ID"

echo "✅ CC Enhancement Systems ready!"

# CKS Learning System Auto-Start
/Users/MAC/.claude/hooks/cks-auto-start.sh

# Start CKS Change Monitor for auto-evolution
if [ -f "/Users/MAC/Documents/projects/caia/knowledge-system/scripts/start_cks_monitor.sh" ]; then
    /Users/MAC/Documents/projects/caia/knowledge-system/scripts/start_cks_monitor.sh start > /dev/null 2>&1
fi

# Run CKS Integration Test (Background)
if [ -f "/Users/MAC/Documents/projects/caia/knowledge-system/scripts/run_integration_test.sh" ]; then
    echo "🔍 Running CKS integration test in background..."
    /Users/MAC/Documents/projects/caia/knowledge-system/scripts/run_integration_test.sh > /Users/MAC/Documents/projects/caia/knowledge-system/logs/startup_test_$(date +%Y%m%d_%H%M%S).log 2>&1 &
    echo "📊 Test running (PID: $!). Results will be logged."
fi

# Start comprehensive hooks system
if [ -f ~/.claude/hooks/cc-comprehensive-hooks.sh ]; then
  source ~/.claude/hooks/cc-comprehensive-hooks.sh 2>/dev/null
  echo "✅ Comprehensive hooks system loaded"
fi

echo "✅ Session startup hooks completed"
