#!/bin/bash
#
# Minimal Claude Code Session Startup Hook
# Quick, clean, non-blocking startup with essential info only
#

set +e  # Don't exit on errors

# Quick parallel service checks (timeout 0.5 seconds each)
CKS_OK=$(timeout 0.5 curl -s http://localhost:5555/health &>/dev/null && echo "✓" || echo "○")
CLS_OK=$(timeout 0.5 curl -s http://localhost:5003/health &>/dev/null && echo "✓" || echo "○")
DAEMON_OK=$(pgrep -f "capture_context.py" &>/dev/null && echo "✓" || echo "○")

# Count uncommitted projects
UNCOMMITTED_COUNT=0
for dir in /Users/MAC/Documents/projects/*/.git; do
    if [ -d "$dir" ]; then
        cd "$(dirname "$dir")" 2>/dev/null || continue
        if ! git diff --quiet HEAD 2>/dev/null || [ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ]; then
            ((UNCOMMITTED_COUNT++))
        fi
    fi
done 2>/dev/null

# Single line status
echo -n "🚀 CC Ready | Services: CKS[$CKS_OK] CLS[$CLS_OK] Daemon[$DAEMON_OK]"
[ $UNCOMMITTED_COUNT -gt 0 ] && echo " | 📝 $UNCOMMITTED_COUNT projects uncommitted" || echo ""

# Session tracking
export CC_SESSION_ID="session_$(date +%Y%m%d_%H%M%S)"

# Load CILS silently
[ -f /Users/MAC/.claude/hooks/cils-interaction-capture.sh ] && \
    source /Users/MAC/.claude/hooks/cils-interaction-capture.sh 2>/dev/null

# Always succeed
exit 0