#!/bin/bash

# Auto-start CC Enhancement Systems on CC session start
CC_ENHANCEMENT_DIR="/Users/MAC/Documents/projects/caia/knowledge-system/cc-enhancement"

if [ -f "$CC_ENHANCEMENT_DIR/start-daemon.sh" ]; then
    "$CC_ENHANCEMENT_DIR/start-daemon.sh" > /dev/null 2>&1
fi

# Create session in Session Manager
if curl -s http://localhost:5002/health > /dev/null; then
    PROJECT_PATH=$(pwd)
    curl -s -X POST http://localhost:5002/api/csm/create_session \
        -H "Content-Type: application/json" \
        -d "{\"args\": [\"$PROJECT_PATH\"], \"kwargs\": {}}" > /dev/null
fi
