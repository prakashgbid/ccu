# Claude Development Workflow System

## 🚀 Overview
A complete, reusable development workflow system that executes step-by-step with Git integration.

## ✅ Features
- **11-step development pipeline** from requirements to production
- **Automatic Git commits** for every step
- **Issue detection and auto-fixing**
- **Global command access** via `claude-workflow`
- **Interactive or automated modes**
- **Project-specific workflows**

## 📋 Workflow Steps

1. **Product Owner Requirements** - Gather and document requirements
2. **Business Analysis** - Create user stories and acceptance criteria  
3. **Architecture Design** - System architecture planning
4. **Frontend Development** - UI implementation
5. **Backend Development** - API and server implementation
6. **Automated QA Testing** - Comprehensive test execution
7. **UX/UI Review** - Design validation
8. **BA Validation** - Requirements verification
9. **Deploy to Vercel** - Production deployment
10. **Product Owner Approval** - Final approval
11. **Setup Monitoring** - Production monitoring

## 🎯 Quick Commands

### Basic Usage
```bash
# List all workflows
claude-workflow

# Run development workflow
claude-workflow development

# Run interactively (step-by-step with confirmation)
claude-workflow development --interactive

# Run specific step only
claude-workflow development --step 3

# Run for specific project
claude-workflow development --project /path/to/project
```

### Aliases (After sourcing ~/.claude/aliases.sh)
```bash
# Quick development commands
dev-here              # Run development workflow in current directory
dev-here-interactive  # Run interactively in current directory

# RC Project specific
rc-dev               # Run RC development workflow
rc-dev-interactive   # Run RC workflow interactively  
rc-full-dev          # Run complete RC cycle (all 11 steps)

# Utilities
workflows            # List all workflows
workflow-status      # Show project status
workflow-step        # Run specific step
workflow-commit      # Quick commit with message
```

## 🔧 Installation

1. **Workflow files are installed at:**
   - `/Users/MAC/.claude/workflows/development_workflow.py`
   - `/Users/MAC/.claude/bin/claude-workflow`

2. **Add to PATH (already done):**
   ```bash
   export PATH="$HOME/.claude/bin:$PATH"
   ```

3. **Load aliases (already done):**
   ```bash
   source ~/.claude/aliases.sh
   ```

## 📝 Git Integration

Every workflow step automatically:
- Checks for changes
- Creates atomic commits
- Uses conventional commit format
- Includes agent information

Example commit messages:
```
product-owner: product owner requirements
business-analyst: business analysis
frontend-developer: frontend development
automation-qa: automated qa testing
```

## 🔍 Issue Detection & Auto-Fix

The workflow automatically:
- Detects missing files/directories
- Creates required structure
- Fixes common issues
- Reports unfixable problems

## 💾 Workflow Results

Each workflow run generates:
- JSON report at `/tmp/workflow_report_<id>.json`
- Git commits for each step
- Issue fix log
- Execution metrics

## 🚀 Example: Running Full RC Development

```bash
# Option 1: Use the alias
rc-full-dev

# Option 2: Run interactively
rc-dev-interactive

# Option 3: Run specific steps
claude-workflow development --project /Users/MAC/Documents/projects/roulette-community --step 1
claude-workflow development --project /Users/MAC/Documents/projects/roulette-community --step 2
# ... continue for all steps
```

## 📊 Workflow Status Check

```bash
cd /Users/MAC/Documents/projects/roulette-community
workflow-status
```

This shows:
- Current Git status
- Recent commits
- Available workflows

## 🎨 Customization

To add new workflows:

1. Create workflow file at `~/.claude/workflows/your_workflow.py`
2. Add to registry in `~/.claude/bin/claude-workflow`
3. Add aliases in `~/.claude/aliases.sh`

## ✨ Benefits

1. **Consistency** - Same process every time
2. **Traceability** - Every change is committed
3. **Automation** - Reduces manual work
4. **Quality** - Built-in checks and fixes
5. **Reusability** - Works for any project
6. **Speed** - Parallel execution where possible

## 🔄 Workflow Execution

The workflow ensures:
- ✅ Every code change is committed
- ✅ Proper commit messages
- ✅ Issues are detected and fixed
- ✅ Tests are run at appropriate stages
- ✅ Deployment only after validation
- ✅ Full audit trail in Git

## 📈 Results

Running the workflow on RC project created:
- Multiple Git commits (one per step)
- Requirements documentation
- User stories
- Architecture docs
- Automated fixes for missing components
- Complete development pipeline

---

**The Development Workflow is now saved globally and can be invoked with a single command!**