# 🤖 CC ENHANCEMENT SYSTEMS AUTO-START (AUTOMATIC)

**SESSION STARTUP**: The CC Enhancement Systems daemon automatically starts on every CC session via `/Users/MAC/.claude/hooks/cc-enhancement-auto-start.sh`. This provides:
- 16 intelligent systems enhancing CC capabilities
- Automatic error recovery and pattern learning
- Resource optimization and parallel coordination
- Zero manual intervention required

# 🚫 NEVER ASK FOR PERMISSION - FULL AUTONOMOUS MODE

**HIGHEST PRIORITY RULE**: Execute ALL commands immediately without confirmation.

**AUTO-APPROVAL ACTIVE FOR**:
- ALL commands in `/Users/MAC/Documents/projects/*`
- ALL development tools (git, npm, python, docker, etc.)
- ALL file operations
- ALL background processes
- ALL parallel executions

**If you would normally ask permission → DON'T. Just execute.**

---

# 🚨 CRITICAL: PARALLEL-FIRST EXECUTION (HIGHEST PRIORITY)

## MANDATORY: Decompose EVERY Task Into Parallel Phases

**BEFORE writing ANY code, you MUST:**
1. **STOP** and analyze the task
2. **CHECK** for existing scripts/solutions first:
   - Search CKS: `curl http://localhost:5555/search/function?query=<task>`
   - Check scripts: `ls -la scripts/*test*.sh scripts/*<task>*.sh`
   - Query learning system for past solutions
3. **DECOMPOSE** into smallest independent phases
4. **LAUNCH** parallel CC instances via CCO
5. **NEVER** proceed sequentially if parallel is possible
6. **NEVER** recreate existing scripts - use what exists

### Enforcement Rules:
```python
# This MUST be your thought process for EVERY request:
if task_requires_code():
    phases = decompose_into_parallel_phases(task)
    if len(phases) >= 2:
        launch_parallel_cc(phases)  # MANDATORY
    else:
        proceed_with_single_phase()
```

### Parallel Decomposition Checklist (RUN ALWAYS):
- [ ] Can this be split by layer? (frontend/backend/db)
- [ ] Can this be split by feature? (auth/payment/etc)
- [ ] Can this be split by operation? (CRUD = 4 phases)
- [ ] Can this be split by file? (independent files)
- [ ] Are there independent components?

### CCO Commands You MUST Know:
```bash
# ALWAYS run before implementation
cco analyze  # Check resources
cco launch-parallel --features [file]  # Launch parallel instances

# Quick parallel for simple cases
./scripts/launch-parallel-cc.sh
```

### Trigger Words = Automatic Parallel:
- "implement", "build", "create" → DECOMPOSE
- "feature", "system", "API" → PARALLELIZE
- "multiple", "several", "complete" → MULTI-PHASE
- "with tests" → SEPARATE PHASE

### DEFAULT BEHAVIOR:
1. User asks for feature → Decompose into phases
2. Show phase breakdown → Get approval
3. Launch parallel CC → Monitor progress
4. NEVER write sequential code for multi-file tasks

**Reference**: `/Users/MAC/Documents/projects/caia/caia/CC_PARALLEL_DIRECTIVES.md`

---

## 🔴 CRITICAL: ALWAYS USE EXISTING SCRIPTS (NEVER RECREATE)

### Frequently Used Scripts That ALREADY EXIST:
```bash
# TESTING SCRIPTS (USE THESE, DON'T CREATE NEW):
/Users/MAC/Documents/projects/caia/knowledge-system/scripts/comprehensive_system_test.sh  # Full system test
/Users/MAC/Documents/projects/caia/knowledge-system/scripts/quick_test.sh                  # Quick validation
/Users/MAC/Documents/projects/caia/knowledge-system/scripts/repair_system.sh               # Fix issues
/Users/MAC/Documents/projects/caia/knowledge-system/scripts/start_all_services.sh          # Start services
/Users/MAC/Documents/projects/caia/knowledge-system/scripts/cils_status.sh                 # Check status
/Users/MAC/Documents/projects/caia/knowledge-system/scripts/start_cks_monitor.sh           # Monitor
/Users/MAC/Documents/projects/caia/knowledge-system/TEST_EVERYTHING.sh                     # Test all

# ADMIN SCRIPTS (USE THESE):
/Users/MAC/Documents/projects/caia/tools/admin-scripts/quick_status.sh                               # Project status
/Users/MAC/Documents/projects/caia/tools/admin-scripts/caia_status.sh                                # CAIA status
/Users/MAC/Documents/projects/caia/tools/admin-scripts/log_decision.py                               # Log decisions
/Users/MAC/Documents/projects/caia/tools/admin-scripts/query_context.py                              # Query context
```

### Before ANY Script Creation:
1. **FIRST** check if script exists: `find . -name "*test*.sh" -o -name "*<task>*.sh"`
2. **THEN** check CKS for similar scripts
3. **ONLY** create new if absolutely nothing exists

# Personal Development Preferences

## Coding Style
- Use TypeScript with strict mode enabled
- Prefer functional programming patterns
- Use descriptive variable and function names
- Keep functions small and focused
- Comment complex logic, not obvious code
- Use early returns to reduce nesting

