#!/bin/bash

# Parallel Execution Enforcement Hook
# This hook MUST be called before ANY implementation task

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Configuration
ENFORCEMENT_LOG="/tmp/cc-parallel-enforcement.log"
DECOMPOSITION_LOG="/tmp/cc-decomposition.log"
BYPASS_FILE="/tmp/cc-parallel-bypass"
MIN_PHASES_FOR_PARALLEL=2

# Log enforcement check
log_enforcement() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$ENFORCEMENT_LOG"
}

# Check if task requires implementation
requires_implementation() {
    local task="$1"
    local triggers=(
        "implement" "build" "create" "add" "develop"
        "write" "code" "feature" "function" "component"
        "api" "endpoint" "service" "model" "controller"
        "crud" "test" "fix" "refactor" "update"
    )
    
    task_lower=$(echo "$task" | tr '[:upper:]' '[:lower:]')
    
    for trigger in "${triggers[@]}"; do
        if [[ "$task_lower" == *"$trigger"* ]]; then
            return 0
        fi
    done
    
    return 1
}

# Check if decomposition was performed
check_decomposition() {
    if [ ! -f "$DECOMPOSITION_LOG" ]; then
        return 1
    fi
    
    # Check if decomposition is recent (within last hour)
    if [ -f "$DECOMPOSITION_LOG" ]; then
        local timestamp=$(jq -r '.timestamp' "$DECOMPOSITION_LOG" 2>/dev/null || echo "0")
        local now=$(date +%s000)
        local age=$((now - timestamp))
        
        if [ $age -gt 3600000 ]; then # 1 hour in milliseconds
            return 1
        fi
        
        return 0
    fi
    
    return 1
}

# Main enforcement logic
enforce_parallel() {
    local task_description="$1"
    
    # Check if bypass is enabled (only for explicit user override)
    if [ -f "$BYPASS_FILE" ]; then
        log_enforcement "BYPASS: Parallel enforcement disabled"
        rm -f "$BYPASS_FILE"
        return 0
    fi
    
    # Check if task requires implementation
    if ! requires_implementation "$task_description"; then
        log_enforcement "SKIP: Task doesn't require implementation"
        return 0
    fi
    
    # Check if decomposition was already performed
    if check_decomposition; then
        log_enforcement "PASS: Decomposition already performed"
        return 0
    fi
    
    # ENFORCEMENT: Decomposition required
    echo -e "${RED}${BOLD}🚨 PARALLEL DECOMPOSITION REQUIRED${NC}"
    echo "=================================================="
    echo -e "${YELLOW}Task: ${NC}$task_description"
    echo ""
    echo -e "${RED}You MUST decompose this task before proceeding!${NC}"
    echo ""
    echo -e "${GREEN}Run this command:${NC}"
    echo -e "${BOLD}cco-decompose \"$task_description\" --auto${NC}"
    echo ""
    echo -e "${YELLOW}Or quick mode:${NC}"
    echo -e "${BOLD}cco-decompose quick \"$task_description\"${NC}"
    echo ""
    echo "=================================================="
    
    log_enforcement "BLOCKED: Decomposition required for: $task_description"
    
    # Auto-run decomposition if CCO is available
    if command -v cco-decompose &> /dev/null; then
        echo -e "${GREEN}Auto-running decomposition...${NC}"
        cco-decompose quick "$task_description"
    else
        echo -e "${RED}Please install CCO first:${NC}"
        echo "cd /Users/MAC/Documents/projects/caia/caia/packages/utils/cc-orchestrator"
        echo "npm install && npm run build"
        echo "npm link"
    fi
    
    return 1
}

# Monitor and suggest parallelization
suggest_parallel() {
    local current_task="$1"
    
    echo -e "${BLUE}${BOLD}💡 PARALLEL OPPORTUNITY DETECTED${NC}"
    echo "=================================="
    echo "This task can be parallelized for faster execution!"
    echo ""
    echo "Suggested decomposition:"
    
    # Quick analysis
    if [[ "$current_task" == *"crud"* ]] || [[ "$current_task" == *"CRUD"* ]]; then
        echo "  • Create operation (15 min)"
        echo "  • Read operation (15 min)"
        echo "  • Update operation (15 min)"
        echo "  • Delete operation (15 min)"
        echo ""
        echo -e "${GREEN}Potential speedup: 4x${NC}"
    elif [[ "$current_task" == *"frontend"* ]] && [[ "$current_task" == *"backend"* ]]; then
        echo "  • Frontend components (30 min)"
        echo "  • Backend API (30 min)"
        echo "  • Database layer (20 min)"
        echo ""
        echo -e "${GREEN}Potential speedup: 3x${NC}"
    else
        echo "  • Multiple independent phases detected"
        echo -e "${GREEN}Run decomposition for detailed analysis${NC}"
    fi
    
    echo ""
    echo -e "${BOLD}Run: cco-decompose \"$current_task\"${NC}"
}

# Export functions for use in other scripts
export -f enforce_parallel
export -f suggest_parallel
export -f check_decomposition

# If called directly with arguments
if [ $# -gt 0 ]; then
    enforce_parallel "$*"
fi