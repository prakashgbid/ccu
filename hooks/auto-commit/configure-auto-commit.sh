#!/bin/bash

# Auto-Commit Configuration Manager
# Easy enable/disable and configuration of auto-commit hooks

CONFIG_FILE="$HOME/.claude/auto-commit.conf"
HOOKS_DIR="$HOME/.config/claude/hooks"

# Default configuration
cat > "$CONFIG_FILE" << 'EOF'
# Auto-Commit Configuration
# Edit these values to customize behavior

# Enable/disable auto-commit
ENABLED=true

# Commit after N file changes
COMMIT_THRESHOLD=5

# Minimum time between commits (seconds)
TIME_THRESHOLD=300

# Auto-merge threshold (files changed)
AUTO_MERGE_THRESHOLD=10

# Create PR for changes above this threshold
CREATE_PR_THRESHOLD=20

# Commit strategy
# Options: "branch" (always create branches), "direct" (commit to current branch)
COMMIT_STRATEGY="branch"

# Auto-push to remote
AUTO_PUSH=true

# Delete feature branches after merge
DELETE_MERGED_BRANCHES=true

# Projects to exclude (comma-separated)
EXCLUDE_PROJECTS=""

# Include patterns (comma-separated glob patterns)
INCLUDE_PATTERNS="*.py,*.js,*.ts,*.jsx,*.tsx,*.java,*.go,*.rs,*.cpp,*.c,*.h"

# Exclude patterns (comma-separated glob patterns)
EXCLUDE_PATTERNS="*.log,*.tmp,*.cache,node_modules/*,__pycache__/*,.git/*"

# Commit message template
COMMIT_TEMPLATE="feat: auto-commit after {TOOL} operation

Changes made by Claude Code
Tool: {TOOL}
Files: {FILES}
Time: {TIME}"

# Enable verbose logging
DEBUG=false
EOF

echo "✅ Auto-commit configuration created at: $CONFIG_FILE"
echo ""
echo "Usage:"
echo "  Enable:  export AUTO_COMMIT_ENABLED=true"
echo "  Disable: export AUTO_COMMIT_ENABLED=false"
echo ""
echo "Or edit $CONFIG_FILE directly"
echo ""
echo "Current settings:"
cat "$CONFIG_FILE" | grep -E "^[A-Z]" | head -5

# Make sure hooks load the config
for hook in "$HOOKS_DIR/auto-commit-hook.sh" "$HOOKS_DIR/task-completion-commit.sh"; do
    if [ -f "$hook" ]; then
        # Add config loading if not present
        if ! grep -q "CONFIG_FILE=" "$hook"; then
            sed -i.bak '2a\
\
# Load configuration\
CONFIG_FILE="$HOME/.claude/auto-commit.conf"\
[ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"\
' "$hook"
        fi
    fi
done

echo ""
echo "✅ Hooks configured to use settings file"