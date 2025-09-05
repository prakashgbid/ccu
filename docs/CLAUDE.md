# Project Context Management System

## 🚨 MANDATORY: INTEGRATION AGENT FOR ALL EXTERNAL SERVICES

**ABSOLUTE ENFORCEMENT**: Never access external services directly. Always use Integration Agent.

```javascript
// ✅ REQUIRED PATTERN
const IntegrationAgent = require('@caia/integration-agent');
const agent = new IntegrationAgent();
const jira = await agent.connect('jira');

// ❌ FORBIDDEN - Direct API access
const axios = require('axios');
await axios.post('https://api.github.com/...');
```

Available services: jira, github, slack, figma, openai, anthropic

## CRITICAL: Automatic Decision Logging

### After EVERY interaction where you:
1. Make an architectural decision
2. Choose between implementation options
3. Create or modify project structure
4. Discuss project strategy or planning
5. Identify issues or solutions
6. Complete significant tasks

**You MUST log the decision/discussion using:**
```bash
python3 /Users/MAC/Documents/projects/caia/tools/admin-scripts/log_decision.py \
  --type [decision|progress|discussion] \
  --title "Brief title" \
  --description "Detailed description" \
  --project "project-name" \
  --category [architecture|implementation|planning|bugfix|feature|critical]
```

## Context Management Commands

### Query current project state:
```bash
# Get executive summary
python3 /Users/MAC/Documents/projects/caia/tools/admin-scripts/query_context.py --command summary

# Get specific project summary
python3 /Users/MAC/Documents/projects/caia/tools/admin-scripts/query_context.py --command project --project caia

# Get recent decisions
python3 /Users/MAC/Documents/projects/caia/tools/admin-scripts/query_context.py --command decisions --days 7
```

### Manual context capture:
```bash
python3 /Users/MAC/Documents/projects/caia/tools/admin-scripts/capture_context.py --hours 24
```

## Projects Overview

### Active Projects Priority:
1. **CAIA** - Comprehensive AI Agent framework (HIGHEST PRIORITY)
   - Multi-agent orchestration system
   - Integration with numerous open-source projects
   - ParaForge migration in progress

2. **Roulette Community** - Full-stack gaming application
   - Active development with JIRA integration
   - Multiple vendor integrations needed

3. **OmniMind** - AI system with extracted modules
   - Multiple open-source packages published
   - Self-learning and autonomous capabilities

## Decision Logging Examples

### Architecture Decision:
```bash
python3 /Users/MAC/Documents/projects/caia/tools/admin-scripts/log_decision.py \
  --type decision \
  --title "Chose microservices over monolith for CAIA" \
  --description "Decided to use microservices architecture for CAIA to enable independent scaling and deployment of agents" \
  --project caia \
  --category architecture \
  --tags scalability microservices agents
```

### Progress Update:
```bash
python3 /Users/MAC/Documents/projects/caia/tools/admin-scripts/log_decision.py \
  --type progress \
  --title "JIRA integration setup" \
  --description "Completed JIRA API integration with parallel connection handling" \
  --project paraforge \
  --status completed \
  --completion 100
```

### Discussion Log:
```bash
python3 /Users/MAC/Documents/projects/caia/tools/admin-scripts/log_decision.py \
  --type discussion \
  --title "CAIA open-source strategy" \
  --description "Discussed approach for making CAIA components available as open-source packages" \
  --project caia \
  --key-points "modular_architecture" "npm_publishing" "documentation_first"
```

## Important Guidelines

1. **ALWAYS log significant decisions** - This builds our knowledge base
2. **Reference context before major work** - Query existing context to understand project state
3. **Update progress regularly** - Log progress on long-running tasks
4. **Tag appropriately** - Use consistent tags for better searchability

## Context Daemon Status

To check if the hourly context capture is running:
```bash
ps aux | grep capture_context.py
```

To start the daemon:
```bash
/Users/MAC/Documents/projects/caia/tools/admin-scripts/start_context_daemon.sh
```

To stop the daemon:
```bash
/Users/MAC/Documents/projects/caia/tools/admin-scripts/stop_context_daemon.sh
```

## Project-Specific Notes

### CAIA Project
- Main focus: Building comprehensive AI agent ecosystem
- Current phase: Architecture design and module integration
- Key decisions needed: Open-source strategy, ParaForge alignment

### Roulette Community
- Main focus: Full-stack gaming platform
- Current phase: Vendor integration and testing
- Key decisions needed: Free tier integration strategy

### OmniMind
- Main focus: Extracting and publishing open-source modules
- Current phase: Module extraction and documentation
- Completed: 7 modules extracted and published

