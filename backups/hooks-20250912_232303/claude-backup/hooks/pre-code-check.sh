#!/bin/bash

# ============================================================================
# AUTOMATIC CKS CHECK BEFORE CODE GENERATION
# This hook runs automatically to check for duplicates
# ============================================================================

# Function to extract task from context
extract_task() {
    # Try to get from environment or arguments
    local TASK="${CODE_TASK:-$1}"
    
    # Common patterns to extract
    if [[ "$TASK" == *"implement"* ]] || [[ "$TASK" == *"create"* ]] || [[ "$TASK" == *"build"* ]]; then
        echo "$TASK" | sed 's/.*implement\|create\|build//i' | head -c 50
    else
        echo "$TASK" | head -c 50
    fi
}

# Get the task/feature being implemented
TASK=$(extract_task "$@")

if [ -n "$TASK" ]; then
    # Log the check
    echo "[$(date '+%H:%M:%S')] Pre-check: $TASK" >> /tmp/cks_checks.log
    
    # Run CKS check
    RESULT=$(/Users/MAC/.claude/cks-check "$TASK" 2>/dev/null | tail -5)
    
    # Store result for CC to see
    echo "$RESULT" > /tmp/last_cks_check.txt
fi

exit 0