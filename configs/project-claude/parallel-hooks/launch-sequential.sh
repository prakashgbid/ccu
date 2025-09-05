#!/bin/bash
# Sequential Launch System for CC Hook Development Instances
# Proper terminal → CC → context → monitoring flow

echo "🚀 SEQUENTIAL CC INSTANCE LAUNCH SYSTEM"
echo "========================================"
echo ""
echo "✅ Proper Flow:"
echo "   1. Create terminal → Wait for initialization"
echo "   2. Launch CC → Wait for ready state"
echo "   3. Provide detailed context → Monitor continuously"
echo ""

SHARED_PATH="/Users/MAC/Documents/projects/.claude/parallel-hooks/shared"
INSTANCES_PATH="/Users/MAC/Documents/projects/.claude/parallel-hooks/instances"
PROJECT_PATH="/Users/MAC/Documents/projects"

# Ensure shared directories exist
mkdir -p "$SHARED_PATH"/{logs,state,events,config}
mkdir -p "$INSTANCES_PATH"

# Hook category definitions
declare -a HOOK_CATEGORIES=(
    "cc1-cognitive:🧠 COGNITIVE & AWARENESS HOOKS"
    "cc2-cks:🔗 CKS INTEGRATION & COMMUNICATION HOOKS" 
    "cc3-quality:🔍 CODE QUALITY & REUSE ENFORCEMENT HOOKS"
    "cc4-project:🎯 PROJECT AWARENESS & CAIA CONTEXT HOOKS"
    "cc5-health:🏥 HEALTH MONITORING & MAINTENANCE HOOKS"
    "cc6-enhancement:💡 SUGGESTION ENGINE & LEARNING HOOKS"
    "cc7-professional:👔 SYSTEMATIC BEHAVIOR & PROFESSIONALISM HOOKS"
    "cc8-coordination:🎛️ COORDINATION HUB & ORCHESTRATION HOOKS"
)

launch_cc_instance_sequential() {
    local instance_spec="$1"
    local instance_id=$(echo "$instance_spec" | cut -d: -f1)
    local description=$(echo "$instance_spec" | cut -d: -f2-)
    
    echo ""
    echo "🚀 LAUNCHING: $instance_id"
    echo "📋 DESCRIPTION: $description"
    echo ""
    
    # Create instance directory
    mkdir -p "$INSTANCES_PATH/$instance_id"
    
    # Step 1: Create terminal and wait for initialization
    echo "📱 Step 1: Creating terminal..."
    osascript << EOF
tell application "Terminal"
    set newWindow to do script "cd '$PROJECT_PATH' && echo '🎯 Terminal for $instance_id created. Waiting for CC launch...' && echo ''"
    set name of newWindow to "$instance_id Terminal"
end tell
EOF
    
    echo "⏳ Waiting 3 seconds for terminal initialization..."
    sleep 3
    
    # Step 2: Launch CC and wait for ready state
    echo "🤖 Step 2: Launching CC instance..."
    osascript << EOF
tell application "Terminal"
    tell window "$instance_id Terminal"
        do script "echo '🚀 Launching Claude Code for $instance_id...' && claude --session-id 'hook-$instance_id'" in it
    end tell
end tell
EOF
    
    echo "⏳ Waiting 10 seconds for CC to initialize..."
    sleep 10
    
    # Step 3: We'll handle context provision manually for now
    echo "✅ Instance $instance_id launched successfully"
    echo "📋 Next: Provide detailed context manually in the terminal"
    echo "🖥️  Terminal name: '$instance_id Terminal'"
    echo ""
    
    return 0
}

# Interactive launch
echo "🎯 This will launch ONE instance at a time with proper sequencing"
echo "📝 You'll need to provide context to each CC instance manually"
echo ""
read -p "Which instance to launch first? (1-8 or 'all' for sequential): " choice

case $choice in
    1) launch_cc_instance_sequential "${HOOK_CATEGORIES[0]}" ;;
    2) launch_cc_instance_sequential "${HOOK_CATEGORIES[1]}" ;;
    3) launch_cc_instance_sequential "${HOOK_CATEGORIES[2]}" ;;
    4) launch_cc_instance_sequential "${HOOK_CATEGORIES[3]}" ;;
    5) launch_cc_instance_sequential "${HOOK_CATEGORIES[4]}" ;;
    6) launch_cc_instance_sequential "${HOOK_CATEGORIES[5]}" ;;
    7) launch_cc_instance_sequential "${HOOK_CATEGORIES[6]}" ;;
    8) launch_cc_instance_sequential "${HOOK_CATEGORIES[7]}" ;;
    "all")
        echo "🚀 Launching all instances sequentially with 30-second intervals..."
        for i in "${!HOOK_CATEGORIES[@]}"; do
            launch_cc_instance_sequential "${HOOK_CATEGORIES[$i]}"
            if [ $i -lt $((${#HOOK_CATEGORIES[@]} - 1)) ]; then
                echo "⏳ Waiting 30 seconds before next instance..."
                sleep 30
            fi
        done
        ;;
    *)
        echo "❌ Invalid choice. Use 1-8 or 'all'"
        exit 1
        ;;
esac

echo ""
echo "✅ LAUNCH COMPLETE"
echo ""
echo "📋 NEXT STEPS:"
echo "1. Switch to each terminal and verify CC is ready (shows prompt)"
echo "2. Provide detailed context and task assignment"
echo "3. Monitor progress and provide guidance as needed"
echo ""
echo "🖥️  Terminal names: '<instance-id> Terminal'"
echo "📊 Progress tracking: cat $SHARED_PATH/state/progress.json"