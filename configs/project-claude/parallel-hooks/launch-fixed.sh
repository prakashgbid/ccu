#!/bin/bash
# Fixed Master Launch Script for 8 Parallel CC Instances

echo "🚀 LAUNCHING PARALLEL HOOK IMPLEMENTATION SYSTEM"
echo "═══════════════════════════════════════════════════"
echo ""
echo "🎯 Mission: Transform Claude Code into Systematic AI Professional"
echo "📊 Deploying: 8 Specialized CC Instances"
echo "🔧 Total Hooks: 64 across 8 categories"
echo ""

# Configuration paths
SHARED_PATH="/Users/MAC/Documents/projects/.claude/parallel-hooks/shared"
PROJECT_PATH="/Users/MAC/Documents/projects"
INSTANCES_PATH="/Users/MAC/Documents/projects/.claude/parallel-hooks/instances"

# Launch function that handles one instance at a time
launch_instance() {
    local instance_id="$1"
    local assignment="$2"
    local color_name="$3"
    
    echo "🚀 Launching $instance_id..."
    echo "📋 Assignment: $assignment"
    
    # Create instance directory
    mkdir -p "$INSTANCES_PATH/$instance_id"
    
    # Create environment file
    cat > "$INSTANCES_PATH/$instance_id/env.sh" << 'ENV_EOF'
export CC_INSTANCE_ID="$1"
export CC_SHARED_PATH="/Users/MAC/Documents/projects/.claude/parallel-hooks/shared"
export CC_SESSION_ID="hook-$1-$(date +%s)"
ENV_EOF
    
    # Use simpler terminal launch approach
    osascript -e "tell application \"Terminal\" to do script \"cd '$PROJECT_PATH' && echo '🤖 CC Instance: $instance_id' && echo '🎯 Mission: $assignment' && claude --model opusplan --session-id 'hook-$instance_id' '$assignment Work systematically on your assigned hook category. Create comprehensive, production-ready hook implementations. Log progress to shared filesystem at $SHARED_PATH.'\""
    
    sleep 2
    echo "   ✅ Launched $instance_id"
    echo ""
}

echo "🎯 Launching specialized CC instances..."
echo ""

# Launch each instance individually
launch_instance "cc1-cognitive" "COGNITIVE HOOKS: Implement thinking transparency, intent prediction, and meta-learning hooks for systematic AI reasoning" "red"

launch_instance "cc2-cks" "CKS INTEGRATION HOOKS: Implement knowledge system integration, duplicate detection, and architectural alignment hooks" "green"

launch_instance "cc3-quality" "CODE QUALITY HOOKS: Implement reuse enforcement, pattern matching, and anti-duplication hooks for code quality" "yellow"

launch_instance "cc4-project" "PROJECT AWARENESS HOOKS: Implement CAIA context awareness, component registry, and project state monitoring hooks" "blue"

launch_instance "cc5-health" "HEALTH MONITORING HOOKS: Implement performance monitoring, security auditing, and proactive maintenance hooks" "magenta"

launch_instance "cc6-enhancement" "SUGGESTION ENGINE HOOKS: Implement learning-based recommendations, workflow optimization, and innovation hooks" "cyan"

launch_instance "cc7-professional" "PROFESSIONAL STANDARDS HOOKS: Implement systematic behavior, quality gates, and best practice enforcement hooks" "white"

launch_instance "cc8-coordination" "COORDINATION HOOKS: Implement hook orchestration, event coordination, and integration testing hooks" "bright-yellow"

echo ""
echo "✅ ALL 8 CC INSTANCES LAUNCHED!"
echo ""
echo "📊 Monitor Progress:"
echo "   ./monitor-progress.sh"
echo ""
echo "📋 Check Active Instances:"
echo "   ps aux | grep claude"
echo ""
echo "🔍 View Event Stream:"
echo "   tail -f shared/events/hook-events.jsonl"
echo ""
echo "🚀 PARALLEL HOOK DEVELOPMENT IS NOW ACTIVE!"