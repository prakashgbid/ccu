#!/bin/bash
# TEMPLATE: Replace with your hook description
# This template ensures all hooks have visible console output

# ============================================
# CONFIGURATION
# ============================================
HOOK_NAME="your-hook-name"  # Change this to your hook's name
HOOK_ACTION="What this hook does"  # Brief description of the action
LOG_FILE="$HOME/.claude/logs/${HOOK_NAME}.log"

# Create log directory if needed
mkdir -p "$(dirname "$LOG_FILE")"

# ============================================
# CONSOLE OUTPUT (MANDATORY FOR ALL HOOKS)
# ============================================
# This section ensures the hook is visible when it runs
# Choose one of these styles:

# Style 1: Simple box (for quick hooks)
echo "┌──────────────────────────────────────────┐" >&2
echo "│ 🪝 HOOK: $HOOK_NAME" | head -c 44 | awk '{printf "%-44s│\n", $0}' >&2
echo "│ 📋 ACTION: $HOOK_ACTION" | head -c 44 | awk '{printf "%-44s│\n", $0}' >&2
echo "└──────────────────────────────────────────┘" >&2

# Style 2: Double-line box (for important hooks)
# echo "╔══════════════════════════════════════════╗" >&2
# echo "║ 🪝 HOOK: $HOOK_NAME" | head -c 44 | awk '{printf "%-44s║\n", $0}' >&2
# echo "║ 📋 ACTION: $HOOK_ACTION" | head -c 44 | awk '{printf "%-44s║\n", $0}' >&2
# echo "╚══════════════════════════════════════════╝" >&2

# Style 3: Rounded box (for user-facing hooks)
# echo "╭──────────────────────────────────────────╮" >&2
# echo "│ 🪝 HOOK: $HOOK_NAME" | head -c 44 | awk '{printf "%-44s│\n", $0}' >&2
# echo "│ 📋 ACTION: $HOOK_ACTION" | head -c 44 | awk '{printf "%-44s│\n", $0}' >&2
# echo "╰──────────────────────────────────────────╯" >&2

# ============================================
# ENVIRONMENT VARIABLES
# ============================================
# Get common Claude Code environment variables
TOOL_NAME="${CLAUDE_TOOL_NAME:-unknown}"
TOOL_INPUT="${CLAUDE_TOOL_INPUT:-}"
TOOL_PARAMS="${CLAUDE_TOOL_PARAMS:-}"
EXIT_CODE="${CLAUDE_TOOL_EXIT_CODE:-0}"
USER_PROMPT="${CLAUDE_USER_PROMPT:-}"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# ============================================
# LOGGING FUNCTION
# ============================================
log() {
    echo "[$TIMESTAMP] $*" >> "$LOG_FILE"
    # Optionally also show in console for debugging
    # echo "  [${HOOK_NAME}] $*" >&2
}

# ============================================
# MAIN HOOK LOGIC
# ============================================
main() {
    log "Hook triggered: $HOOK_NAME"
    
    # YOUR HOOK LOGIC GOES HERE
    # Example:
    # if [[ "$TOOL_NAME" == "Write" ]]; then
    #     echo "  📝 Processing Write operation..." >&2
    #     # Do something
    # fi
    
    # Show completion
    # echo "  ✅ Hook completed: $HOOK_NAME" >&2
    
    log "Hook completed successfully"
}

# ============================================
# ERROR HANDLING
# ============================================
trap 'log "Hook failed with error on line $LINENO"' ERR

# ============================================
# EXECUTION
# ============================================
# Run in background to avoid blocking (&) or foreground
main

# Exit cleanly
exit 0

# ============================================
# HOOK GUIDELINES
# ============================================
# 1. ALWAYS show console output when hook triggers
# 2. Use >&2 to send output to stderr (visible in console)
# 3. Keep console messages concise but informative
# 4. Log detailed information to log files
# 5. Run heavy operations in background with &
# 6. Exit with 0 to avoid blocking CC operations
# 7. Use meaningful icons: 🪝 🔧 📋 ✅ ❌ 🔄 📦 💬 ⚡
# 8. Test your hook with: bash -x your-hook.sh

# ============================================
# COMMON PATTERNS
# ============================================

# Pattern 1: Tool-specific hook
# if [[ "$TOOL_NAME" == "Write" ]] || [[ "$TOOL_NAME" == "Edit" ]]; then
#     echo "  🔧 Processing code modification..." >&2
#     # Your logic here
# fi

# Pattern 2: Conditional execution
# if should_execute; then
#     echo "  ⚡ Executing action..." >&2
#     # Your logic here
# fi

# Pattern 3: Multi-project processing
# for project_dir in /Users/MAC/Documents/projects/*/; do
#     if [ -d "$project_dir/.git" ]; then
#         echo "  📦 Processing: $(basename "$project_dir")" >&2
#         # Your logic here
#     fi
# done

# Pattern 4: Background operation
# (
#     heavy_operation &
#     HEAVY_PID=$!
#     echo "  🔄 Running in background (PID: $HEAVY_PID)" >&2
# ) &

# Pattern 5: Progress indicators
# echo -n "  🔄 Processing" >&2
# for i in {1..3}; do
#     echo -n "." >&2
#     sleep 1
# done
# echo " Done!" >&2