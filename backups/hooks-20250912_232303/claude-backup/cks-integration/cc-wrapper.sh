#!/bin/bash

# CC Wrapper with CKS Integration
# This wrapper intercepts CC prompts and responses for CKS enhancement

INTEGRATION_DIR="/Users/MAC/.claude/cks-integration"
MIDDLEWARE="$INTEGRATION_DIR/middleware.sh"
ENABLED_FILE="$INTEGRATION_DIR/.enabled"

# Enable integration by default
touch "$ENABLED_FILE"

# Function to check if integration is enabled
is_enabled() {
    [ -f "$ENABLED_FILE" ]
}

# Intercept and enhance prompts
cc_with_cks() {
    local prompt="$*"
    
    if is_enabled; then
        # Enhance prompt with CKS context
        enhanced_prompt=$("$MIDDLEWARE" enhance "$prompt")
        
        # Send to CC (this would be the actual CC invocation)
        # For now, we'll just echo to demonstrate
        echo "=== ENHANCED PROMPT SENT TO CC ==="
        echo "$enhanced_prompt"
        echo "==================================="
        
        # Simulate CC response
        response="[Simulated CC Response]"
        
        # Validate response
        validated_response=$("$MIDDLEWARE" validate "$response")
        
        echo "=== VALIDATED RESPONSE FROM CC ==="
        echo "$validated_response"
        echo "==================================="
    else
        # Direct pass-through without enhancement
        echo "CKS Integration disabled - sending directly to CC"
        echo "$prompt"
    fi
}

# Alias for easy use
alias cc='cc_with_cks'

# Export function for use in scripts
export -f cc_with_cks

echo "CKS-CC Integration Wrapper Loaded"
echo "Use 'cc <prompt>' to send enhanced prompts to Claude Code"
echo "Integration is: $(is_enabled && echo 'ENABLED' || echo 'DISABLED')"