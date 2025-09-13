#!/bin/bash
# Activate verbose logging for current session

export CC_VERBOSE_LOGGING=true
export CC_LOG_LEVEL=MICRO
export CC_ATTRIBUTION_TRACKING=true
export ENHANCED_LOGGER_PATH="$HOME/.claude/enhanced_verbose_logger.py"

# Function to log CC actions
cc_log() {
    python3 "$ENHANCED_LOGGER_PATH" log "$@"
}

# Alias for quick logging
alias ccl='cc_log'

echo "🔍 Verbose logging with attribution activated!"
echo "Use 'cc_log' or 'ccl' to manually log operations"
echo "Monitor: python3 ~/.claude/cc_attribution_monitor.py"