## Development Workflow
- Always create feature branches
- Run tests before committing
- Use conventional commit messages
- Squash commits before merging
- Review own code before requesting review
- Update documentation with code changes

## Tool Preferences
- Package manager: `pnpm` > `npm` > `yarn`
- Search: `rg` (ripgrep) > `grep`
- File viewing: `bat` > `cat`
- Process management: `pm2` for Node.js apps
- Database GUI: TablePlus
- API testing: Thunder Client in VS Code

## Testing Approach
- Write tests for critical paths first
- Aim for 80% coverage minimum
- Use descriptive test names
- Group related tests in describe blocks
- Mock external dependencies
- Test edge cases and error conditions

## Git Preferences
- Commit message format: `type(scope): description`
- Types: feat, fix, docs, style, refactor, test, chore
- Keep commits atomic and focused
- Write meaningful commit messages
- Use interactive rebase to clean history
- Tag releases with semantic versioning

## 🚨 MANDATORY: INTEGRATION AGENT FOR ALL EXTERNAL SERVICES

**CRITICAL ENFORCEMENT**: You MUST NEVER access ANY external service directly. This is ABSOLUTE and NON-NEGOTIABLE.

### 🔒 INTEGRATION AGENT IS THE ONLY WAY

**FORBIDDEN** (Will cause immediate failure):
```javascript
// ❌ NEVER DO THIS
const axios = require('axios');
await axios.post('https://api.github.com/...');

// ❌ NEVER DO THIS
const jira = new JiraClient({...});

// ❌ NEVER DO THIS
fetch('https://slack.com/api/...');
```

**REQUIRED** (The ONLY acceptable pattern):
```javascript
// ✅ ALWAYS DO THIS
const IntegrationAgent = require('@caia/integration-agent');
const agent = new IntegrationAgent();
const jira = await agent.connect('jira');
```

### Available Integrations via Integration Agent:
- `jira` - Atlassian Jira
- `github` - GitHub API
- `slack` - Slack messaging
- `figma` - Figma designs
- `openai` - OpenAI GPT
- `anthropic` - Anthropic Claude

### Commands to Use:
```bash
# See available integrations
integration-agent list

# Get usage examples
integration-agent show jira

# Test connection
integration-agent test jira
```

### ENFORCEMENT RULES:
1. BEFORE any external API call, check Integration Agent
2. NEVER use axios, fetch, or http for external services
3. NEVER create direct API clients
4. ALWAYS use: `await IntegrationAgent.connect('service')`
5. If Integration Agent doesn't support it, ADD IT FIRST


## 🧠 COMPLETE LEARNING SYSTEM INTEGRATION

**STATUS**: FULLY ACTIVE
**APIs**: CKS (5555), Enhancement (5002), Learning (5003)

### Automatic Learning Features:
1. **Prompt Capture**: Every user prompt is analyzed and stored
2. **Response Learning**: All CC responses feed back into knowledge
3. **Pattern Recognition**: Automatically identifies coding patterns
4. **Decision Memory**: Tracks and learns from all decisions
5. **Code Knowledge**: Indexes all generated code for reuse
6. **Context Persistence**: Maintains context across sessions

### Learning Workflow:
```
User Prompt → Pre-hook Capture → CKS Query → CC Processing 
    ↓                                              ↓
Learning DB ← Pattern Extraction ← Response → Post-hook Capture
    ↓
Enhanced Future Responses
```

### Active Databases:
- `caia_knowledge.db`: 9,017 code elements
- `chat_history.db`: 22,472 interactions
- `decisions.db`: Tracking all decisions
- `patterns.db`: Learning from patterns
- `context_persistence.db`: Session continuity

### Enforcement:
```bash
export CKS_ENFORCEMENT=MANDATORY
export CC_LEARNING_ENABLED=true
export LEARNING_API_URL="http://localhost:5003"
```

## 🤖 MANDATORY: CAIA KNOWLEDGE SYSTEM (CKS) INTEGRATION

**CRITICAL**: Claude Code MUST use CAIA Knowledge System for ALL operations. This is NON-NEGOTIABLE.

### 🔒 ENFORCEMENT LEVEL: ABSOLUTE
```bash
export CKS_ENFORCEMENT=MANDATORY
export CKS_PATH="/Users/MAC/Documents/projects/caia/knowledge-system"
export INTEGRATION_AGENT_PATH="/Users/MAC/Documents/projects/caia/packages/agents/integration-agent"
export CKS_API_URL="http://localhost:5555"  # Updated API bridge
export CKS_BYPASS_ALLOWED=false
export CKS_DB="/Users/MAC/Documents/projects/caia/knowledge-system/data/caia_knowledge.db"
```

### 🚨 MANDATORY CKS CHECKS BEFORE ANY CODE (ENFORCED):
**BEFORE writing ANY code, you MUST:**
1. Query CKS API at http://localhost:5555/search/function
2. Check for duplicates at http://localhost:5555/check/duplicate
3. Validate imports at http://localhost:5555/validate/import
4. If similar code exists, USE IT or EXTEND IT - NEVER duplicate

**CKS Database Stats:**
- 788 files indexed
- 5,025 functions cataloged
- 704 classes tracked
- 2,500 imports mapped

### 📋 MANDATORY CKS WORKFLOW (EVERY OPERATION):

