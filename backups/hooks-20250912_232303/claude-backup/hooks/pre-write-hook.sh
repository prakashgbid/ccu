#!/bin/bash
# Auto-checks CKS before any write operation

if [ -f /Users/MAC/.claude/agents/knowledge-checker/index.js ]; then
    QUERY="${1:-$2}"
    node /Users/MAC/.claude/agents/knowledge-checker/index.js "$QUERY" 2>/dev/null | head -5
fi
