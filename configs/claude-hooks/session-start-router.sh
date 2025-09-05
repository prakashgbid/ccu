#!/bin/bash
#
# Session Startup Router - Routes to preferred startup style
#

# Load config
STARTUP_STYLE="enhanced"  # default
[ -f /Users/MAC/.claude/startup-config ] && source /Users/MAC/.claude/startup-config

# Route to appropriate startup script
case "$STARTUP_STYLE" in
    minimal)
        [ -f /Users/MAC/.claude/hooks/session-start-minimal.sh ] && \
            exec /Users/MAC/.claude/hooks/session-start-minimal.sh
        ;;
    enhanced)
        [ -f /Users/MAC/.claude/hooks/session-start-enhanced.sh ] && \
            exec /Users/MAC/.claude/hooks/session-start-enhanced.sh
        ;;
    silent)
        # Just set session ID and exit
        export CC_SESSION_ID="session_$(date +%Y%m%d_%H%M%S)"
        exit 0
        ;;
    verbose)
        [ -f /Users/MAC/.claude/hooks/session-start.sh.verbose_backup ] && \
            exec /Users/MAC/.claude/hooks/session-start.sh.verbose_backup
        ;;
    *)
        # Fallback to current enhanced version
        exec /Users/MAC/.claude/hooks/session-start.sh
        ;;
esac

# Always succeed
exit 0