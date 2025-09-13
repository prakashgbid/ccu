#!/bin/bash

# CKS-CC Integration Middleware
# Routes CC prompts and responses through CKS enhancement pipeline

# Configuration
INTEGRATION_DIR="/Users/MAC/.claude/cks-integration"
LOG_DIR="$INTEGRATION_DIR/logs"
ENHANCER="$INTEGRATION_DIR/pre-prompt-enhancer.py"
VALIDATOR="$INTEGRATION_DIR/post-response-validator.py"
QUERY_SERVICE="$INTEGRATION_DIR/cks-query-service.py"

# Ensure logs directory exists
mkdir -p "$LOG_DIR"

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_DIR/middleware.log"
}

# Function to enhance prompt with CKS context
enhance_prompt() {
    local prompt="$1"
    
    # Log original prompt
    echo "$prompt" > "$LOG_DIR/last_original_prompt.txt"
    log_message "Enhancing prompt: ${prompt:0:100}..."
    
    # Enhance with CKS context
    enhanced=$(echo "$prompt" | python3 "$ENHANCER" 2>> "$LOG_DIR/enhancer_errors.log")
    
    if [ $? -eq 0 ]; then
        echo "$enhanced" > "$LOG_DIR/last_enhanced_prompt.txt"
        log_message "Prompt enhanced successfully"
        echo "$enhanced"
    else
        log_message "Enhancement failed, using original prompt"
        echo "$prompt"
    fi
}

# Function to validate response against CKS
validate_response() {
    local response="$1"
    
    # Log original response
    echo "$response" > "$LOG_DIR/last_original_response.txt"
    log_message "Validating response..."
    
    # Validate with CKS
    validated=$(echo "$response" | python3 "$VALIDATOR" 2>> "$LOG_DIR/validator_errors.log")
    
    if [ $? -eq 0 ]; then
        echo "$validated" > "$LOG_DIR/last_validated_response.txt"
        log_message "Response validated successfully"
        echo "$validated"
    else
        log_message "Validation failed, using original response"
        echo "$response"
    fi
}

# Function to query CKS directly
query_cks() {
    local query_type="$1"
    local query_data="$2"
    
    result=$(python3 "$QUERY_SERVICE" "$query_type" "$query_data" 2>> "$LOG_DIR/query_errors.log")
    
    if [ $? -eq 0 ]; then
        echo "$result"
    else
        echo "{\"error\": \"Query failed\"}"
    fi
}

# Function to check CKS health
check_health() {
    # Check if CKS services are running
    if curl -s http://localhost:5000/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓ CKS API (5000) healthy${NC}"
    else
        echo -e "${RED}✗ CKS API (5000) not responding${NC}"
    fi
    
    if curl -s http://localhost:5001/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓ CKS Enhanced (5001) healthy${NC}"
    else
        echo -e "${RED}✗ CKS Enhanced (5001) not responding${NC}"
    fi
    
    if curl -s http://localhost:5002/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓ CC Enhancement (5002) healthy${NC}"
    else
        echo -e "${RED}✗ CC Enhancement (5002) not responding${NC}"
    fi
    
    # Check cache stats
    cache_stats=$(python3 "$QUERY_SERVICE" cache-stats 2>/dev/null)
    if [ ! -z "$cache_stats" ]; then
        echo -e "${BLUE}Cache Stats: $cache_stats${NC}"
    fi
}

# Function to show integration status
show_status() {
    echo -e "${BLUE}=== CKS-CC Integration Status ===${NC}"
    echo ""
    
    # Check services
    check_health
    echo ""
    
    # Show recent activity
    if [ -f "$LOG_DIR/middleware.log" ]; then
        echo -e "${YELLOW}Recent Activity:${NC}"
        tail -5 "$LOG_DIR/middleware.log" | while read line; do
            echo "  $line"
        done
    fi
    
    echo ""
    echo -e "${YELLOW}Log Files:${NC}"
    echo "  Middleware: $LOG_DIR/middleware.log"
    echo "  Enhancements: $LOG_DIR/enhancements.jsonl"
    echo "  Validations: $LOG_DIR/validations.jsonl"
}

# Function to enable/disable integration
toggle_integration() {
    local action="$1"
    
    if [ "$action" = "enable" ]; then
        touch "$INTEGRATION_DIR/.enabled"
        echo -e "${GREEN}CKS-CC Integration ENABLED${NC}"
        log_message "Integration enabled"
    elif [ "$action" = "disable" ]; then
        rm -f "$INTEGRATION_DIR/.enabled"
        echo -e "${YELLOW}CKS-CC Integration DISABLED${NC}"
        log_message "Integration disabled"
    else
        if [ -f "$INTEGRATION_DIR/.enabled" ]; then
            echo -e "${GREEN}Integration is ENABLED${NC}"
        else
            echo -e "${YELLOW}Integration is DISABLED${NC}"
        fi
    fi
}

# Function to test the integration pipeline
test_pipeline() {
    echo -e "${BLUE}Testing CKS-CC Integration Pipeline${NC}"
    echo "======================================"
    
    # Test prompt
    test_prompt="Create a function to calculate fibonacci numbers"
    
    echo -e "${YELLOW}1. Original Prompt:${NC}"
    echo "$test_prompt"
    echo ""
    
    echo -e "${YELLOW}2. Enhancing with CKS context...${NC}"
    enhanced=$(enhance_prompt "$test_prompt")
    echo "${enhanced:0:500}..."
    echo ""
    
    # Simulate CC response
    test_response='```python
def fibonacci(n):
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)
```'
    
    echo -e "${YELLOW}3. Simulated CC Response:${NC}"
    echo "$test_response"
    echo ""
    
    echo -e "${YELLOW}4. Validating against CKS...${NC}"
    validated=$(validate_response "$test_response")
    echo "${validated:0:500}..."
    echo ""
    
    echo -e "${GREEN}✓ Pipeline test complete!${NC}"
}

# Main command handler
case "$1" in
    enhance)
        # Read prompt from stdin or argument
        if [ -z "$2" ]; then
            prompt=$(cat)
        else
            prompt="$2"
        fi
        enhance_prompt "$prompt"
        ;;
    
    validate)
        # Read response from stdin or argument
        if [ -z "$2" ]; then
            response=$(cat)
        else
            response="$2"
        fi
        validate_response "$response"
        ;;
    
    query)
        query_cks "$2" "$3"
        ;;
    
    status)
        show_status
        ;;
    
    health)
        check_health
        ;;
    
    enable)
        toggle_integration "enable"
        ;;
    
    disable)
        toggle_integration "disable"
        ;;
    
    test)
        test_pipeline
        ;;
    
    logs)
        if [ "$2" = "follow" ]; then
            tail -f "$LOG_DIR/middleware.log"
        else
            tail -20 "$LOG_DIR/middleware.log"
        fi
        ;;
    
    *)
        echo "CKS-CC Integration Middleware"
        echo "Usage: $0 {enhance|validate|query|status|health|enable|disable|test|logs} [args]"
        echo ""
        echo "Commands:"
        echo "  enhance [prompt]  - Enhance prompt with CKS context"
        echo "  validate [response] - Validate response against CKS"
        echo "  query <type> <data> - Query CKS directly"
        echo "  status           - Show integration status"
        echo "  health           - Check service health"
        echo "  enable           - Enable integration"
        echo "  disable          - Disable integration"
        echo "  test             - Test the pipeline"
        echo "  logs [follow]    - View logs"
        exit 1
        ;;
esac