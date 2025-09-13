# API Endpoint Verification Template

## REST API Verification
```bash
# Basic endpoint check
curl -s -o /dev/null -w "%{http_code}" https://api.example.com/health

# With authentication
curl -s -H "Authorization: Bearer TOKEN" \
     -o /dev/null -w "%{http_code}" https://api.example.com/v1/resource

# POST request verification
curl -s -X POST https://api.example.com/v1/resource \
     -H "Content-Type: application/json" \
     -d '{"test": "data"}' \
     -o /dev/null -w "%{http_code}"
```

## GraphQL Endpoint Verification
```bash
# GraphQL health check
curl -s -X POST https://api.example.com/graphql \
     -H "Content-Type: application/json" \
     -d '{"query": "{ __typename }"}' \
     -o /dev/null -w "%{http_code}"
```

## WebSocket Verification
```bash
# Check WebSocket upgrade
curl -s -o /dev/null -w "%{http_code}" \
     -H "Upgrade: websocket" \
     -H "Connection: Upgrade" \
     https://ws.example.com/socket
```

## API Response Validation
```bash
# Check response content
response=$(curl -s https://api.example.com/version)
echo $response | jq -r '.version'

# Validate response structure
curl -s https://api.example.com/health | \
     jq -e '.status == "healthy"' > /dev/null && echo "✅ API healthy" || echo "❌ API unhealthy"
```

## Load Testing
```bash
# Simple concurrent requests
for i in {1..10}; do
  curl -s -o /dev/null -w "%{http_code}\n" https://api.example.com/health &
done
wait
```

## Using the verification script
```bash
~/.claude/verify_web_actions.sh url https://api.example.com/health "API Health Check"
```