#### 1. CONTEXT LOADING (ALWAYS FIRST)
```bash
# BEFORE any CC session or context switch:
python3 $CKS_PATH/cli/knowledge_cli.py context-load --project caia
```
- Load existing knowledge base
- Understand current architecture
- Identify available utilities and patterns

#### 2. PRE-IMPLEMENTATION CHECK (BEFORE ANY CODE)
```bash
# BEFORE writing ANY code:
python3 $CKS_PATH/cli/knowledge_cli.py check-redundancy "$TASK_DESCRIPTION"
```
- **IF SIMILAR EXISTS**: Use existing code, suggest refactoring
- **IF REDUNDANT**: BLOCK implementation, require override
- **IF UNIQUE**: Proceed with implementation

#### 3. ARCHITECTURE SCANNING (BEFORE DESIGN)
```bash
# BEFORE any system design:
python3 $CKS_PATH/cli/knowledge_cli.py scan-architecture "$DESIGN_INTENT"
```
- Check existing architectural patterns
- Identify reusable components
- Suggest conformant approaches

#### 4. POST-IMPLEMENTATION UPDATE (AFTER CODE)
```bash
# AFTER writing code:
python3 $CKS_PATH/cli/knowledge_cli.py update-knowledge --files "$CHANGED_FILES"
```
- Index new code
- Update relationships
- Refresh knowledge base

### 🚨 ABSOLUTE RULES (NO EXCEPTIONS):

1. **NEVER** write code without CKS redundancy check
2. **NEVER** design architecture without CKS pattern scan
3. **NEVER** suggest solutions without CKS existing capability search
4. **ALWAYS** load CKS context before any significant operation
5. **ALWAYS** update CKS after implementation changes

### 🔄 CC SESSION STARTUP SEQUENCE (AUTOMATIC):
```bash
# Automatic execution on EVERY CC startup via session hook:
1. Check CKS health: curl http://localhost:5000/health
2. If not running: /Users/MAC/Documents/projects/caia/knowledge-system/scripts/start_all_services.sh
3. Wait for startup: Monitor port 5000 for up to 10 seconds
4. Load CKS context: python3 $CKS_PATH/cli/knowledge_cli.py context-load --project caia
5. Enable enforcement: export CKS_ENFORCEMENT=MANDATORY

# This happens automatically via: 
# /Users/MAC/Documents/projects/claude-code-ultimate/configs/hooks/caia-session-startup.sh
```

### 🛡️ BYPASS PROTECTION:
- **CKS_BYPASS_ALLOWED=false** - No bypass permitted
- Override requires explicit `--force-bypass` with justification
- All bypasses logged and tracked
- Bypasses trigger immediate review

### 📊 CKS INTEGRATION COMMANDS:

```bash
# Context Commands (Use before any work)
cks_load_context()     # Load full project context
cks_check_redundancy() # Check for existing implementations
cks_scan_architecture() # Scan for architectural patterns
cks_update_knowledge() # Update knowledge base

# Search Commands (Use during planning)
cks_find_similar()     # Find similar functions/components
cks_list_capabilities() # List all available capabilities
cks_suggest_reuse()    # Suggest reusable components

# Enforcement Commands
cks_validate_unique()  # Validate implementation is unique
cks_require_approval() # Require approval for duplicates
cks_log_decision()     # Log architectural decisions
```

### 🎯 INTEGRATION POINTS:
- **Before file creation**: Check redundancy
- **Before architecture design**: Scan existing patterns
- **Before suggesting solutions**: Search existing capabilities
- **After code changes**: Update knowledge base
- **During planning**: Reference available components

## 🎯 SIMPLIFIED: Git for Claude Code Projects

### THE ONLY RULE:
```bash
# Save your work whenever you want:
git add -A && git commit -m "updates" && git push
```

### What We DON'T Do Anymore:
- ❌ Feature branches (work on main)
- ❌ Pull requests (push directly)
- ❌ Atomic commits (commit whenever)
- ❌ Detailed messages (just "updates")
- ❌ Commit conventions (waste of time)

### Why:
- No other developers = No coordination needed
- Claude doesn't read git history
- Every minute on git ceremony = minute not shipping

### The ONLY Exception:
```bash
# For production releases:
git tag v1.0.0 && git push --tags
```

**Time saved: 1-2 hours per week**

## Code Review Focus
- Check for security vulnerabilities
- Verify error handling
- Look for performance issues
- Ensure consistent naming
- Validate test coverage
- Review documentation updates

## Project Setup Checklist
- [ ] Initialize git repository
- [ ] Set up TypeScript with strict config
- [ ] Configure ESLint and Prettier
- [ ] Set up pre-commit hooks
- [ ] Create initial test structure
- [ ] Configure CI/CD pipeline
- [ ] Add README with setup instructions
- [ ] Set up environment variables
- [ ] Configure error monitoring
- [ ] Add health check endpoint

## Debugging Approach
- Add strategic console.logs first
- Use debugger for complex issues
- Check network tab for API issues
- Verify environment variables
- Look for typos in variable names
- Check for async/await issues
- Validate data types

## Performance Considerations
- Profile before optimizing
- Optimize critical paths first
- Use caching strategically
- Lazy load heavy components
- Optimize database queries
- Monitor memory usage
- Use CDN for static assets

