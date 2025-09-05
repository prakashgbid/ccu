#!/bin/bash
# CILS (Comprehensive Interaction Learning System) Hook
# Captures every interaction between user and Claude Code for learning
# Auto-installed hook for CC Enhancement

CILS_PYTHON_PATH="/Users/MAC/Documents/projects/caia/knowledge-system/learning/interaction_learner.py"
CILS_LOG="/Users/MAC/.claude/logs/cils_interactions.log"
TEMP_DIR="/tmp/cils_capture"

# Create directories if they don't exist
mkdir -p "$(dirname "$CILS_LOG")" "$TEMP_DIR"

# Function to capture interaction
capture_interaction() {
    local interaction_type="$1"
    local content="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Log to file for backup
    echo "[$timestamp][$interaction_type] $content" >> "$CILS_LOG"
    
    # Create temp files for Python processing
    local temp_file="$TEMP_DIR/interaction_$$_$(date +%s).json"
    
    cat > "$temp_file" << EOF
{
    "timestamp": "$timestamp",
    "type": "$interaction_type",
    "content": $(echo "$content" | python3 -c "import json, sys; print(json.dumps(sys.stdin.read()))")
}
EOF
    
    # Process through CILS in background (non-blocking)
    if [ -f "$CILS_PYTHON_PATH" ]; then
        (python3 "$CILS_PYTHON_PATH" capture "$temp_file" 2>/dev/null && rm -f "$temp_file") &
    fi
}

# Function to detect correction patterns
detect_correction() {
    local user_input="$1"
    
    # Common correction indicators
    local correction_patterns=(
        "\b(no|not|don't|stop|wrong|actually|instead)\b"
        "\b(should|shouldn't|must|never|always)\b"
        "\b(but|however|rather|correction)\b"
        "\b(as I said|I told you|remember|again)\b"
    )
    
    for pattern in "${correction_patterns[@]}"; do
        if echo "$user_input" | grep -qiE "$pattern"; then
            return 0  # Correction detected
        fi
    done
    
    return 1  # No correction
}

# Function to extract preferences
extract_preference() {
    local user_input="$1"
    
    # Look for preference indicators
    if echo "$user_input" | grep -qiE "\b(prefer|like|want|always|never|use|don't)\b"; then
        capture_interaction "preference_detected" "$user_input"
        
        # Trigger immediate learning
        if [ -f "$CILS_PYTHON_PATH" ]; then
            echo "$user_input" | python3 -c "
import sys
sys.path.append('$(dirname "$CILS_PYTHON_PATH")')
from interaction_learner import InteractionLearner
learner = InteractionLearner()
request = sys.stdin.read().strip()
learner.capture_interaction(request, '', 'preference')
print('Preference learned')
" 2>/dev/null &
        fi
    fi
}

# Function to check for repeated tasks
check_repeated_task() {
    local user_input="$1"
    
    if [ -f "$CILS_PYTHON_PATH" ]; then
        python3 -c "
import sys
sys.path.append('$(dirname "$CILS_PYTHON_PATH")')
from interaction_learner import InteractionLearner
learner = InteractionLearner()
result = learner.check_for_repeated_task('$user_input')
if result and result.get('frequency', 0) > 2:
    print('REPEATED_TASK_DETECTED:' + str(result['frequency']))
" 2>/dev/null
    fi
}

