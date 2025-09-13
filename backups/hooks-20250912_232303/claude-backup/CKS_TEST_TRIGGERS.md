# CKS/CLS Test Suite Trigger Commands

## IMPORTANT: Auto-Test Recognition

When Claude Code sees ANY of these phrases in a user prompt, it should IMMEDIATELY run the corresponding test without asking for confirmation:

### Primary Triggers (Run Full Test):
- **"Run CKS test suite"**
- **"Test CKS integration"** 
- **"Verify learning system"**
- **"%cks test"**
- **"%cks full"**

### Quick Check Triggers:
- **"CKS health check"**
- **"Check learning APIs"**
- **"%cks health"**

### Specific Test Triggers:
- **"Test auto-indexing"**
- **"Verify indexing"**
- **"%cks index"**

### Evolution Triggers:
- **"Evolve tests"**
- **"Update test suite"**
- **"%cks evolve"**

## Automatic Execution:

When any trigger is detected, Claude should:

1. Immediately run: `/Users/MAC/.claude/cks_test_triggers.sh "[trigger phrase]"`
2. Display results in real-time
3. If test fails, run self-healing: `python3 /Users/MAC/Documents/projects/caia/knowledge-system/scripts/self_learning_test_updater.py`
4. Log results to: `/Users/MAC/Documents/projects/caia/knowledge-system/logs/`

## Background Testing:

- **Every CC session**: Tests run automatically on startup
- **Real-time monitoring**: CKS Change Monitor watches for updates
- **Automatic evolution**: Tests evolve immediately when CKS is updated
- **On failures**: Self-learning updater adjusts tests

## Real-Time Evolution Triggers:

The test suite evolves AUTOMATICALLY when:
- Any CKS Python file is modified
- API endpoints are added/changed
- Database schema is updated
- Configuration files are changed
- New integrations are added
- CC configurations are updated
- New agents or hooks are added

## Manual Evolution Commands:

- **`Evolve CKS tests`** - Force evolution now
- **`/Users/MAC/Documents/projects/caia/knowledge-system/scripts/cks_evolution_manager.sh evolve`**
- **`%cks evolve`** - Quick evolution trigger

## Monitor Management:

- **Start monitor**: `/Users/MAC/Documents/projects/caia/knowledge-system/scripts/start_cks_monitor.sh start`
- **Stop monitor**: `/Users/MAC/Documents/projects/caia/knowledge-system/scripts/start_cks_monitor.sh stop`
- **Check status**: `/Users/MAC/Documents/projects/caia/knowledge-system/scripts/start_cks_monitor.sh status`

## Response Format:

```
🔍 Running CKS/CLS Test Suite...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ API Health: PASS (all 4 APIs)
✅ Indexing: PASS (5-10 seconds)
✅ Concurrency: PASS (50+ connections)
⚠️ Performance: WARNING (response >100ms)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 Overall: OPERATIONAL
```

## Self-Learning Features:

The test suite automatically:
- Discovers new APIs and endpoints
- Detects new database tables and columns
- Identifies new file types for indexing
- Finds new integration points
- Adjusts tests based on consistent failures
- Adds tests for newly discovered capabilities

## Manual Override:

To force evolution: `python3 /Users/MAC/Documents/projects/caia/knowledge-system/scripts/self_learning_test_updater.py`
To see history: `cat /Users/MAC/Documents/projects/caia/knowledge-system/logs/test_evolution.json`