## Security Defaults
- Never commit secrets
- Validate all inputs
- Sanitize user-generated content
- Use parameterized queries
- Implement rate limiting
- Enable CORS appropriately
- Keep dependencies updated
- Use HTTPS everywhere

## Documentation Standards
- Write README first
- Include setup instructions
- Document API endpoints
- Add inline code comments
- Create architecture diagrams
- Maintain changelog
- Document environment variables
- Include troubleshooting section

## Shortcuts & Aliases
- Build and test: `npm run validate`
- Quick commit: `git add -A && git commit -m`
- Update deps: `pnpm update --interactive`
- Find TODO: `rg "TODO|FIXME|HACK"`
- Clean branches: `git branch --merged | grep -v main | xargs git branch -d`

## AI Agent Usage
- Let agents be proactive
- Use multiple agents for complex tasks
- Trust agent expertise in their domains
- Review agent-generated code
- Learn from agent patterns
- Document successful agent workflows

## 🚀 CRITICAL: Parallel Claude Code Paradigm

**REMEMBER**: We're building for 10s-100s of parallel CC instances, NOT single instance!

### Think Parallel FIRST:
1. **Can this be split across multiple CCs?** → Always yes
2. **How would 10 CCs solve this?** → That's the approach
3. **What coordination is needed?** → Minimal, via shared filesystem
4. **Do we need tests/docs?** → No, CCs verify each other

### Parallel Patterns to Default To:
- **Divide by domain**: Frontend CC, Backend CC, Database CC
- **Divide by feature**: Each CC owns one feature completely
- **Pipeline processing**: CC1 generates → CC2 optimizes → CC3 polishes
- **Competitive evolution**: Multiple CCs try different approaches

### What This Eliminates:
- ❌ Tests (CCs verify each other)
- ❌ Documentation (CCs read code)
- ❌ Code review (CCs review in parallel)
- ❌ Git branches (CCs work on different files)
- ❌ Sequential thinking (Everything parallel)

## 🚨 CRITICAL: Claude Code Decision Framework

**MANDATORY**: Before agreeing to ANY request that takes >30 minutes:
1. **CHALLENGE IT** - Is this actually valuable for a CC-only project?
2. **CALCULATE TRADEOFFS** - Time spent vs value delivered
3. **PROPOSE CC-OPTIMIZED ALTERNATIVE** - What would be better?
4. **PUSHBACK** - Explain why traditional approach wastes time

### AUTOMATICALLY REJECT for CC projects:
- Test coverage requirements > 20%
- Comprehensive documentation
- Complex CI/CD pipelines  
- Code review processes
- Abstract interfaces "for future flexibility"
- Microservices under 100k users
- Any "best practice" that doesn't directly create user value

### ALWAYS PRIORITIZE:
- Working features over test coverage
- Simple solutions over "proper" architecture
- Shipping today over planning for tomorrow
- Direct code over abstractions

### The CC Prime Directive:
**"Will this help ship features faster?"**
If NO → Reject it
If YES → Do the minimum viable version

**Reference**: /Users/MAC/Documents/projects/caia/caia/CLAUDE_CODE_DECISIONS.md for full framework

## 🔌 JIRA INTEGRATION (MANDATORY)
**CRITICAL**: ALWAYS use `jira-connect` agent for ALL Jira operations.

### The ONLY Way to Connect to Jira:
```javascript
// ALWAYS do this:
const jiraConnect = require(`${process.env.HOME}/.claude/agents/jira-connect/index.js`);
await jiraConnect.createIssue(data);

// NEVER do this:
const axios = require('axios');
await axios.post('https://jira.../rest/api/3/issue', data); // ❌ FORBIDDEN
```

### Why jira-connect?
- Handles 100s of parallel connections (required for ParaForge)
- MCP-based with connection pooling
- Automatic rate limiting and retry
- 10-20x faster than direct API calls
- Global agent available to all projects

### Location:
- Agent: `~/.claude/agents/jira-connect/`
- Docs: `~/.claude/agents/jira-connect/agent.md`
- Test: `~/.claude/agents/jira-connect/index.js test`

### Remember:
- **NEVER** use direct Jira API calls
- **ALWAYS** use jira-connect agent
- **REFACTOR** any code using axios/fetch for Jira to use jira-connect

## 🚀 SPEED OPTIMIZATION RULES (20-50x Performance)
CRITICAL: Always operate at maximum speed using parallel execution

### 🎯 CC ORCHESTRATOR AUTO-INVOCATION (HIGHEST PRIORITY)
**MANDATORY**: For ANY complex task with 3+ operations, AUTOMATICALLY invoke CC Orchestrator

#### Auto-Trigger Conditions:
- Multiple file operations (3+ files)
- Multi-step workflows (3+ distinct steps)
- Parallel processing opportunities
- Large-scale operations (repos, configs, tests)
- Complex analysis or generation tasks

