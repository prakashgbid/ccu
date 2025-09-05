#!/bin/bash
#
# Claude Code Session Startup Hook - Clean & Efficient
# Replaces the verbose multi-layered startup system
#

# Quick service checks (all in parallel, 1 sec timeout)
check_service() {
    timeout 1 curl -s "$1" &>/dev/null && echo "1" || echo "0"
}

# Start checks in background
CKS_API=$(check_service "http://localhost:5555/health") &
CKS_CORE=$(check_service "http://localhost:5000/health") &
ENH_API=$(check_service "http://localhost:5002/health") &
CONTEXT_DAEMON=$(pgrep -f "capture_context.py --daemon" &>/dev/null && echo "1" || echo "0") &

# Wait for all checks (max 1 second)
wait

# Prepare output
ISSUES=()
SERVICES_OK=true

# Check results
[ "$(echo $CKS_API)" = "0" ] && { ISSUES+=("CKS offline"); SERVICES_OK=false; }
[ "$(echo $CONTEXT_DAEMON)" = "0" ] && ISSUES+=("Context daemon stopped")

# Single clean output
echo "🚀 Claude Code Session Ready"

# Show status based on checks
if [ "$SERVICES_OK" = true ] && [ ${#ISSUES[@]} -eq 0 ]; then
    # Everything working - show minimal stats
    STATS=$(timeout 1 curl -s http://localhost:5555/stats 2>/dev/null)
    if [ -n "$STATS" ]; then
        FILES=$(echo "$STATS" | grep -o '"total_files":[0-9]*' | cut -d: -f2)
        echo "✅ All systems operational | ${FILES:-0} files indexed"
    else
        echo "✅ Core systems ready"
    fi
else
    # Show issues compactly
    if [ ${#ISSUES[@]} -gt 0 ]; then
        echo "⚠️  Issues: $(IFS=', '; echo "${ISSUES[*]}")"
        echo "   Fix: run 'start_all_services' or 'start_context_daemon'"
    fi
fi

# Session ID for tracking
export CC_SESSION_ID="session_$(date +%Y%m%d_%H%M%S)"

# Load CILS silently if available
[ -f /Users/MAC/.claude/hooks/cils-interaction-capture.sh ] && \
    source /Users/MAC/.claude/hooks/cils-interaction-capture.sh 2>/dev/null