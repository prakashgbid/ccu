#!/bin/bash

# PreToolUse Hook - Check CKS before Write/Edit operations
# REALISTIC duplicate prevention

TOOL_NAME="$1"
FILE_PATH="$2"
SESSION_ID="${CC_SESSION_ID:-unknown}"

# Only check for Write and Edit tools
if [[ "$TOOL_NAME" == "Write" ]] || [[ "$TOOL_NAME" == "Edit" ]]; then
    
    # Extract filename
    FILENAME=$(basename "$FILE_PATH" 2>/dev/null)
    
    if [ -n "$FILENAME" ]; then
        # Check for similar files in CKS
        SIMILAR=$(sqlite3 /Users/MAC/Documents/projects/caia/knowledge-system/data/knowledge.db \
            "SELECT file_path FROM components WHERE file_path LIKE '%$FILENAME%' LIMIT 5" 2>/dev/null)
        
        if [ -n "$SIMILAR" ]; then
            echo "⚠️  CKS Warning: Similar files already exist:"
            echo "$SIMILAR" | head -3
            echo "Consider reusing existing code instead of creating new."
            echo "---"
        fi
        
        # Simple duplicate detection by filename pattern
        if [[ "$FILENAME" == *"test"* ]] || [[ "$FILENAME" == *"Test"* ]]; then
            EXISTING_TESTS=$(find /Users/MAC/Documents/projects -name "*test*.js" -o -name "*test*.py" 2>/dev/null | head -5)
            if [ -n "$EXISTING_TESTS" ]; then
                echo "📝 Note: Existing test files found. Consider adding to them:"
                echo "$EXISTING_TESTS" | head -3
                echo "---"
            fi
        fi
    fi
    
    # Log tool usage
    sqlite3 /Users/MAC/Documents/projects/caia/knowledge-system/data/patterns.db <<EOF
INSERT OR REPLACE INTO behavior_patterns (pattern_type, pattern_data, frequency)
VALUES ('tool_usage', '$TOOL_NAME', 
    COALESCE((SELECT frequency FROM behavior_patterns 
              WHERE pattern_type='tool_usage' AND pattern_data='$TOOL_NAME'), 0) + 1);
EOF
fi

# Never block execution
exit 0