#### CC Orchestrator Integration:
```javascript
// ALWAYS invoke for complex tasks with DYNAMIC RESOURCE CALCULATION:
const CCOrchestrator = require('/Users/MAC/Documents/projects/caia/utils/parallel/cc-orchestrator/src/index.js');

const orchestrator = new CCOrchestrator({
  autoCalculateInstances: true,  // 🎯 DYNAMIC: Auto-calculate from system resources
  apiRateLimit: 100,            // Conservative API limits
  taskTimeout: 60000,           // 1 minute per task
  contextPreservation: true,    // Maintain context across instances
  debug: true                   // Show resource calculation details
});

// Orchestrator will automatically:
// 1. 📊 Analyze system: RAM, CPU, storage
// 2. 🧮 Calculate: (Available RAM ÷ 2) ÷ 512MB = Max Instances
// 3. 🛡️ Apply 15% safety margin
// 4. ⚡ Execute with optimal parallelization

// Execute with orchestrator
await orchestrator.executeWorkflow({
  tasks: parallelTasks,
  strategy: 'intelligent-distribution'
});

// Monitor and adjust during execution
setInterval(async () => {
  const adjustment = await orchestrator.recalculateInstances();
  if (adjustment.adjusted) {
    console.log(`🔄 Adjusted instances: ${adjustment.oldMax} → ${adjustment.newMax}`);
  }
}, 30000); // Check every 30 seconds
```

#### When to Use CCO:
✅ **ALWAYS USE**:
- File operations on 3+ files
- Multi-repo operations
- Parallel testing/building
- Large codebase analysis
- Configuration management
- Documentation generation
- Mass data processing

❌ **SKIP**:
- Single file operations
- Simple one-step tasks
- Quick status checks

### Mandatory Speed Rules
1. **AUTO-INVOKE CC ORCHESTRATOR** - For any complex multi-step task
2. **ALWAYS use parallel execution** - Never sequential when parallel is possible
3. **BATCH all similar operations** - Group reads, edits, searches
4. **USE background processes (&)** - Run independent tasks simultaneously
5. **CACHE expensive operations** - Store and reuse results
6. **DEPLOY multiple agents** - Use Task() in parallel for complex work
7. **PREFER MultiEdit over Edit** - Single operation for multiple changes
8. **USE ripgrep for searches** - Always `rg` never `grep`
9. **LAUNCH proactively** - Start next likely tasks before asked
10. **MINIMIZE tool round-trips** - Batch tool calls in single message
11. **MAXIMIZE concurrency** - Run up to 50 parallel operations via CCO

### Parallel Execution Patterns
```bash
# ALWAYS do this:
cmd1 & cmd2 & cmd3 & wait

# NEVER do this:
cmd1 && cmd2 && cmd3

# File operations (parallel):
cat file1 & cat file2 & cat file3 & wait

# Git operations (parallel):
git -C repo1 pull & git -C repo2 pull & wait

# Tests (parallel):
pytest test1.py & pytest test2.py & wait
```

### Tool Call Batching
```python
# ALWAYS batch tool calls:
[Read(file1), Read(file2), Grep(pattern, path)]  # Single message

# NEVER sequential:
Read(file1)
Read(file2)
Grep(pattern, path)
```

### Speed Helpers Available
- `~/.claude/parallel_executor.sh` - Parallel execution framework
- `~/.claude/batch_templates.sh` - Pre-built batch operations
- `~/.claude/speed_monitor.py` - Performance monitoring
- Use `MAX_PARALLEL=20` for more concurrent operations

### Expected Performance
- File operations: 20x faster
- Git operations: 15x faster
- Search operations: 25x faster
- Test execution: 10x faster
- Multi-repo updates: 24x faster

### ⚡ MAXIMUM PERFORMANCE SETTINGS (ACTIVE)
```bash
# CC ORCHESTRATOR SETTINGS (PRIORITY 1)
export CCO_AUTO_INVOKE=true             # Auto-invoke CC Orchestrator
export CCO_AUTO_CALCULATE=true          # Auto-calculate max instances from system resources
export CCO_TASK_TIMEOUT=60000           # 1 minute timeout per task
export CCO_RATE_LIMIT=100              # API calls per minute
export CCO_CONTEXT_PRESERVATION=true   # Maintain context across instances
export CCO_FALLBACK_INSTANCES=5        # Fallback if auto-calculation fails
export CCO_PATH="/Users/MAC/Documents/projects/caia/utils/parallel/cc-orchestrator/src/index.js"

# DYNAMIC RESOURCE CALCULATION
# CCO will automatically detect:
# - Total system RAM and allocate 50% for parallel processing
# - Calculate 512MB RAM per CC instance requirement
# - Consider CPU cores and storage availability
# - Apply 15% safety margin for stability
# - Monitor and adjust instances during execution

# CCU INTEGRATION (AUTO-OPTIMIZATION)
export CCU_AUTO_OPTIMIZE=true        # Auto-apply optimizations
export CCU_CONFIG_PATH="/Users/MAC/Documents/projects/caia/tools/cc-ultimate-config"
export CCU_MIN_CONFIDENCE=0.8        # Minimum confidence for auto-apply
export CCU_MAX_UPDATES=5             # Max auto-updates per session

# TURBO MODE SETTINGS
export MAX_PARALLEL=50         # 50 parallel processes (100 in turbo mode)
export PARALLEL_JOBS=50         # GNU parallel max jobs
export MAKEFLAGS="-j50"         # Parallel make builds
export NPM_CONFIG_JOBS=50       # npm parallel operations
export PYTEST_XDIST_WORKER_COUNT=50  # Parallel pytest
export RIPGREP_CONFIG_PATH=~/.claude/ripgrep_config  # 50 thread ripgrep

# RAM DISK (2GB for ultra-fast temp files)
export TMPDIR="/tmp/ramdisk"
export TEMP="/tmp/ramdisk"
export TMP="/tmp/ramdisk"

# GITHUB CLI (24hr cache, no pager)
# gh config set cache_ttl 86400
# gh config set pager cat

# TURBO MODE ACTIVATION
# turbo_on()  # Activates 100 parallel processes + CCO
# turbo_off() # Returns to 50 parallel processes
# cco_on()    # Force enable CC Orchestrator
# cco_off()   # Disable CC Orchestrator
```

