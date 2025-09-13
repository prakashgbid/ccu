#!/bin/bash
#
# Enhanced Claude Code Session Startup Hook
# Includes: health tracking, service auto-start, uncommitted changes detection
#

# Exit on any error would block CC, so we handle errors gracefully
set +e

# Colors for minimal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Load health check functions
needs_health_check() {
    /Users/MAC/.claude/health-check-tracker.sh check
}

time_since_last_check() {
    /Users/MAC/.claude/health-check-tracker.sh time
}

perform_thorough_check() {
    /Users/MAC/.claude/health-check-tracker.sh perform
}

echo "🚀 Claude Code Session Starting..."

# =============================================================================
# 1. Quick Service Status & Auto-Start
# =============================================================================

check_and_start_service() {
    local name="$1"
    local port="$2"
    local start_cmd="$3"
    
    if timeout 1 curl -s "http://localhost:$port/health" &>/dev/null; then
        echo "1"  # Running
    else
        # Try to start the service
        if [ -n "$start_cmd" ]; then
            eval "$start_cmd" >/dev/null 2>&1 &
            sleep 2  # Give it time to start
            timeout 1 curl -s "http://localhost:$port/health" &>/dev/null && echo "1" || echo "0"
        else
            echo "0"  # Not running, no start command
        fi
    fi
}

# Check and potentially start critical services
CKS_STATUS=$(check_and_start_service "CKS" "5555" "/Users/MAC/Documents/projects/caia/knowledge-system/scripts/start_all_services.sh")
CLS_STATUS=$(check_and_start_service "CLS" "5003" "/Users/MAC/Documents/projects/caia/knowledge-system/scripts/start_learning_system.sh")

# Check context daemon
DAEMON_STATUS="0"
if pgrep -f "capture_context.py --daemon" &>/dev/null; then
    DAEMON_STATUS="1"
else
    # Try to start it
    /Users/MAC/Documents/projects/admin/scripts/start_context_daemon.sh >/dev/null 2>&1
    sleep 1
    pgrep -f "capture_context.py --daemon" &>/dev/null && DAEMON_STATUS="1"
fi

# =============================================================================
# 2. Display Service Status
# =============================================================================

if [ "$CKS_STATUS" = "1" ] && [ "$CLS_STATUS" = "1" ]; then
    # Get quick stats
    STATS=$(timeout 1 curl -s http://localhost:5555/stats 2>/dev/null)
    FILES=$(echo "$STATS" | grep -o '"total_files":[0-9]*' | cut -d: -f2 2>/dev/null || echo "0")
    echo -e "${GREEN}✅ Core Services: CKS & CLS running${NC} | ${FILES:-0} files indexed"
else
    # Show service status without alarm - they're auto-starting
    [ "$CKS_STATUS" = "0" ] && echo -e "${YELLOW}⚠️  CKS starting in background...${NC}"
    [ "$CLS_STATUS" = "0" ] && echo -e "${YELLOW}⚠️  CLS starting in background...${NC}"
fi

[ "$DAEMON_STATUS" = "0" ] && echo -e "${YELLOW}⚠️  Context daemon starting...${NC}"

# =============================================================================
# 3. Thorough System Check (if needed)
# =============================================================================

if [ "$(needs_health_check)" = "1" ]; then
    echo -e "${YELLOW}🔍 Running 4-hour system check...${NC}"
    
    # Run thorough check in background to not slow startup
    (
        perform_thorough_check >/dev/null 2>&1
        echo "$(date '+%Y-%m-%d %H:%M:%S'): Thorough check completed" >> /Users/MAC/.claude/health-check-logs/checks.log
    ) &
    
    echo "   System check initiated (background)"
else
    LAST_CHECK=$(time_since_last_check)
    echo "   Last system check: $LAST_CHECK"
fi

# =============================================================================
# 4. Check for Uncommitted Changes
# =============================================================================

echo ""
echo "📝 Checking for uncommitted changes..."

# Find all git repos with uncommitted changes
UNCOMMITTED_PROJECTS=()
ORIGINAL_DIR=$(pwd)
for project_dir in /Users/MAC/Documents/projects/*/; do
    if [ -d "$project_dir/.git" ]; then
        cd "$project_dir" 2>/dev/null || continue
        
        # Check for uncommitted changes
        if ! git diff --quiet HEAD 2>/dev/null || ! git diff --cached --quiet 2>/dev/null || [ -n "$(git ls-files --others --exclude-standard)" ]; then
            PROJECT_NAME=$(basename "$project_dir")
            # Get counts (ensure we get clean numbers)
            MODIFIED=$(git status --porcelain 2>/dev/null | grep "^ M" | wc -l | tr -d ' ')
            UNTRACKED=$(git status --porcelain 2>/dev/null | grep "^??" | wc -l | tr -d ' ')
            STAGED=$(git status --porcelain 2>/dev/null | grep "^[AM]" | wc -l | tr -d ' ')
            
            STATUS=""
            [ "$MODIFIED" -gt 0 ] && STATUS="${STATUS}${MODIFIED}M "
            [ "$STAGED" -gt 0 ] && STATUS="${STATUS}${STAGED}S "
            [ "$UNTRACKED" -gt 0 ] && STATUS="${STATUS}${UNTRACKED}U"
            
            UNCOMMITTED_PROJECTS+=("$PROJECT_NAME: $STATUS")
        fi
    fi
done
cd "$ORIGINAL_DIR" 2>/dev/null  # Return to original directory

# Display uncommitted projects
if [ ${#UNCOMMITTED_PROJECTS[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Projects with uncommitted changes:${NC}"
    for project in "${UNCOMMITTED_PROJECTS[@]}"; do
        echo "   • $project"
    done
else
    echo -e "${GREEN}✅ All projects committed${NC}"
fi

# =============================================================================
# 5. Set Session Variables
# =============================================================================

export CC_SESSION_ID="session_$(date +%Y%m%d_%H%M%S)"
export CC_SERVICES_STATUS="CKS:$CKS_STATUS,CLS:$CLS_STATUS,DAEMON:$DAEMON_STATUS"

# Load CILS silently if available
[ -f /Users/MAC/.claude/hooks/cils-interaction-capture.sh ] && \
    source /Users/MAC/.claude/hooks/cils-interaction-capture.sh 2>/dev/null

# =============================================================================
# 6. Quick Tips (occasional)
# =============================================================================

if [ $((RANDOM % 5)) -eq 0 ]; then
    TIPS=(
        "💡 Run 'cks_find_similar' before writing new code"
        "💡 Use '&' for parallel execution"
        "💡 Check 'adm' for admin commands"
        "💡 Run 'git add -A && git commit -m \"updates\"' to commit"
        "💡 Use 'cks_status' to check system health"
    )
    echo ""
    echo "${TIPS[$((RANDOM % ${#TIPS[@]}))]}"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Always return success to avoid blocking CC startup
# Services will auto-start in background if needed
exit 0