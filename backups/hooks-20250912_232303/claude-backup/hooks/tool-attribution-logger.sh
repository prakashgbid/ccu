#!/bin/bash
#
# Tool Attribution Logger Hook for Claude Code
# Logs every operation with tool/utility attribution
#

# Import the Python logger
LOGGER_PATH="$HOME/.claude/enhanced_verbose_logger.py"

# Function to detect tool from command
detect_tool_from_command() {
    local cmd="$1"
    
    # Check for known tools
    case "$cmd" in
        *"cc-orchestrator"*|*"cco"*)
            echo "cc-orchestrator"
            ;;
        *"integration-agent"*)
            echo "integration-agent"
            ;;
        *"knowledge_cli.py"*|*"cks"*)
            echo "knowledge-system"
            ;;
        *"log_decision.py"*)
            echo "log_decision.py"
            ;;
        *"capture_context.py"*)
            echo "capture_context.py"
            ;;
        *"parallel_executor.sh"*)
            echo "parallel_executor.sh"
            ;;
        *"ccu"*|*"claude-code-ultimate"*)
            echo "ccu"
            ;;
        *"jira"*)
            echo "jira-connect"
            ;;
        *"git "*)
            echo "git"
            ;;
        *"npm "*|*"pnpm "*|*"yarn "*)
            echo "package-manager"
            ;;
        *"python"*|*"pip"*)
            echo "python"
            ;;
        *"pytest"*)
            echo "pytest"
            ;;
        *"docker"*)
            echo "docker"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Function to detect project from path
detect_project_from_path() {
    local path="$1"
    
    if [[ "$path" == *"caia"* ]]; then
        echo "caia"
    elif [[ "$path" == *"claude-code-ultimate"* ]] || [[ "$path" == *"ccu"* ]]; then
        echo "ccu"
    elif [[ "$path" == *"roulette"* ]]; then
        echo "roulette"
    elif [[ "$path" == *"omnimind"* ]]; then
        echo "omnimind"
    elif [[ "$path" == *"admin"* ]]; then
        echo "admin"
    else
        echo ""
    fi
}

# Main hook logic
EVENT="$1"
shift

case "$EVENT" in
    "pre_bash_command")
        COMMAND="$1"
        TOOL=$(detect_tool_from_command "$COMMAND")
        PROJECT=$(detect_project_from_path "$PWD")
        
        # Log with tool attribution
        python3 "$LOGGER_PATH" log "BASH_EXEC" "Executing: $COMMAND" "$TOOL" "$PROJECT"
        ;;
        
    "pre_tool_call")
        TOOL_NAME="$1"
        TOOL_ARGS="$2"
        
        # Log native CC tool usage
        python3 "$LOGGER_PATH" tool "$TOOL_NAME" "CC_NATIVE" "$TOOL_ARGS"
        ;;
        
    "post_tool_call")
        TOOL_NAME="$1"
        RESULT="$2"
        
        # Log tool result
        python3 "$LOGGER_PATH" log "TOOL_RESULT" "Completed: $TOOL_NAME" "$TOOL_NAME"
        ;;
        
    "file_operation")
        OPERATION="$1"
        FILE_PATH="$2"
        PROJECT=$(detect_project_from_path "$FILE_PATH")
        
        # Log file operation with project attribution
        python3 "$LOGGER_PATH" log "FILE_OP" "$OPERATION: $FILE_PATH" "" "$PROJECT"
        ;;
        
    "parallel_start")
        OPERATIONS="$@"
        
        # Log parallel operations
        python3 "$LOGGER_PATH" log "PARALLEL" "Starting parallel operations: $OPERATIONS" "cc-orchestrator"
        ;;
        
    "decision_point")
        DECISION="$1"
        OPTIONS="$2"
        
        # Log decision with context
        python3 "$LOGGER_PATH" log "DECISION" "Chose: $DECISION from options: $OPTIONS"
        ;;
        
    "custom_script")
        SCRIPT_PATH="$1"
        SCRIPT_NAME=$(basename "$SCRIPT_PATH")
        PROJECT=$(detect_project_from_path "$SCRIPT_PATH")
        
        # Log custom script usage
        python3 "$LOGGER_PATH" log "CUSTOM_SCRIPT" "Running: $SCRIPT_NAME" "$SCRIPT_NAME" "$PROJECT"
        ;;
        
    "session_end")
        # Generate session summary
        python3 "$LOGGER_PATH" summary
        ;;
        
    *)
        # Log unknown events
        python3 "$LOGGER_PATH" log "EVENT" "$EVENT $@"
        ;;
esac