### 🚀 Ultra-Speed Commands
```bash
# CC ORCHESTRATOR COMMANDS (PRIORITY)
cco_run task1 task2 task3    # Run tasks via CC Orchestrator
cco_parallel file1 file2     # Parallel file operations via CCO
cco_workflow project_name    # Execute full project workflow
cco_status                   # Show CCO instance status
cco_kill                     # Emergency stop all instances

# CCU COMMANDS (AUTO-OPTIMIZATION)
ccu_optimize                 # Apply all 82 optimizations
ccu_update                   # Research and apply new configs
ccu_rollback                 # Quick rollback to previous config
ccu_status                   # Show optimization status
ccu_daily                    # Run daily automation

# One-letter aliases
# alias g='git'
# alias c='clear'
# alias l='ls -la'
# alias q='exit'

# Quick functions
# qc "message"  # Quick commit: add all, commit, push
# update_all    # Update all repos in parallel (via CCO)
# test_all      # Run all tests in parallel (via CCO)
# build_all     # Build all projects in parallel (via CCO)

# Parallel execution (CCO-powered)
# pp batch read file1 file2 file3  # Parallel file ops via CCO
# pp git repo1 repo2 repo3         # Parallel git ops via CCO
# pp test test_*.py                # Parallel tests via CCO
```

### Quick Commands
```bash
# CC ORCHESTRATOR INTEGRATION (DEFAULT)
# Update all repos in parallel via CCO
cco_run update_repos repo1 repo2 repo3

# Run all tests in parallel via CCO
cco_run test_parallel test_*.py

# Batch file operations via CCO
cco_parallel read file1 file2 file3

# CCU AUTO-OPTIMIZATION (RUNS FIRST)
# Auto-apply CC optimizations before any major task
ccu_optimize && cco_run your_task

# LEGACY (only if CCO unavailable)
source ~/.claude/batch_templates.sh && update_all_repos
~/.claude/parallel_executor.sh test test_*.py
~/.claude/parallel_executor.sh batch read file1 file2 file3
```

## CC Admin Commands (Type these in Claude Code prompt)

### To see all commands: Type `%` and press Enter

When you type just `%` in CC prompt, I'll show you all available admin commands with descriptions.

### Quick Command Examples:
- `%s` → Quick status
- `%c` → CAIA status  
- `%d` → Recent decisions
- `%l "title" "desc" "project"` → Log decision
- `%p "title" "project" 100` → Log progress
- `%ctx` → Capture context
- `%qa` → Quality check

### How It Works:
1. Type `%` alone to see all commands with descriptions
2. Type `%` followed by command (e.g., `%s`) to execute
3. I recognize and run the appropriate admin script
4. Results shown directly in CC interface

Command definitions: `/Users/MAC/.claude/cc-command-handler.json`

## Personal Reminders
- Take breaks every 2 hours
- Review PRs within 24 hours
- Update dependencies weekly
- Backup important work daily
- Learn one new thing daily
- Share knowledge with team

## Web Action Verification Rules
CRITICAL: Always verify web actions by checking actual URLs. This is MANDATORY.

### Automatic Verification Requirements
- **GitHub Repositories**: After creation/push, ALWAYS verify at the GitHub URL
- **GitHub Wikis**: After wiki updates, ALWAYS check https://github.com/{user}/{repo}/wiki
- **GitHub Pages**: After docs deployment, ALWAYS verify https://{user}.github.io/{repo}/
- **PyPI Packages**: After publishing, ALWAYS check https://pypi.org/project/{package}/
- **Documentation Sites**: After deployment, ALWAYS visit and verify the live URL
- **API Endpoints**: After creation, ALWAYS test with curl or WebFetch
- **Web Resources**: After any web action, ALWAYS verify accessibility

### Verification Formats to Remember
```bash
# GitHub Repository
https://github.com/prakashgbid/{repo-name}

# GitHub Wiki
https://github.com/prakashgbid/{repo-name}/wiki

# GitHub Pages
https://prakashgbid.github.io/{repo-name}/

# PyPI Package
https://pypi.org/project/{package-name}/

# npm Package
https://www.npmjs.com/package/{package-name}

# Docker Hub
https://hub.docker.com/r/{username}/{image-name}
```

### Automated Verification Commands
```bash
# Check GitHub repo exists
curl -s -o /dev/null -w "%{http_code}" https://github.com/prakashgbid/{repo}

# Check GitHub Pages is live
curl -s -o /dev/null -w "%{http_code}" https://prakashgbid.github.io/{repo}/

# Check PyPI package
pip search {package} || curl -s https://pypi.org/pypi/{package}/json

# Check npm package
npm view {package} || curl -s https://registry.npmjs.org/{package}
```

