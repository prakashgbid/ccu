#!/bin/bash

# CC Data Capture Hook - Captures ALL interactions for learning
# This hook sends every interaction to CKS and CLS for learning

# Configuration
CLS_API="http://localhost:5003"
CKS_API="http://localhost:5555"
LOG_FILE="/Users/MAC/Documents/projects/caia/knowledge-system/logs/data_capture.log"
SESSION_ID=$(date +%Y%m%d_%H%M%S)

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Function to capture interaction
capture_interaction() {
    local prompt="$1"
    local response="$2"
    local tools="$3"
    
    # Send to CLS API
    curl -s -X POST "$CLS_API/api/capture" \
        -H "Content-Type: application/json" \
        -d "{
            \"session_id\": \"$SESSION_ID\",
            \"prompt\": \"$prompt\",
            \"response\": \"$response\",
            \"tools\": $tools,
            \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)\"
        }" > /dev/null 2>&1
    
    log_message "Captured interaction to CLS"
}

# Function to capture code generation
capture_code_generation() {
    local file_path="$1"
    local language="$2"
    local action="$3"
    
    # Send to CKS API
    curl -s -X POST "$CKS_API/api/capture/code" \
        -H "Content-Type: application/json" \
        -d "{
            \"file_path\": \"$file_path\",
            \"language\": \"$language\",
            \"action\": \"$action\",
            \"session_id\": \"$SESSION_ID\",
            \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)\"
        }" > /dev/null 2>&1
    
    log_message "Captured code generation to CKS"
}

# Function to capture tool usage
capture_tool_usage() {
    local tool_name="$1"
    local parameters="$2"
    
    curl -s -X POST "$CLS_API/api/capture/tool" \
        -H "Content-Type: application/json" \
        -d "{
            \"tool\": \"$tool_name\",
            \"parameters\": $parameters,
            \"session_id\": \"$SESSION_ID\",
            \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)\"
        }" > /dev/null 2>&1
    
    log_message "Captured tool usage: $tool_name"
}

# Export functions for use by other scripts
export -f capture_interaction
export -f capture_code_generation
export -f capture_tool_usage
export SESSION_ID

# Log startup
log_message "CC Data Capture Hook initialized with session: $SESSION_ID"

# Make functions available to CC
echo "Data capture hooks loaded successfully"