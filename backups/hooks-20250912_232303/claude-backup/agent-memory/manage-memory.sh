#!/bin/bash

# Agent Memory Management Tool

case "$1" in
  "status")
    echo "Agent Memory System Status"
    echo "=========================="
    echo "Agents with memory: $(ls -1 ~/.claude/agent-memory/agents | wc -l)"
    echo "Total interactions: $(grep -h '"interactions":' ~/.claude/agent-memory/agents/*/memory.json | awk '{sum+=$2} END {print sum}')"
    echo "Patterns discovered: $(grep -h '"patterns_discovered":' ~/.claude/agent-memory/agents/*/memory.json | awk '{sum+=$2} END {print sum}')"
    ;;
    
  "backup")
    echo "Backing up agent memory..."
    tar -czf ~/.claude/agent-memory-backup-$(date +%Y%m%d).tar.gz ~/.claude/agent-memory
    echo "Backup created"
    ;;
    
  "stats")
    agent=$2
    if [ -z "$agent" ]; then
      echo "Usage: $0 stats <agent-name>"
      exit 1
    fi
    echo "Stats for $agent:"
    cat ~/.claude/agent-memory/agents/$agent/memory.json | python3 -m json.tool | grep -E '"interactions"|"patterns_discovered"|"time_saved"'
    ;;
    
  *)
    echo "Agent Memory Management"
    echo "Usage:"
    echo "  $0 status    - Show system status"
    echo "  $0 backup    - Backup all memory"
    echo "  $0 stats <agent> - Show agent stats"
    ;;
esac
