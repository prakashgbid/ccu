#!/bin/bash

# CKS Test Trigger Recognition
# This script is called when specific prompts are detected

trigger="$1"

case "$trigger" in
    "run cks test suite"|"test cks integration"|"verify learning system")
        echo "🔍 Running CKS/CLS Comprehensive Test Suite..."
        /Users/MAC/Documents/projects/caia/knowledge-system/scripts/run_integration_test.sh
        ;;
    "cks health check")
        echo "🏥 Quick CKS Health Check..."
        curl -s http://localhost:5555/health
        curl -s http://localhost:5002/health
        curl -s http://localhost:5003/health
        curl -s http://localhost:5000/health
        ;;
    "test auto-indexing")
        echo "📝 Testing auto-indexing..."
        timestamp=$(date +%s)
        echo "def test_$timestamp(): return 'test'" > /tmp/test_$timestamp.py
        sleep 10
        sqlite3 /Users/MAC/Documents/projects/caia/knowledge-system/data/caia_knowledge.db \
            "SELECT COUNT(*) FROM functions WHERE name LIKE '%test_$timestamp%';"
        ;;
    "evolve tests")
        echo "🧬 Evolving test suite..."
        python3 /Users/MAC/Documents/projects/caia/knowledge-system/scripts/self_learning_test_updater.py
        ;;
    *)
        echo "Unknown trigger: $trigger"
        ;;
esac
