# CC Workflow Initialization Prompt

## 🚀 COPY AND PASTE THIS AT SESSION START:

```
Initialize CC workflow system. Load and enforce:
1. CKS mandatory checks before code
2. Parallel-first decomposition 
3. Integration Agent for external services
4. CC Orchestrator for parallel execution
5. No direct API calls, no sequential when parallel possible

Run: source ~/.claude/init-cc-workflow.sh
Show me the workflow rules and confirm initialization.
```

## 🎯 OR USE THESE SHORTER TRIGGERS:

### Option 1 - Ultra Short:
```
Load CC workflow rules from CLAUDE.md
```

### Option 2 - Reminder:
```
Enforce CKS + Parallel + Integration Agent workflow
```

### Option 3 - Direct Command:
```
%workflow
```

## 📋 WORKFLOW ENFORCEMENT CHECKLIST:

Before EVERY task, I must:
- [ ] Check CKS for existing implementations
- [ ] Scan architecture patterns
- [ ] Decompose into parallel phases
- [ ] Use Integration Agent only (no axios/fetch)
- [ ] Launch parallel CC instances
- [ ] Update CKS after implementation

## 🚨 RED FLAGS (Stop me immediately if I):
- Start coding without CKS check
- Use direct API calls instead of Integration Agent
- Implement sequentially when parallel is possible
- Skip decomposition analysis
- Don't show parallel phases before coding