#!/bin/bash

# CKS Enforcement Engine - Mandatory Integration with Decision Logging
# This script enforces CKS usage and logs all decisions

set -e

# Configuration
CKS_PATH="/Users/MAC/Documents/projects/caia/knowledge-system"
DECISION_LOGGER="/Users/MAC/Documents/projects/admin/scripts/log_decision.py"
LOG_FILE="/Users/MAC/.claude/cks-enforcement.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging function
log_decision() {
    local type="$1"
    local title="$2" 
    local description="$3"
    local category="$4"
    
    if [ -f "$DECISION_LOGGER" ]; then
        python3 "$DECISION_LOGGER" \
            --type "$type" \
            --title "$title" \
            --description "$description" \
            --project "caia" \
            --category "$category" \
            --tags "cks-integration" "claude-code"
    fi
}

# Enforce redundancy checking
enforce_redundancy_check() {
    local task_description="$1"
    local context="$2"
    
    echo -e "${BLUE}🔍 CKS: Checking for redundancy...${NC}"
    
    # Run redundancy check
    if [ -f "$CKS_PATH/cli/knowledge_cli.py" ]; then
        local result=$(python3 "$CKS_PATH/cli/knowledge_cli.py" check-redundancy "$task_description" 2>/dev/null || echo "UNIQUE")
        
        if [[ "$result" == *"REDUNDANT"* ]] || [[ "$result" == *"SIMILAR"* ]]; then
            echo -e "${RED}⚠️  REDUNDANCY DETECTED!${NC}"
            echo -e "${YELLOW}Similar implementations found:${NC}"
            echo "$result"
            
            # Log the redundancy detection
            log_decision "decision" \
                "Redundancy detected: $task_description" \
                "CKS found similar implementations. Details: $result" \
                "redundancy-prevention"
            
            echo -e "${YELLOW}🛡️  Do you want to proceed anyway? (y/N)${NC}"
            read -r response
            if [[ ! "$response" =~ ^[Yy]$ ]]; then
                echo -e "${RED}❌ Implementation blocked by CKS enforcement${NC}"
                log_decision "decision" \
                    "Implementation blocked: $task_description" \
                    "User chose to abort implementation due to redundancy" \
                    "enforcement"
                exit 1
            else
                log_decision "decision" \
                    "Redundancy override: $task_description" \
                    "User chose to proceed despite redundancy warning" \
                    "override"
            fi
        else
            echo -e "${GREEN}✅ No redundancy detected - proceeding${NC}"
            log_decision "progress" \
                "Unique implementation approved: $task_description" \
                "CKS confirmed no similar implementations exist" \
                "validation"
        fi
    else
        echo -e "${YELLOW}⚠️  CKS CLI not available, proceeding with warning${NC}"
    fi
}

# Enforce architecture scanning
enforce_architecture_scan() {
    local design_intent="$1"
    local context="$2"
    
    echo -e "${BLUE}🏗️  CKS: Scanning architectural patterns...${NC}"
    
    # Scan for architectural patterns
    if [ -f "$CKS_PATH/cli/knowledge_cli.py" ]; then
        local patterns=$(python3 "$CKS_PATH/cli/knowledge_cli.py" scan-architecture "$design_intent" 2>/dev/null || echo "NO_PATTERNS")
        
        if [[ "$patterns" != "NO_PATTERNS" ]] && [[ "$patterns" != "" ]]; then
            echo -e "${GREEN}📊 Existing patterns found:${NC}"
            echo "$patterns"
            
            log_decision "decision" \
                "Architecture patterns identified: $design_intent" \
                "CKS found relevant patterns: $patterns" \
                "architecture"
        else
            echo -e "${YELLOW}🆕 New architectural pattern - ensure documentation${NC}"
            log_decision "decision" \
                "New architectural pattern: $design_intent" \
                "CKS detected new architectural approach - requires documentation" \
                "architecture"
        fi
    fi
}

# Enforce capability search
enforce_capability_search() {
    local suggestion_context="$1"
    local task_type="$2"
    
    echo -e "${BLUE}🔎 CKS: Searching existing capabilities...${NC}"
    
    # Search for existing capabilities
    if [ -f "$CKS_PATH/cli/knowledge_cli.py" ]; then
        local capabilities=$(python3 "$CKS_PATH/cli/knowledge_cli.py" list-capabilities "$suggestion_context" 2>/dev/null || echo "NONE")
        
        if [[ "$capabilities" != "NONE" ]] && [[ "$capabilities" != "" ]]; then
            echo -e "${GREEN}🛠️  Existing capabilities found:${NC}"
            echo "$capabilities"
            
            log_decision "progress" \
                "Existing capabilities identified: $suggestion_context" \
                "CKS found relevant capabilities: $capabilities" \
                "capability-reuse"
        else
            echo -e "${YELLOW}✨ New capability needed${NC}"
            log_decision "progress" \
                "New capability required: $suggestion_context" \
                "CKS found no existing capabilities for this task" \
                "capability-gap"
        fi
    fi
}

# Main enforcement function
main() {
    local action="$1"
    local context="$2"
    local description="$3"
    
    echo -e "${BLUE}🤖 CKS Enforcement Engine${NC}"
    echo "Action: $action"
    echo "Context: $context"
    echo ""
    
    case "$action" in
        "check-redundancy")
            enforce_redundancy_check "$description" "$context"
            ;;
        "scan-architecture")
            enforce_architecture_scan "$description" "$context"
            ;;
        "search-capabilities")
            enforce_capability_search "$description" "$context"
            ;;
        "full-check")
            enforce_redundancy_check "$description" "$context"
            enforce_architecture_scan "$description" "$context"
            enforce_capability_search "$description" "$context"
            ;;
        *)
            echo -e "${RED}Unknown enforcement action: $action${NC}"
            exit 1
            ;;
    esac
    
    echo -e "${GREEN}✅ CKS enforcement completed${NC}"
    echo ""
}

# Execute if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi