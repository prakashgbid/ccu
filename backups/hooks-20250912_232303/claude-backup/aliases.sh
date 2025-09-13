#!/bin/bash
# Claude Workflow Aliases - Quick commands for common workflows

# Development Workflow - Complete development pipeline
alias dev-workflow="claude-workflow development"
alias dev-workflow-interactive="claude-workflow development --interactive"
alias dev-step="claude-workflow development --step"

# Quick development for current directory
alias dev-here="claude-workflow development --project \$(pwd)"
alias dev-here-interactive="claude-workflow development --project \$(pwd) --interactive"

# RC specific workflow
alias rc-dev="claude-workflow development --project /Users/MAC/Documents/projects/roulette-community"
alias rc-dev-interactive="claude-workflow development --project /Users/MAC/Documents/projects/roulette-community --interactive"

# Testing workflow
alias test-workflow="claude-workflow test"
alias qa="claude-workflow test --project \$(pwd)"

# Deployment workflow  
alias deploy="claude-workflow deploy"
alias deploy-prod="claude-workflow deploy --project \$(pwd)"

# List all workflows
alias workflows="claude-workflow"

# Run full RC development cycle
rc-full-dev() {
    echo "🚀 Running full RC development cycle..."
    cd /Users/MAC/Documents/projects/roulette-community
    
    # Run all steps sequentially
    for step in {1..11}; do
        echo "Running step $step..."
        claude-workflow development --project /Users/MAC/Documents/projects/roulette-community --step $step
        
        # Check if step failed
        if [ $? -ne 0 ]; then
            echo "❌ Step $step failed. Stopping."
            return 1
        fi
    done
    
    echo "✅ Full development cycle complete!"
    git log --oneline -10
}

# Run specific workflow step
workflow-step() {
    local workflow=${1:-development}
    local step=${2:-1}
    local project=${3:-$(pwd)}
    
    claude-workflow $workflow --project $project --step $step
}

# Quick commit all changes with workflow
workflow-commit() {
    git add -A
    git commit -m "workflow: $1

Automated workflow commit
🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>"
}

# Show workflow status
workflow-status() {
    echo "📊 Workflow Status for $(pwd)"
    echo "="*60
    echo "Git Status:"
    git status -s
    echo ""
    echo "Recent Commits:"
    git log --oneline -5
    echo ""
    echo "Available Workflows:"
    claude-workflow
}

# echo "✅ Claude Workflow aliases loaded!"
# echo "Quick commands:"
# echo "  • dev-here          - Run development workflow in current directory"
# echo "  • rc-dev            - Run RC project development workflow"
# echo "  • rc-full-dev       - Run complete RC development cycle"
# echo "  • workflows         - List all available workflows"
# echo "  • workflow-status   - Show current project status"