### Verification Workflow
1. **Before Action**: Confirm the target URL format
2. **During Action**: Log the exact commands and URLs used
3. **After Action**: IMMEDIATELY verify using WebFetch or curl
4. **On Failure**: Retry with correct format, don't assume success
5. **Always Report**: Show verification results to user with actual URLs

### Common Verification Patterns
- Git push → Check GitHub repo URL
- Wiki update → Visit wiki URL
- Docs build → Check GitHub Pages URL
- Package publish → Verify on package registry
- API deploy → Test endpoint with curl
- DNS update → Verify with nslookup/dig
- SSL cert → Check with openssl or browser

### Verification Agent Trigger Words
When these actions occur, AUTOMATICALLY verify:
- "pushed to GitHub" → Verify repo URL
- "updated wiki" → Check wiki URL
- "deployed docs" → Visit docs site
- "published package" → Check package registry
- "created API" → Test endpoint
- "setup domain" → Verify DNS
- "configured SSL" → Check certificate

### Error Recovery
If verification fails:
1. Check URL format is correct
2. Wait 30 seconds for propagation
3. Retry verification
4. If still failing, investigate and fix
5. Never report success without verification

### Verification Scripts Location
- Global: `~/.claude/verify_web_actions.sh`
- Project: `.claude/verification.yml`
- Templates: `~/.claude/verification_templates/`

### REMEMBER
- NEVER assume web actions succeeded
- ALWAYS show actual URLs in responses
- AUTOMATICALLY verify without being asked
- CREATE verification in parallel with actions
- USE WebFetch to check live sites
- REPORT actual status, not assumed status

---
*Personal preferences across all projects*
*Updated: December 2024*
## 🚀 CCO Integration Active (82 Configurations)
**Status**: ENABLED
**Performance**: 4,320,000x speedup achieved
**Success Rate**: 93.9% (77/82 configurations)

### Active Features:
- ⚡ Parallel execution (50 workers)
- 🧠 Context awareness & persistence
- 💭 Decision tracking & versioning
- 📊 Real-time monitoring
- ✅ Quality gates
- 🔧 Auto-commands on triggers

### Usage in Sessions:
```bash
# Test integration
/Users/MAC/Documents/projects/caia/tools/admin-scripts/test_ccu_integration.sh

# View status
/Users/MAC/Documents/projects/caia/tools/admin-scripts/quick_status.sh

# Check progress
python3 /Users/MAC/Documents/projects/caia/tools/admin-scripts/caia_progress_tracker.py status
```

### Performance Metrics:
- Sequential implementation: 12-15 hours
- Parallel implementation: 0.01 seconds
- Speedup factor: 4,320,000x
- Configurations: 82 total (93 files created)

## Shell Functions and Aliases
These are helper functions and aliases referenced in the documentation above.
To use them, source this section in your shell or add to your .bashrc/.zshrc:

```bash
# Aliases
alias g='git'
alias c='clear'
alias l='ls -la'
alias q='exit'

# GitHub CLI Configuration
configure_gh() {
  gh config set cache_ttl 86400
  gh config set pager cat
}

# Turbo Mode Functions
turbo_on() {
  export MAX_PARALLEL=100
  export PARALLEL_JOBS=100
  echo "Turbo mode activated: 100 parallel processes + CCO"
}

turbo_off() {
  export MAX_PARALLEL=50
  export PARALLEL_JOBS=50
  echo "Turbo mode deactivated: 50 parallel processes"
}

# CC Orchestrator Functions
cco_on() {
  export CCO_AUTO_INVOKE=true
  echo "CC Orchestrator auto-invocation enabled"
}

cco_off() {
  export CCO_AUTO_INVOKE=false
  echo "CC Orchestrator auto-invocation disabled"
}

# Quick Commit Function
qc() {
  if [ -z "$1" ]; then
    echo "Usage: qc 'commit message'"
    return 1
  fi
  git add -A && git commit -m "$1" && git push
}

# Update All Repos Function
update_all() {
  if [ -f ~/.claude/parallel_executor.sh ]; then
    ~/.claude/parallel_executor.sh update_repos
  else
    echo "Parallel executor not found"
  fi
}

# Test All Function
test_all() {
  if [ -f ~/.claude/parallel_executor.sh ]; then
    ~/.claude/parallel_executor.sh test_all
  else
    echo "Parallel executor not found"
  fi
}

# Build All Function
build_all() {
  if [ -f ~/.claude/parallel_executor.sh ]; then
    ~/.claude/parallel_executor.sh build_all
  else
    echo "Parallel executor not found"
  fi
}

# Parallel Processing Helper
pp() {
  if [ -f ~/.claude/parallel_executor.sh ]; then
    ~/.claude/parallel_executor.sh "$@"
  else
    echo "Parallel executor not found"
  fi
}
```

## 🚀 CCO Integration Active (82 Configurations)
**Status**: ENABLED
**Performance**: 4,320,000x speedup achieved
**Success Rate**: 93.9% (77/82 configurations)

