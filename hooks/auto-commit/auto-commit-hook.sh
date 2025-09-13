#!/bin/bash


# Load configuration
CONFIG_FILE="$HOME/.claude/auto-commit.conf"
[ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"
# Auto-Commit Hook for Claude Code
# Automatically commits changes after task completion
# Creates feature branches and merges to main

# Configuration
LOG_FILE="$HOME/.claude/logs/auto-commit.log"
COMMIT_THRESHOLD=5  # Number of file changes to trigger commit
TIME_THRESHOLD=300   # Seconds between commits (5 minutes)
LAST_COMMIT_FILE="$HOME/.claude/.last_commit_time"
DEBUG=${DEBUG:-false}

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$(dirname "$LAST_COMMIT_FILE")"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
    [ "$DEBUG" = "true" ] && echo "[AUTO-COMMIT] $*" >&2
}

# Get tool name from environment
TOOL_NAME="${CLAUDE_TOOL_NAME:-unknown}"
TOOL_INPUT="${CLAUDE_TOOL_INPUT:-}"

# Skip for certain tools that don't modify code
case "$TOOL_NAME" in
    Read|Grep|Glob|WebSearch|WebFetch|BashOutput|Task)
        log "Skipping auto-commit for read-only tool: $TOOL_NAME"
        exit 0
        ;;
esac

# Console output for visibility (only for write operations)
echo "┌──────────────────────────────────────────┐" >&2
echo "│ 🪝 HOOK: auto-commit-hook                │" >&2
echo "│ 🔧 TOOL: $TOOL_NAME" | head -c 44 | awk '{printf "%-44s│\n", $0}' >&2
echo "│ 🔄 ACTION: Checking for uncommitted code │" >&2
echo "└──────────────────────────────────────────┘" >&2

# Function to check if we should commit
should_commit() {
    local project_dir="$1"
    
    # Check if it's a git repository
    if ! git -C "$project_dir" rev-parse --git-dir >/dev/null 2>&1; then
        return 1
    fi
    
    # Check for uncommitted changes
    if ! git -C "$project_dir" diff --quiet || ! git -C "$project_dir" diff --cached --quiet; then
        return 0
    fi
    
    # Check for untracked files
    if [ -n "$(git -C "$project_dir" ls-files --others --exclude-standard)" ]; then
        return 0
    fi
    
    return 1
}

# Function to generate branch name
generate_branch_name() {
    local tool="$1"
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local random=$(openssl rand -hex 3)
    # Convert to lowercase manually for compatibility
    local tool_lower=$(echo "$tool" | tr '[:upper:]' '[:lower:]')
    echo "cc-auto-${tool_lower}-${timestamp}-${random}"
}

# Function to generate commit message
generate_commit_message() {
    local tool="$1"
    local changes="$2"
    local files_changed="$3"
    
    local message="feat: auto-commit after $tool operation"
    
    if [ -n "$changes" ]; then
        message="$message

Changes:
$changes

Files modified: $files_changed
Tool: $tool
Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
    fi
    
    echo "$message"
}

