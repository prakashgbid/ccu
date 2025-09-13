#!/bin/bash


# Load configuration
CONFIG_FILE="$HOME/.claude/auto-commit.conf"
[ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"
# Task Completion Auto-Commit Hook
# Monitors TodoWrite tool and commits when tasks are marked complete

# Configuration
LOG_FILE="$HOME/.claude/logs/task-commit.log"
STATE_FILE="$HOME/.claude/.task_commit_state"
COMMIT_ON_COMPLETION=true
CREATE_PR_THRESHOLD=20  # Files changed threshold for PR creation

# Ensure directories exist
mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$(dirname "$STATE_FILE")"

# Logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# Parse tool input for TodoWrite
parse_todo_input() {
    local input="$1"
    
    # Check if this is a TodoWrite tool
    if [[ "$CLAUDE_TOOL_NAME" != "TodoWrite" ]]; then
        return 1
    fi
    
    # Check for completed tasks in the input
    echo "$input" | grep -q '"status":"completed"'
    return $?
}

# Function to create commit message from completed tasks
create_task_commit_message() {
    local project="$1"
    local completed_tasks="$2"
    
    cat << EOF
feat: completed CC tasks

Completed Tasks:
$completed_tasks

Project: $project
Auto-committed by Claude Code task completion hook
Timestamp: $(date '+%Y-%m-%d %H:%M:%S')
EOF
}

# Function to handle task completion
handle_task_completion() {
    local project_dir="$1"
    local project_name=$(basename "$project_dir")
    
    log "Task completed in $project_name, checking for uncommitted changes"
    
    # Check for changes
    if ! git -C "$project_dir" diff --quiet || ! git -C "$project_dir" diff --cached --quiet || \
       [ -n "$(git -C "$project_dir" ls-files --others --exclude-standard)" ]; then
        
        log "Found uncommitted changes in $project_name"
        
        # Get current branch
        local current_branch=$(git -C "$project_dir" rev-parse --abbrev-ref HEAD)
        
        # Generate branch name based on task
        local timestamp=$(date +%Y%m%d-%H%M%S)
        local branch_name="cc-task-${timestamp}"
        
        # If not on main/master, stay on current branch
        if [[ "$current_branch" != "main" && "$current_branch" != "master" ]]; then
            log "Working on feature branch: $current_branch"
            
            # Commit to current branch
            git -C "$project_dir" add -A
            git -C "$project_dir" commit -m "chore: checkpoint after task completion" >/dev/null 2>&1
            log "Committed checkpoint to $current_branch"
            
        else
            # Create feature branch
            log "Creating feature branch: $branch_name"
            
            # Create and switch to new branch
            git -C "$project_dir" checkout -b "$branch_name" >/dev/null 2>&1
            
            # Add and commit all changes
            git -C "$project_dir" add -A
            
            # Get change statistics
            local files_changed=$(git -C "$project_dir" diff --cached --name-only | wc -l)
            local insertions=$(git -C "$project_dir" diff --cached --stat | tail -1 | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' || echo 0)
            local deletions=$(git -C "$project_dir" diff --cached --stat | tail -1 | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+' || echo 0)
            
            # Create detailed commit message
            local commit_msg=$(create_task_commit_message "$project_name" "Auto-detected from TodoWrite")
            git -C "$project_dir" commit -m "$commit_msg" >/dev/null 2>&1
            
            log "Committed $files_changed files (+$insertions/-$deletions lines)"
            
            # Auto-merge for small changes
            if [ "$files_changed" -le "$CREATE_PR_THRESHOLD" ]; then
                log "Auto-merging to main (below threshold: $files_changed files)"
                
                # Switch to main/master
                git -C "$project_dir" checkout main >/dev/null 2>&1 || \
                git -C "$project_dir" checkout master >/dev/null 2>&1
                
                # Attempt merge
                if git -C "$project_dir" merge --no-ff "$branch_name" \
                   -m "Auto-merge: Task completion ($files_changed files changed)" >/dev/null 2>&1; then
                    
                    log "Successfully merged $branch_name"
                    
                    # Delete feature branch
                    git -C "$project_dir" branch -d "$branch_name" >/dev/null 2>&1
                    
                    # Push if remote exists
                    if git -C "$project_dir" remote get-url origin >/dev/null 2>&1; then
                        git -C "$project_dir" push >/dev/null 2>&1
                        log "Pushed to remote"
                    fi
                else
                    log "Merge conflict, keeping feature branch"
                    git -C "$project_dir" merge --abort >/dev/null 2>&1
                    git -C "$project_dir" checkout "$branch_name" >/dev/null 2>&1
                    
                    # Try to create PR if gh CLI is available
                    if command -v gh >/dev/null 2>&1; then
                        cd "$project_dir"
                        gh pr create --title "Task completion: $branch_name" \
                                    --body "Auto-generated PR from task completion" \
                                    2>/dev/null && log "Created PR for review"
                    fi
                fi
            else
                log "Large change ($files_changed files), creating PR for review"
                
                # Push branch and create PR
                if git -C "$project_dir" remote get-url origin >/dev/null 2>&1; then
                    git -C "$project_dir" push -u origin "$branch_name" >/dev/null 2>&1
                    
                    if command -v gh >/dev/null 2>&1; then
                        cd "$project_dir"
                        gh pr create --title "Task completion: $branch_name ($files_changed files)" \
                                    --body "Large change auto-committed after task completion" \
                                    2>/dev/null && log "Created PR for review"
                    fi
                fi
            fi
        fi
    else
        log "No changes to commit in $project_name"
    fi
}

# Main execution
main() {
    # Only process TodoWrite with completed tasks
    if [[ "$CLAUDE_TOOL_NAME" == "TodoWrite" ]]; then
        if echo "$CLAUDE_TOOL_INPUT" | grep -q '"status":"completed"'; then
            log "Detected completed task(s)"
            
            # Console output for visibility
            echo "╔══════════════════════════════════════════╗" >&2
            echo "║ 🪝 HOOK: task-completion-commit          ║" >&2
            echo "║ ✅ TRIGGER: Task marked complete         ║" >&2
            echo "║ 🔄 ACTION: Auto-committing changes       ║" >&2
            echo "╚══════════════════════════════════════════╝" >&2
            
            # Process all project directories
            for project_dir in /Users/MAC/Documents/projects/*/; do
                if [ -d "$project_dir/.git" ]; then
                    handle_task_completion "$project_dir" &
                fi
            done
            
            # Also check current directory
            if [ -d ".git" ]; then
                handle_task_completion "." &
            fi
        fi
    fi
}

# Run in background
main &

exit 0