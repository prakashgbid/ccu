#!/bin/bash
# Notification Hook - Handles CC notifications

# Log notification
echo "[$(date)] NOTIFICATION: $CLAUDE_NOTIFICATION_TYPE - $CLAUDE_NOTIFICATION_MESSAGE" >> /tmp/cc-notifications.log

# Handle specific notification types
case "$CLAUDE_NOTIFICATION_TYPE" in
    "error")
        echo "Error occurred: $CLAUDE_NOTIFICATION_MESSAGE" >> /tmp/cc-errors.log
        ;;
    "warning")
        echo "Warning: $CLAUDE_NOTIFICATION_MESSAGE" >> /tmp/cc-warnings.log
        ;;
    "info")
        echo "Info: $CLAUDE_NOTIFICATION_MESSAGE" >> /tmp/cc-info.log
        ;;
esac

exit 0