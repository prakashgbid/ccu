#!/bin/bash
#
# Simple wrapper for CC to log operations with attribution
# Usage: cc_log.sh <action_type> <details> [tool] [project]
#

LOGGER="$HOME/.claude/enhanced_verbose_logger.py"

# Function to auto-detect tool from current command
auto_detect_tool() {
    # Check command history for recent tool usage
    local last_cmd=$(history 1 2>/dev/null | sed 's/^[ ]*[0-9]*[ ]*//')
    
    # Pattern matching for tools
    if [[ "$last_cmd" == *"cco"* ]] || [[ "$last_cmd" == *"cc-orchestrator"* ]]; then
        echo "cc-orchestrator"
    elif [[ "$last_cmd" == *"cks"* ]] || [[ "$last_cmd" == *"knowledge"* ]]; then
        echo "knowledge-system"
    elif [[ "$last_cmd" == *"integration-agent"* ]]; then
        echo "integration-agent"
    elif [[ "$last_cmd" == *"log_decision"* ]]; then
        echo "log_decision.py"
    elif [[ "$last_cmd" == *"git"* ]]; then
        echo "git"
    elif [[ "$last_cmd" == *"npm"* ]] || [[ "$last_cmd" == *"pnpm"* ]]; then
        echo "package-manager"
    else
        echo ""
    fi
}

# Function to detect project from PWD
auto_detect_project() {
    if [[ "$PWD" == *"caia"* ]]; then
        echo "caia"
    elif [[ "$PWD" == *"claude-code-ultimate"* ]]; then
        echo "ccu"
    elif [[ "$PWD" == *"roulette"* ]]; then
        echo "roulette"
    elif [[ "$PWD" == *"admin"* ]]; then
        echo "admin"
    else
        echo ""
    fi
}

# Main logging logic
ACTION_TYPE="${1:-INFO}"
DETAILS="${2:-No details provided}"
TOOL="${3:-$(auto_detect_tool)}"
PROJECT="${4:-$(auto_detect_project)}"

# Call the Python logger
python3 "$LOGGER" log "$ACTION_TYPE" "$DETAILS" "$TOOL" "$PROJECT"

# Also echo to console for immediate feedback
echo "[CC-LOG] [$ACTION_TYPE] $DETAILS" >&2