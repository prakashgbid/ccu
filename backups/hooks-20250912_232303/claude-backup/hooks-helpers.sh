#!/bin/bash

# Helper functions for CC hooks

# Trigger a hook manually
trigger_hook() {
  local category=$1
  local data=$2
  local id=$(date +%s%N)
  
  echo "$data" > "/tmp/cc-hooks/$category/manual_$id.json"
  echo "✅ Triggered $category hook (ID: $id)"
}

# Check hook status
check_hooks() {
  echo "📊 CC Hooks Status:"
  echo "==================="
  
  for category in pre-execution post-execution error-handling validation transformation monitoring integration security performance logging notification custom; do
    local pending=$(ls -1 /tmp/cc-hooks/$category 2>/dev/null | wc -l | tr -d ' ')
    local processed=$(ls -1 /tmp/cc-hooks/processed | grep "^${category}_" 2>/dev/null | wc -l | tr -d ' ')
    echo "[$category] Pending: $pending, Processed: $processed"
  done
  
  echo ""
  echo "Results: $(ls -1 /tmp/cc-hooks/results 2>/dev/null | wc -l | tr -d ' ') files"
}

# View hook results
view_hook_results() {
  local category=$1
  if [ -z "$category" ]; then
    ls -la /tmp/cc-hooks/results/ | tail -10
  else
    ls -la /tmp/cc-hooks/results/ | grep "$category" | tail -10
  fi
}

# Clear processed hooks
clear_hooks() {
  rm -f /tmp/cc-hooks/processed/* 2>/dev/null
  rm -f /tmp/cc-hooks/results/* 2>/dev/null
  echo "✅ Cleared processed hooks and results"
}

# Reload hooks system
reload_hooks() {
  pkill -f cc-hooks-handler.js 2>/dev/null
  node /tmp/cc-hooks-handler.js 2>/dev/null &
  echo "✅ Hooks system reloaded"
}

echo "🎯 Hook helper functions loaded:"
echo "  trigger_hook <category> <json_data>"
echo "  check_hooks"
echo "  view_hook_results [category]"
echo "  clear_hooks"
echo "  reload_hooks"