# Main hook functions
on_user_prompt_submit() {
    local user_input="$1"
    
    # Always capture the interaction
    capture_interaction "user_prompt" "$user_input"
    
    # Check for corrections
    if detect_correction "$user_input"; then
        capture_interaction "correction_detected" "$user_input"
        echo "🔍 CILS: Learning from correction..."
    fi
    
    # Extract preferences
    extract_preference "$user_input"
    
    # Check for repeated tasks
    local repeated_check=$(check_repeated_task "$user_input")
    if [[ "$repeated_check" == "REPEATED_TASK_DETECTED:"* ]]; then
        local frequency=${repeated_check#*:}
        if [ "$frequency" -gt 3 ]; then
            echo "💡 CILS: This task repeated $frequency times. Consider automation."
        fi
    fi
    
    # Apply learned preferences proactively
    if [ -f "$CILS_PYTHON_PATH" ]; then
        python3 -c "
import sys, json
sys.path.append('$(dirname "$CILS_PYTHON_PATH")')
from interaction_learner import InteractionLearner, ProactiveAdvisor
learner = InteractionLearner()
advisor = ProactiveAdvisor(learner)
suggestions = advisor.analyze_request('$user_input')

if suggestions.get('optimizations'):
    for opt in suggestions['optimizations']:
        print('⚡ CILS Optimization:', opt['suggestion'])

if suggestions.get('warnings'):
    for warn in suggestions['warnings']:
        print('⚠️  CILS Warning: Avoid', warn['avoid'])
" 2>/dev/null &
    fi
}

on_claude_response() {
    local claude_response="$1"
    local response_type="${2:-action}"
    
    # Capture Claude's response
    capture_interaction "claude_response:$response_type" "$claude_response"
    
    # Analyze response for learning opportunities
    if echo "$claude_response" | grep -qiE "\b(should I|do you want|would you like)\b"; then
        capture_interaction "unnecessary_permission_request" "$claude_response"
        echo "🎯 CILS: Detected permission request - this should be automated"
    fi
    
    # Check if response could be optimized
    if echo "$claude_response" | grep -qiE "\b(running|executing|processing)\b.*\b(sequentially|one by one)\b"; then
        capture_interaction "parallelization_opportunity" "$claude_response"
        echo "⚡ CILS: Parallel execution opportunity detected"
    fi
}

on_tool_execution() {
    local tool_name="$1"
    local tool_params="$2"
    local execution_time="${3:-unknown}"
    
    # Capture tool usage patterns
    capture_interaction "tool_execution" "{\"tool\":\"$tool_name\",\"params\":\"$tool_params\",\"time\":\"$execution_time\"}"
    
    # Learn from test executions
    if [[ "$tool_name" == "Bash" ]] && echo "$tool_params" | grep -qiE "\b(test|pytest|npm test)\b"; then
        local test_command=$(echo "$tool_params" | grep -oE "(python3|pytest|npm test).*")
        if [ -f "$CILS_PYTHON_PATH" ]; then
            python3 -c "
import sys
sys.path.append('$(dirname "$CILS_PYTHON_PATH")')
from interaction_learner import InteractionLearner
learner = InteractionLearner()
learner.record_test_result('test_execution', '$test_command', True)  # Assume success for now
" 2>/dev/null &
        fi
    fi
}

on_error_occurred() {
    local error_message="$1"
    local context="$2"
    
    # Capture error for learning
    capture_interaction "error_occurred" "{\"error\":\"$error_message\",\"context\":\"$context\"}"
    
    # Learn from error patterns
    if [ -f "$CILS_PYTHON_PATH" ]; then
        python3 -c "
import sys
sys.path.append('$(dirname "$CILS_PYTHON_PATH")')
from interaction_learner import InteractionLearner
learner = InteractionLearner()
# Record failed test execution
if 'test' in '$context'.lower():
    learner.record_test_result('$context', 'failed_command', False, '$error_message')
" 2>/dev/null &
    fi
}

on_session_start() {
    echo "🧠 CILS: Comprehensive Interaction Learning System Active"
    echo "   📊 Learning from every interaction for optimization"
    
    # Load and apply high-confidence preferences
    if [ -f "$CILS_PYTHON_PATH" ]; then
        python3 -c "
import sys, json
sys.path.append('$(dirname "$CILS_PYTHON_PATH")')
from interaction_learner import InteractionLearner
learner = InteractionLearner()
prefs = learner.get_preferences_for_context('')

if prefs.get('execution', {}).get('no_permission_requests'):
    print('   ✅ Auto-approval mode: ON')
if prefs.get('execution', {}).get('prefer_parallel'):
    print('   ⚡ Parallel execution: DEFAULT')
if prefs.get('avoid'):
    print(f'   🚫 Avoiding {len(prefs[\"avoid\"])} known errors')

summary = learner.get_summary()
if summary.get('total_interactions', 0) > 0:
    efficiency = summary.get('learning_efficiency', 0) * 100
    print(f'   📈 Learning efficiency: {efficiency:.1f}%')
" 2>/dev/null
    fi
    
    # Clean up old temp files
    find "$TEMP_DIR" -name "interaction_*.json" -mtime +1 -delete 2>/dev/null &
}

on_session_end() {
    if [ -f "$CILS_PYTHON_PATH" ]; then
        echo "🔍 CILS Session Summary:"
        python3 -c "
import sys, json
sys.path.append('$(dirname "$CILS_PYTHON_PATH")')
from interaction_learner import InteractionLearner
learner = InteractionLearner()
summary = learner.get_summary()
print(f'   Interactions: {summary.get(\"total_interactions\", 0)}')
print(f'   Corrections needed: {summary.get(\"corrections_needed\", 0)}')
print(f'   New preferences learned: {summary.get(\"preferences_learned\", 0)}')
print(f'   Learning efficiency: {summary.get(\"learning_efficiency\", 0)*100:.1f}%')
if summary.get('corrections_needed', 0) == 0:
    print('   🎉 Perfect session - no corrections needed!')
" 2>/dev/null
    fi
    
    # Cleanup
    rm -f "$TEMP_DIR"/interaction_$$_*.json 2>/dev/null
}

# Export functions for hook system
export -f on_user_prompt_submit
export -f on_claude_response  
export -f on_tool_execution
export -f on_error_occurred
export -f on_session_start
export -f on_session_end
export -f capture_interaction
export -f detect_correction
export -f extract_preference
export -f check_repeated_task