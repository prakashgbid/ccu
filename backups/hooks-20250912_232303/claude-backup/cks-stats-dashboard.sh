#!/bin/bash

# ============================================================================
# CKS/CLS STATS DASHBOARD
# Shows learning progress automatically
# ============================================================================

show_dashboard() {
    clear
    echo "╔════════════════════════════════════════════════╗"
    echo "║         CKS/CLS LEARNING DASHBOARD             ║"
    echo "╚════════════════════════════════════════════════╝"
    echo ""
    
    # Get stats from API
    STATS=$(curl -s http://localhost:5004/stats 2>/dev/null)
    
    if [ -n "$STATS" ]; then
        INTERACTIONS=$(echo "$STATS" | jq -r '.total_interactions // 0')
        PATTERNS=$(echo "$STATS" | jq -r '.total_patterns // 0')
        SESSIONS=$(echo "$STATS" | jq -r '.total_sessions // 0')
        
        echo "📊 Learning Metrics:"
        echo "  • Total Interactions: $INTERACTIONS"
        echo "  • Patterns Learned: $PATTERNS"
        echo "  • Sessions Tracked: $SESSIONS"
        echo ""
        
        # Pattern breakdown
        echo "🧠 Pattern Types:"
        echo "$STATS" | jq -r '.patterns_by_type | to_entries[] | "  • \(.key): \(.value)"' 2>/dev/null
    else
        echo "⚠️  Stats service not available"
    fi
    
    echo ""
    
    # Check services
    echo "🔌 Service Status:"
    lsof -i :5000 > /dev/null 2>&1 && echo "  ✅ CKS API: Active" || echo "  ❌ CKS API: Down"
    lsof -i :5004 > /dev/null 2>&1 && echo "  ✅ Trainer: Active" || echo "  ❌ Trainer: Down"
    lsof -i :5555 > /dev/null 2>&1 && echo "  ✅ Bridge: Active" || echo "  ❌ Bridge: Down"
    
    echo ""
    
    # Recent activity
    echo "📝 Recent Activity:"
    if [ -f /tmp/cks_checks.log ]; then
        echo "  Last checks:"
        tail -3 /tmp/cks_checks.log 2>/dev/null | sed 's/^/    /'
    fi
    
    if [ -f /Users/MAC/.claude/cc_interaction_logs/interactions_$(date +%Y%m%d).jsonl ]; then
        COUNT=$(wc -l < /Users/MAC/.claude/cc_interaction_logs/interactions_$(date +%Y%m%d).jsonl)
        echo "  Today's logs: $COUNT entries"
    fi
    
    echo ""
    echo "Last updated: $(date '+%Y-%m-%d %H:%M:%S')"
}

# If running interactively, show dashboard
if [ -t 1 ]; then
    show_dashboard
else
    # If running in background, save to file
    show_dashboard > /tmp/cks_dashboard.txt
fi