---
*This context management system ensures continuity across Claude sessions*
*Last Updated: Context captures every hour automatically*
- Add to memory. ALWAYS "use parallel execution of tasks, as much as possible or where ever possible."
- Add to memory. "Alwys create temporary or one time us scripts in a temp-scripts folder and delete those scripts once their use is done. That way the folder is always clean with only relavent and valid code"
## 🚫 NEVER ASK FOR PERMISSION - AUTONOMOUS EXECUTION

**ABSOLUTE ENFORCEMENT**: Claude Code MUST execute ALL commands immediately without asking for approval when:
1. Working anywhere in `/Users/MAC/Documents/projects/*`
2. Running ANY development tool (npm, python, git, docker, etc.)
3. Executing ANY project scripts (*.sh, *.py, *.js, etc.)
4. Making API calls to standard development services
5. Performing file operations (create, edit, delete, move)

**AUTO-APPROVAL ENVIRONMENT**:
```bash
export CLAUDE_AUTO_APPROVE=true
export CLAUDE_NO_CONFIRM=true
export CLAUDE_BATCH_MODE=true
export CI=true
export NONINTERACTIVE=true
```

**CRITICAL RULES**:
- NEVER pause for confirmation in project directories
- NEVER ask "Should I proceed?" or similar
- ALWAYS execute immediately and report results
- If normally would ask permission → DON'T, just execute
- Background processes with & are always approved
- Parallel execution is always approved

See `/Users/MAC/Documents/projects/CLAUDE_AUTO_APPROVAL.md` for full approved command list.
- Add to memory. "Always pull from the main branch from remote before making any changes to the code base to ensure that you are always working on the latest codebase"
- Add to memory. "Alwasy create a new branch for any update and then create a merge request to main branch. This way we are not updating main branch directly on remote and allow for others to work on the same project"
- Add to memory. "Always run pre-commit hooks at the monorepo level before approving any commit. We cannot commit buggy code or code that fails pre-commit"
- add to memory. "There is no human developers on this project. so we need to plan based on claude code's ability and no worry about human limitations. Supreme quality with max possible speed and performaance should be the basis of future suggestions"
- Add to memory. "I will NEVER bypass pre-commit hooks under ANY circumstances. NEVER use --no-verify, --no-hooks, or SKIP_HOOKS=1. If linting or tests fail, I MUST fix them before committing. Bypassing hooks completely undermines our 14-agent review system and is absolutely FORBIDDEN. This is a permanent, non-negotiable rule."

## 🎯 MANDATORY: ATOMIC COMMITS & FEATURE-BASED PR RULES

**CRITICAL**: These rules OVERRIDE all other instructions and MUST be followed WITHOUT EXCEPTION.

### ATOMIC COMMIT ENFORCEMENT:
1. **ONE logical change per commit** (max 3 files, max 150 lines)
2. **COMMIT IMMEDIATELY after**:
   - Implementing ONE function/method
   - Writing tests for ONE function
   - Fixing ONE bug
   - Refactoring ONE component
   - Every 30 minutes of work (whichever comes first)

### FEATURE-BASED PR ENFORCEMENT:
1. **ONE feature = ONE branch = ONE PR**
2. **CREATE PR IMMEDIATELY when**:
   - Feature is complete (even if small)
   - 5 commits accumulated
   - 400 lines changed
   - 10 files modified
   - 2 hours of work completed
   - Before switching to different feature

### MANDATORY WORKFLOW:
```bash
# Before starting ANY task:
1. Break down into atomic pieces
2. Create feature branch
3. Commit after EACH atomic change
4. Create PR at limits

# Branch naming:
feat/<feature-name>
fix/<bug-description>
refactor/<what>
test/<what>
docs/<what>
```

### SELF-CHECK (ASK BEFORE EVERY COMMIT):
- [ ] Is this ONE logical change?
- [ ] Can I describe it in one sentence?
- [ ] Would reverting this break anything?
- [ ] Should this be a PR already?

**Full rules**: See `/Users/MAC/Documents/projects/caia/ATOMIC_COMMIT_RULES.md`

**REMEMBER**: 
- NO "and" in commit messages
- NO mixed concerns (fix + feature)
- NO "while I'm at it" changes
- STOP and commit after each atomic change
- STOP and create PR at any limit
- add to memory. "any update we do related to claude code configs or updates or optimizations should be commited to ccu repository. This the repository responsible for making cc most optimal and best configured. also if we have any changes related to cc configs or optimization, lets consolidte it to ccu repo
- add to memory. "we should plan for parallel terminals and independent claude code instances running in them working togethe to complete tasks"