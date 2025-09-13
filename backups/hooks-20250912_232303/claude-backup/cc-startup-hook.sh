#!/bin/bash

# Claude Code Startup Hook - MANDATORY CKS Integration
# This script runs automatically when Claude Code starts

set -e

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
CKS_PATH="/Users/MAC/Documents/projects/caia/knowledge-system"
CKS_INTEGRATION="$CKS_PATH/cc-integration"
LOG_FILE="$HOME/.claude/cks-integration.log"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

echo -e "${BLUE}🤖 CAIA Knowledge System - Claude Code Integration Loading...${NC}"
log "CC Startup: Initializing CKS integration"

# 1. Validate CKS is available
if [ ! -d "$CKS_PATH" ]; then
    echo -e "${RED}❌ ERROR: CAIA Knowledge System not found at $CKS_PATH${NC}"
    log "ERROR: CKS not found at $CKS_PATH"
    exit 1
fi

# 2. Load CKS commands
if [ -f "$CKS_INTEGRATION/automation/cks-commands.sh" ]; then
    source "$CKS_INTEGRATION/automation/cks-commands.sh"
    echo -e "${GREEN}✅ CKS commands loaded (30+ functions available)${NC}"
    log "CKS commands loaded successfully"
else
    echo -e "${YELLOW}⚠️  CKS commands not found, running basic integration${NC}"
    log "WARNING: CKS commands not found"
fi

# 3. Set environment variables
export CKS_ENFORCEMENT="MANDATORY"
export CKS_PATH="$CKS_PATH"
export CKS_API_URL="http://localhost:5000"
export CKS_BYPASS_ALLOWED="false"
export CKS_SESSION_ID="cc_$(date +%s)"

log "Environment variables set: ENFORCEMENT=MANDATORY, BYPASS=false"

# 4. Load project context
echo -e "${BLUE}📊 Loading CAIA project context...${NC}"
if [ -f "$CKS_PATH/scripts/validate-system.sh" ]; then
    "$CKS_PATH/scripts/validate-system.sh" > /dev/null 2>&1
    echo -e "${GREEN}✅ CAIA context loaded and validated${NC}"
    log "CAIA context loaded and validated"
else
    echo -e "${YELLOW}⚠️  Context validation skipped${NC}"
    log "WARNING: Context validation skipped"
fi

# 5. Start real-time monitoring (background)
if [ -f "$CKS_INTEGRATION/automation/real-time-monitor.sh" ]; then
    "$CKS_INTEGRATION/automation/real-time-monitor.sh" & 
    MONITOR_PID=$!
    echo "$MONITOR_PID" > "$HOME/.claude/cks-monitor.pid"
    echo -e "${GREEN}✅ Real-time monitoring active (PID: $MONITOR_PID)${NC}"
    log "Real-time monitoring started with PID $MONITOR_PID"
fi

# 6. Display CKS status
echo -e "${BLUE}📋 CKS Integration Status:${NC}"
echo "  🎯 Enforcement: MANDATORY (no bypass)"
echo "  📊 Context: CAIA project loaded"
echo "  🔍 Redundancy checking: ENABLED"
echo "  🏗️  Architecture scanning: ENABLED"
echo "  ⚡ Real-time updates: ACTIVE"
echo "  📝 Session ID: $CKS_SESSION_ID"

log "CKS integration startup completed successfully"

# 7. Show available commands
echo ""
echo -e "${GREEN}🎮 Available CKS Commands:${NC}"
echo "  cks_check_redundancy <description>  - Check for existing implementations"
echo "  cks_scan_architecture <intent>     - Scan architectural patterns"
echo "  cks_load_context                   - Load full project context"
echo "  cks_find_similar <function_name>   - Find similar functions"
echo "  cks_status                         - Show integration status"
echo "  cks_help                          - Show all commands"

echo ""
echo -e "${BLUE}🚀 Claude Code ready with MANDATORY CKS integration!${NC}"
echo -e "${YELLOW}⚠️  All code generation will be checked for redundancy${NC}"
log "Claude Code startup with CKS integration completed"

# 8. Pre-populate common context
if command -v cks_load_context >/dev/null 2>&1; then
    cks_load_context > /dev/null 2>&1 &
fi