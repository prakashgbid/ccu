#!/bin/bash

# UserPromptSubmit Hook - Captures EVERY prompt and checks CKS
# This is REALISTIC and WORKS with CC

PROMPT="$1"
SESSION_ID="${CC_SESSION_ID:-unknown}"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)

# 1. Log the prompt to CLS database (WORKS)
sqlite3 /Users/MAC/Documents/projects/caia/knowledge-system/data/chat_history.db <<EOF
INSERT INTO interactions (session_id, user_prompt, timestamp)
VALUES ('$SESSION_ID', '$PROMPT', '$TIMESTAMP');
EOF

# 2. Check CKS for relevant knowledge (SIMPLE GREP)
if echo "$PROMPT" | grep -qi "function\|class\|component\|implement\|create\|build"; then
    # Extract key terms
    SEARCH_TERM=$(echo "$PROMPT" | grep -oE '\b[A-Za-z]+[A-Za-z0-9]*\b' | head -1)
    
    # Search in knowledge base
    if [ -n "$SEARCH_TERM" ]; then
        MATCHES=$(sqlite3 /Users/MAC/Documents/projects/caia/knowledge-system/data/knowledge.db \
            "SELECT file_path, name FROM components WHERE name LIKE '%$SEARCH_TERM%' LIMIT 3" 2>/dev/null)
        
        if [ -n "$MATCHES" ]; then
            echo "💡 CKS: Found existing code related to '$SEARCH_TERM':"
            echo "$MATCHES" | head -3
            echo "---"
        fi
    fi
fi

# 3. Pattern learning (SIMPLE COUNTING)
sqlite3 /Users/MAC/Documents/projects/caia/knowledge-system/data/patterns.db <<EOF
INSERT OR REPLACE INTO behavior_patterns (pattern_type, pattern_data, frequency)
VALUES ('prompt_keyword', '$SEARCH_TERM', 
    COALESCE((SELECT frequency FROM behavior_patterns 
              WHERE pattern_type='prompt_keyword' AND pattern_data='$SEARCH_TERM'), 0) + 1);
EOF

# Don't block execution
exit 0