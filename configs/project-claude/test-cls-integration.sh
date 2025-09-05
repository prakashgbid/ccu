#!/bin/bash
# Test CLS Integration for CC Auto-Approval Events

echo "🧪 Testing CKS/CLS Integration"
echo "==============================="
echo ""

echo "📡 Testing CLS Event Endpoints..."

# Test data for cc-approval event
approval_data='{
  "event_type": "cc_auto_approval",
  "timestamp": "'$(date '+%Y-%m-%d %H:%M:%S')'",
  "session_id": "test-session",
  "tool_name": "Bash",
  "approval_status": "AUTO-APPROVED",
  "approval_reason": "Test integration",
  "details": "Command: echo test",
  "source": "claude_code",
  "project": "caia",
  "auto_approved": true,
  "project_path": "/Users/MAC/Documents/projects"
}'

# Test data for execution result
result_data='{
  "event_type": "cc_execution_result", 
  "timestamp": "'$(date '+%Y-%m-%d %H:%M:%S')'",
  "session_id": "test-session",
  "tool_name": "Bash",
  "result_status": "SUCCESS",
  "details": "Exit: 0",
  "success": "true",
  "source": "claude_code",
  "project": "caia",
  "project_path": "/Users/MAC/Documents/projects"
}'

echo "🔄 Sending test approval event to CLS..."
approval_response=$(curl -s -w "\n%{http_code}" -X POST "http://localhost:5003/events/cc-approval" \
  -H "Content-Type: application/json" \
  -d "$approval_data")

approval_code=$(echo "$approval_response" | tail -n1)
approval_body=$(echo "$approval_response" | head -n -1)

echo "   HTTP Status: $approval_code"
if [ "$approval_code" -eq 200 ] || [ "$approval_code" -eq 201 ]; then
    echo "   ✅ Approval event accepted"
else
    echo "   ❌ Approval event failed: $approval_body"
fi

echo ""
echo "🔄 Sending test result event to CLS..."
result_response=$(curl -s -w "\n%{http_code}" -X POST "http://localhost:5003/events/cc-result" \
  -H "Content-Type: application/json" \
  -d "$result_data")

result_code=$(echo "$result_response" | tail -n1)
result_body=$(echo "$result_response" | head -n -1)

echo "   HTTP Status: $result_code"
if [ "$result_code" -eq 200 ] || [ "$result_code" -eq 201 ]; then
    echo "   ✅ Result event accepted"
else
    echo "   ❌ Result event failed: $result_body"
fi

echo ""
echo "🔍 Testing CKS API endpoints..."
echo "   Health: $(curl -s http://localhost:5555/health | jq -r '.status // "unknown"')"

echo ""
echo "💡 If events are failing, we may need to:"
echo "   • Check CLS API documentation for correct endpoints"
echo "   • Verify CLS is configured to accept CC events"
echo "   • Update hook URLs to match CLS API structure"