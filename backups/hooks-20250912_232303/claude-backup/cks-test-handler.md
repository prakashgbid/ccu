# CKS/CLS Test Suite Trigger Commands

## TRIGGER PHRASES (Use any of these to run the comprehensive test):

1. **"Run CKS test suite"** - Runs full comprehensive test
2. **"Test CKS integration"** - Runs integration test
3. **"Verify learning system"** - Runs verification suite
4. **"CKS health check"** - Quick health check
5. **"Test auto-indexing"** - Tests indexing specifically
6. **"%cks test"** - Short command version
7. **"%cks full"** - Full comprehensive test

## AUTOMATIC TRIGGERS:

When Claude Code sees ANY of these phrases, it should:
1. Immediately run: `/Users/MAC/Documents/projects/caia/knowledge-system/scripts/run_integration_test.sh`
2. If that fails, run the self-healing script: `/Users/MAC/Documents/projects/caia/knowledge-system/scripts/self_heal_cks.sh`
3. Log results to: `/Users/MAC/Documents/projects/caia/knowledge-system/logs/test_results/`
4. Update the test suite if new capabilities are detected

## RESPONSE FORMAT:

When triggered, CC should respond with:
```
🔍 Running CKS/CLS Comprehensive Test Suite...
[Real-time updates as tests progress]
📊 Test Results: [PASS/FAIL summary]
```