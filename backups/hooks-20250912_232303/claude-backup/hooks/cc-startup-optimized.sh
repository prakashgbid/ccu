#!/bin/bash
#
# Optimized Claude Code Startup Hook
# Provides only actionable information with minimal noise
#

# Quick parallel health checks (timeout after 1 second)
check_service() {
    timeout 1 curl -s "$1" &>/dev/null && echo "1" || echo "0"
}

# Run checks in parallel
CKS_OK=$(check_service "http://localhost:5555/health" &)
ENH_OK=$(check_service "http://localhost:5002/health" &)
DAEMON_OK=$([ -f ~/.claude/context_daemon.pid ] && kill -0 $(cat ~/.claude/context_daemon.pid) 2>/dev/null && echo "1" || echo "0" &)

# Wait for all checks
wait

# Get actual values
CKS_OK=$(echo "$CKS_OK")
ENH_OK=$(echo "$ENH_OK")
DAEMON_OK=$(echo "$DAEMON_OK")

# Start of output
echo "🚀 Claude Code Enhanced Session"
echo "================================"

# Only show problems or important info
ISSUES=()
WARNINGS=()

# Check for issues
[ "$CKS_OK" = "0" ] && ISSUES+=("❌ Knowledge System offline → run: cks_start")
[ "$ENH_OK" = "0" ] && WARNINGS+=("⚠️  Enhancement systems offline → run: start_enhancements")
[ "$DAEMON_OK" = "0" ] && WARNINGS+=("⚠️  Context daemon not running → run: start_context_daemon")

# If everything is working, show useful stats
if [ ${#ISSUES[@]} -eq 0 ] && [ ${#WARNINGS[@]} -eq 0 ]; then
    # Get real stats (with timeout)
    STATS=$(timeout 1 curl -s http://localhost:5555/stats 2>/dev/null)
    if [ -n "$STATS" ]; then
        FILES=$(echo "$STATS" | grep -o '"total_files":[0-9]*' | cut -d: -f2)
        FUNCTIONS=$(echo "$STATS" | grep -o '"total_functions":[0-9]*' | cut -d: -f2)
        [ -n "$FILES" ] && [ -n "$FUNCTIONS" ] && echo "✅ All systems operational"
        echo "📊 Knowledge Base: ${FILES:-0} files, ${FUNCTIONS:-0} functions indexed"
    else
        echo "✅ Core systems ready"
    fi
    
    # Show recent activity if available
    if [ -f ~/Documents/projects/admin/context/latest_summary.txt ]; then
        LAST_UPDATE=$(stat -f "%Sm" -t "%H:%M" ~/Documents/projects/admin/context/latest_summary.txt 2>/dev/null)
        [ -n "$LAST_UPDATE" ] && echo "📝 Last context update: $LAST_UPDATE"
    fi
else
    # Show issues first
    if [ ${#ISSUES[@]} -gt 0 ]; then
        printf "%s\n" "${ISSUES[@]}"
    fi
    
    # Show warnings
    if [ ${#WARNINGS[@]} -gt 0 ]; then
        printf "%s\n" "${WARNINGS[@]}"
    fi
fi

# Show a single actionable tip (10% chance, different each time)
if [ $((RANDOM % 10)) -eq 0 ]; then
    TIPS=(
        "💡 Use 'cks_find_similar' before writing new functions"
        "💡 Run 'cks_status' to check knowledge system health"
        "💡 Use 'adm' for quick admin commands"
        "💡 Check 'caia_status' for project overview"
        "💡 Use parallel execution with '&' for faster operations"
    )
    echo "${TIPS[$((RANDOM % ${#TIPS[@]}))]}"
fi

echo "================================"