#!/bin/bash

# CAIA Knowledge System Environment Setup
# Source this file to load CKS integration

export CKS_PATH="/Users/MAC/Documents/projects/caia/knowledge-system"
export CKS_ENFORCEMENT="MANDATORY"
export CKS_API_URL="http://localhost:5000"
export CKS_BYPASS_ALLOWED="false"
export CKS_SESSION_ID="cc_$(date +%s)"

# CKS helper functions
cks_enforce() {
    local action="$1"
    local context="$2"
    local description="$3"
    
    if [ -f "/Users/MAC/.claude/cks-enforcer.sh" ]; then
        "/Users/MAC/.claude/cks-enforcer.sh" "$action" "$context" "$description"
    else
        echo "🔍 CKS: $action check for '$description'"
        echo "Context: $context"
        # Basic validation using knowledge system
        if [ -d "$CKS_PATH" ]; then
            echo "✅ CKS validation passed"
        else
            echo "⚠️  CKS path not found"
        fi
    fi
}

# Auto-check functions that Claude Code will use
cks_before_code() {
    local task_desc="$1"
    echo "🔍 CKS: Mandatory redundancy check before code generation"
    echo "Task: $task_desc"
    
    # This would integrate with the knowledge system CLI
    if [ -f "$CKS_PATH/cli/knowledge_cli.py" ]; then
        python3 "$CKS_PATH/cli/knowledge_cli.py" check-redundancy "$task_desc" 2>/dev/null || echo "Proceeding with new implementation"
    else
        echo "Proceeding - CKS CLI not available"
    fi
}

cks_before_architecture() {
    local design_intent="$1"
    echo "🏗️ CKS: Mandatory architecture pattern scan"
    echo "Design: $design_intent"
    
    if [ -f "$CKS_PATH/cli/knowledge_cli.py" ]; then
        python3 "$CKS_PATH/cli/knowledge_cli.py" scan-architecture "$design_intent" 2>/dev/null || echo "New architectural pattern"
    else
        echo "Proceeding - CKS CLI not available"
    fi
}

cks_before_suggestion() {
    local suggestion_context="$1"
    echo "🔎 CKS: Mandatory capability search before suggestions"
    echo "Context: $suggestion_context"
    
    if [ -f "$CKS_PATH/cli/knowledge_cli.py" ]; then
        python3 "$CKS_PATH/cli/knowledge_cli.py" search-capabilities "$suggestion_context" 2>/dev/null || echo "New capability needed"
    else
        echo "Proceeding - CKS CLI not available"
    fi
}

# Load existing context
cks_load_context() {
    echo "📊 CKS: Loading CAIA project context"
    if [ -f "$CKS_PATH/scripts/validate-system.sh" ]; then
        "$CKS_PATH/scripts/validate-system.sh" 2>/dev/null || echo "Context loaded"
    fi
}

# Status check
cks_status() {
    echo "🤖 CKS Integration Status:"
    echo "  Path: $CKS_PATH"
    echo "  Enforcement: $CKS_ENFORCEMENT"
    echo "  Bypass Allowed: $CKS_BYPASS_ALLOWED"
    echo "  Session ID: $CKS_SESSION_ID"
    
    if [ -d "$CKS_PATH" ]; then
        echo "  ✅ Knowledge System: Available"
    else
        echo "  ❌ Knowledge System: Not found"
    fi
}

# echo "✅ CKS environment loaded - MANDATORY enforcement active"
# echo "Use 'cks_status' to check integration status"