#!/bin/bash

# ============================================================
# CC WORKFLOW INITIALIZATION SCRIPT
# Run this at the start of every Claude Code session
# Usage: source ~/.claude/init-cc-workflow.sh
# ============================================================

echo "🚀 INITIALIZING CC WORKFLOW SYSTEM"
echo "============================================================"

# 1. LOAD CKS CONTEXT
echo "📚 [1/7] Loading CAIA Knowledge System Context..."
if [ -f "/Users/MAC/Documents/projects/caia/knowledge-system/cli/knowledge_cli.py" ]; then
    python3 /Users/MAC/Documents/projects/caia/knowledge-system/cli/knowledge_cli.py stats 2>/dev/null || echo "   ⚠️  CKS not fully initialized"
else
    echo "   ❌ CKS not found"
fi

# 2. CHECK CC ORCHESTRATOR
echo "🎯 [2/7] Checking CC Orchestrator Status..."
export CCO_PATH="/Users/MAC/Documents/projects/caia/utils/parallel/cc-orchestrator/src/index.js"
export CCO_AUTO_INVOKE=true
export CCO_AUTO_CALCULATE=true
if [ -f "$CCO_PATH" ]; then
    echo "   ✅ CCO Ready (Auto-invoke: ON, Auto-calculate: ON)"
else
    echo "   ❌ CCO not found"
fi

# 3. VERIFY INTEGRATION AGENT
echo "🔌 [3/7] Verifying Integration Agent..."
export INTEGRATION_AGENT_PATH="/Users/MAC/Documents/projects/caia/packages/agents/integration-agent"
if [ -d "$INTEGRATION_AGENT_PATH" ]; then
    echo "   ✅ Integration Agent Ready"
    echo "   📝 Services: jira, github, slack, figma, openai, anthropic"
else
    echo "   ❌ Integration Agent not found"
fi

# 4. SET PARALLEL EXECUTION SETTINGS
echo "⚡ [4/7] Configuring Parallel Execution..."
export MAX_PARALLEL=50
export PARALLEL_JOBS=50
export MAKEFLAGS="-j50"
export CKS_ENFORCEMENT=MANDATORY
export CKS_BYPASS_ALLOWED=false
echo "   ✅ Parallel Mode: 50 workers"
echo "   ✅ CKS Enforcement: MANDATORY"

# 5. LOAD WORKFLOW RULES
echo "📋 [5/7] Loading Workflow Rules..."
cat << 'WORKFLOW_RULES'

============================================================
🚨 MANDATORY WORKFLOW - MUST FOLLOW FOR EVERY TASK
============================================================

1️⃣ BEFORE ANY CODE - CKS Check:
   python3 $CKS_PATH/cli/knowledge_cli.py check-redundancy "task"
   
2️⃣ BEFORE DESIGN - Architecture Scan:
   python3 $CKS_PATH/cli/knowledge_cli.py scan-architecture "design"
   
3️⃣ DECOMPOSE - Parallel Phases:
   - Break into smallest independent units
   - Show decomposition to user
   - Get approval for parallel execution
   
4️⃣ EXTERNAL SERVICES - Integration Agent Only:
   const IntegrationAgent = require('@caia/integration-agent');
   const agent = new IntegrationAgent();
   const jira = await agent.connect('jira');
   
5️⃣ EXECUTE - Launch Parallel CC:
   cco launch-parallel --features features.json
   
6️⃣ AFTER CODE - Update CKS:
   python3 $CKS_PATH/cli/knowledge_cli.py update-knowledge --files "changed_files"

============================================================
❌ FORBIDDEN:
- Direct API calls (axios, fetch)
- Sequential coding when parallel possible
- Skipping CKS checks
- Creating without checking existing

✅ MANDATORY:
- Parallel-first approach
- Integration Agent for all external
- CKS check before implementation
- Decompose everything

============================================================
WORKFLOW_RULES

# 6. CREATE QUICK COMMANDS
echo "🔧 [6/7] Setting Up Quick Commands..."
cat << 'COMMANDS' > /tmp/cc-workflow-commands.txt

QUICK COMMANDS FOR THIS SESSION:
--------------------------------
cks_check() { python3 $CKS_PATH/cli/knowledge_cli.py check-redundancy "$1"; }
cks_scan() { python3 $CKS_PATH/cli/knowledge_cli.py scan-architecture "$1"; }
cks_update() { python3 $CKS_PATH/cli/knowledge_cli.py update-knowledge --files "$1"; }
cco_analyze() { node $CCO_PATH analyze; }
cco_launch() { node $CCO_PATH launch-parallel --features "$1"; }
parallel_decompose() { echo "Task: $1" | node $CCO_PATH decompose; }

To use: Just type the command name with argument
Example: cks_check "booking system"
COMMANDS

# 7. SHOW CURRENT PROJECT STATUS
echo "📊 [7/7] Loading Project Context..."
if [ -f "/Users/MAC/Documents/projects/admin/scripts/quick_status.sh" ]; then
    /Users/MAC/Documents/projects/admin/scripts/quick_status.sh 2>/dev/null | head -20
else
    echo "   ⚠️  Admin scripts not found"
fi

# Create reminder file
cat << 'REMINDER' > /tmp/cc-session-workflow.md
# 🚨 CC SESSION WORKFLOW ACTIVE

## For EVERY Task:
1. CHECK: Has this been built before? (CKS)
2. SCAN: What patterns exist? (CKS) 
3. DECOMPOSE: Break into parallel phases
4. APPROVE: Get user OK for parallel
5. EXECUTE: Launch parallel CC instances
6. UPDATE: Save to knowledge base

## Commands Available:
- cks_check "description"
- cks_scan "architecture"
- parallel_decompose "task"
- cco_launch features.json

## Rules:
- NO direct API calls
- NO sequential if parallel possible
- ALWAYS check CKS first
- ALWAYS use Integration Agent
REMINDER

echo ""
echo "============================================================"
echo "✅ CC WORKFLOW SYSTEM INITIALIZED"
echo "============================================================"
echo ""
echo "📝 Workflow saved to: /tmp/cc-session-workflow.md"
echo "📋 Commands saved to: /tmp/cc-workflow-commands.txt"
echo ""
echo "🎯 REMEMBER: Check CKS → Decompose → Parallel → Integration Agent"
echo ""
echo "Type 'cat /tmp/cc-session-workflow.md' to see workflow"
echo "Type 'cat /tmp/cc-workflow-commands.txt' to see commands"
echo "============================================================"

# Export functions for the session
export -f cks_check 2>/dev/null
export -f cks_scan 2>/dev/null
export -f cks_update 2>/dev/null
export -f cco_analyze 2>/dev/null
export -f cco_launch 2>/dev/null
export -f parallel_decompose 2>/dev/null

# Set session marker
export CC_WORKFLOW_LOADED=true
export CC_WORKFLOW_TIME=$(date +%Y%m%d_%H%M%S)

echo ""
echo "🔥 Ready to work with MANDATORY workflow rules!"
echo "============================================================"