# Function to perform auto-commit
auto_commit() {
    local project_dir="$1"
    local project_name=$(basename "$project_dir")
    
    log "Starting auto-commit for $project_name"
    echo "  📦 Auto-committing in: $project_name" >&2
    
    # Get current branch
    local current_branch=$(git -C "$project_dir" rev-parse --abbrev-ref HEAD)
    
    # Check if we're already on a feature branch
    if [[ "$current_branch" == cc-auto-* ]]; then
        log "Already on auto-commit branch: $current_branch"
        
        # Just commit to current branch
        git -C "$project_dir" add -A
        local commit_msg=$(generate_commit_message "$TOOL_NAME" "" "$(git -C "$project_dir" diff --cached --name-only | wc -l)")
        git -C "$project_dir" commit -m "$commit_msg" >/dev/null 2>&1
        
        log "Committed to existing branch: $current_branch"
        return 0
    fi
    
    # Create new feature branch
    local branch_name=$(generate_branch_name "$TOOL_NAME")
    
    # Stash any uncommitted changes first
    git -C "$project_dir" stash push -m "Auto-stash before branch creation" >/dev/null 2>&1
    local stashed=$?
    
    # Create and checkout new branch
    git -C "$project_dir" checkout -b "$branch_name" >/dev/null 2>&1
    
    # Pop stash if we stashed
    if [ $stashed -eq 0 ]; then
        git -C "$project_dir" stash pop >/dev/null 2>&1
    fi
    
    # Add all changes
    git -C "$project_dir" add -A
    
    # Get change summary
    local changes=$(git -C "$project_dir" diff --cached --stat | head -20)
    local files_changed=$(git -C "$project_dir" diff --cached --name-only | wc -l)
    
    # Generate and apply commit message
    local commit_msg=$(generate_commit_message "$TOOL_NAME" "$changes" "$files_changed")
    git -C "$project_dir" commit -m "$commit_msg" >/dev/null 2>&1
    
    log "Created branch $branch_name and committed $files_changed files"
    
    # Auto-merge to main if it's a small change (less than 10 files)
    if [ "$files_changed" -lt 10 ]; then
        log "Auto-merging to main (small change: $files_changed files)"
        
        # Switch to main
        git -C "$project_dir" checkout main >/dev/null 2>&1 || git -C "$project_dir" checkout master >/dev/null 2>&1
        
        # Merge the feature branch
        if git -C "$project_dir" merge --no-ff "$branch_name" -m "Auto-merge: $branch_name" >/dev/null 2>&1; then
            log "Successfully merged $branch_name to main"
            
            # Delete the feature branch
            git -C "$project_dir" branch -d "$branch_name" >/dev/null 2>&1
            
            # Push to remote if configured
            if git -C "$project_dir" remote get-url origin >/dev/null 2>&1; then
                git -C "$project_dir" push origin main >/dev/null 2>&1 || \
                git -C "$project_dir" push origin master >/dev/null 2>&1
                log "Pushed changes to remote"
            fi
        else
            log "Merge conflict detected, keeping feature branch"
            git -C "$project_dir" merge --abort >/dev/null 2>&1
            git -C "$project_dir" checkout "$branch_name" >/dev/null 2>&1
        fi
    else
        log "Large change ($files_changed files), keeping feature branch for review"
    fi
    
    # Update last commit time
    echo "$(date +%s)" > "$LAST_COMMIT_FILE"
}

# Function to check time threshold
check_time_threshold() {
    if [ ! -f "$LAST_COMMIT_FILE" ]; then
        return 0  # First run, allow commit
    fi
    
    local last_commit=$(cat "$LAST_COMMIT_FILE" 2>/dev/null || echo 0)
    local current_time=$(date +%s)
    local time_diff=$((current_time - last_commit))
    
    if [ $time_diff -ge $TIME_THRESHOLD ]; then
        return 0  # Enough time has passed
    else
        log "Skipping commit, only $time_diff seconds since last commit (threshold: $TIME_THRESHOLD)"
        return 1
    fi
}

# Main execution
main() {
    log "Hook triggered by tool: $TOOL_NAME"
    
    # Check time threshold
    if ! check_time_threshold; then
        exit 0
    fi
    
    # Find all git repositories in projects directory
    local projects_committed=0
    
    # Check main projects directory
    for project_dir in /Users/MAC/Documents/projects/*/; do
        if [ -d "$project_dir/.git" ] && should_commit "$project_dir"; then
            auto_commit "$project_dir"
            ((projects_committed++))
        fi
    done
    
    # Check current directory if it's different
    if [ -d ".git" ] && should_commit "." && [[ "$PWD" != /Users/MAC/Documents/projects/* ]]; then
        auto_commit "."
        ((projects_committed++))
    fi
    
    if [ $projects_committed -gt 0 ]; then
        log "Auto-committed to $projects_committed project(s)"
    else
        log "No projects needed commits"
    fi
}

# Run main function in background to avoid blocking
main &

exit 0