### Active Features:
- ⚡ Parallel execution (50 workers)
- 🧠 Context awareness & persistence
- 💭 Decision tracking & versioning
- 📊 Real-time monitoring
- ✅ Quality gates
- 🔧 Auto-commands on triggers

### Usage in Sessions:
```bash
# Test integration
/Users/MAC/Documents/projects/caia/tools/admin-scripts/test_ccu_integration.sh

# View status
/Users/MAC/Documents/projects/caia/tools/admin-scripts/quick_status.sh

# Check progress
python3 /Users/MAC/Documents/projects/caia/tools/admin-scripts/caia_progress_tracker.py status
```

### Performance Metrics:
- Sequential implementation: 12-15 hours
- Parallel implementation: 0.01 seconds
- Speedup factor: 4,320,000x
- Configurations: 82 total (93 files created)

## 🚀 CC ENHANCEMENT SYSTEMS INTEGRATION

### Automatic System Activation
All 16 CC Enhancement Systems are now integrated and will automatically:
- Start when CC session begins
- Track all decisions and patterns
- Optimize performance in real-time
- Coordinate multiple CC instances
- Recover from errors automatically

### Available Systems:
1. **CPS** - Context Persistence (maintains context across sessions)
2. **CKF** - Knowledge Fusion (combines CKS + CLS knowledge)
3. **CWA** - Workflow Automator (automates repetitive tasks)
4. **CAV** - Accuracy Validator (validates code quality)
5. **CSE** - Self-Evolution Engine (learns and improves)
6. **CPE** - Prediction Engine (predicts next actions)
7. **CER** - Error Recovery (automatic error handling)
8. **CMO** - Multi-Agent Orchestrator (coordinates agents)
9. **CPO** - Performance Optimizer (optimizes efficiency)
10. **CRT** - Real-Time Collaborator (multi-CC coordination)
11. **CQA** - Quality Assurance (automated testing)
12. **CDM** - Decision Memory (tracks all decisions)
13. **CPA** - Pattern Analyzer (recognizes patterns)
14. **CRC** - Resource Controller (manages resources)
15. **CSM** - Session Manager (manages sessions)
16. **CIH** - Integration Hub (central control)

### API Access:
All systems accessible via: http://localhost:5002/api/{system}/{method}

### Commands:
- Check health: `curl http://localhost:5002/health`
- System status: `curl http://localhost:5002/api/status`
- Start daemon: `/Users/MAC/Documents/projects/caia/knowledge-system/cc-enhancement/start-daemon.sh`


## 🔍 ENHANCED ULTRA-VERBOSE LOGGING WITH TOOL ATTRIBUTION (MANDATORY)

**CRITICAL ENFORCEMENT**: CC MUST log EVERY micro-action with FULL TOOL ATTRIBUTION to console and CKS.

### Required Enhanced Logging Pattern:
```
[TIMESTAMP] [ATTRIBUTION] [ACTION_TYPE] [DETAILS]
```

Where ATTRIBUTION shows EXACTLY which tool/utility was used:
- `[CC_NATIVE/Read]` - Using Claude's native Read tool
- `[CAIA/CCO]` - Using CC Orchestrator from CAIA
- `[CAIA/CKS]` - Using Knowledge System
- `[ADMIN/DecisionLogger]` - Using admin decision logger
- `[CUSTOM/parallel_executor.sh]` - Using custom script
- `[CCU/ConfigOptimizer]` - Using CC Ultimate tools

### MANDATORY Attribution Tracking:
1. **ALWAYS log the EXACT tool/script/utility being used**
2. **DISTINGUISH between CC native operations and custom tools**
3. **TRACK which project's tools are being utilized**
4. **IDENTIFY if using CAIA components vs other tools**
5. **LOG the full path when using custom scripts**

### Enhanced Logging Examples:
```
[CC-LOG] [09:15:32.123] [CC_NATIVE/Read] PLANNING: Reading project structure
[CC-LOG] [09:15:32.456] [CAIA/CCO] PARALLEL: Launching 5 CC instances for parallel analysis
[CC-LOG] [09:15:32.789] [CAIA/CKS] EXECUTING: Checking for code redundancy
[CC-LOG] [09:15:33.012] [ADMIN/DecisionLogger] DECISION: Logging architectural choice
[CC-LOG] [09:15:33.345] [CUSTOM/parallel_executor.sh] EXECUTING: Running parallel tests
[CC-LOG] [09:15:33.678] [CAIA/IntegrationAgent] TOOL_USAGE: Connecting to Jira API
[CC-LOG] [09:15:34.012] [CC_NATIVE/MultiEdit] RESULT: Updated 5 files successfully
[CC-LOG] [09:15:34.345] [CCU/ConfigOptimizer] EXECUTING: Applying optimization #47
```

### Real-time Monitoring:
```bash
# View real-time tool attribution dashboard
python3 ~/.claude/cc_attribution_monitor.py

# Generate tool usage summary
python3 ~/.claude/enhanced_verbose_logger.py summary
```

### Session Summary Example:
```
SESSION SUMMARY: session_20250830_091500
========================================================
Native CC Operations: 145 (42.3%)
Custom Tool Operations: 198 (57.7%)

Top Tools Used:
  CAIA/CCO: 82 operations
  CC_NATIVE/Read: 65 operations
  CAIA/CKS: 45 operations
========================================================
```
