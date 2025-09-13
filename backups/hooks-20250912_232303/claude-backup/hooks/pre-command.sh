#!/bin/bash
# Pre-command hook for CC Enhancement Systems

# Export paths
export CC_ENHANCEMENT_DIR="/Users/MAC/Documents/projects/caia/knowledge-system/cc-enhancement"
export CKS_PATH="/Users/MAC/Documents/projects/caia/knowledge-system"
export CKS_API_URL="http://localhost:5000"

# Ensure Integration Hub is running
if ! pgrep -f "cih_system.py" > /dev/null; then
    cd "$CC_ENHANCEMENT_DIR/cih"
    python3 cih_system.py > /dev/null 2>&1 &
fi

# Record command in Decision Memory
python3 "$CC_ENHANCEMENT_DIR/cdm/cdm_system.py" record_command "$@" 2>/dev/null || true
