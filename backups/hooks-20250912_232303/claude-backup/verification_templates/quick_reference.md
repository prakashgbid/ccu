# Quick Reference - Web Action Verification

## Most Common Verifications

### After Git Push
```bash
repo="project-name"
curl -s -o /dev/null -w "GitHub: %{http_code}\n" https://github.com/prakashgbid/$repo
```

### After Wiki Update
```bash
repo="project-name"
curl -s -o /dev/null -w "Wiki: %{http_code}\n" https://github.com/prakashgbid/$repo/wiki
```

### After Docs Deploy
```bash
repo="project-name"
curl -s -o /dev/null -w "Pages: %{http_code}\n" https://prakashgbid.github.io/$repo/
```

### After Package Publish
```bash
# PyPI
package="package-name"
curl -s -o /dev/null -w "PyPI: %{http_code}\n" https://pypi.org/pypi/$package/json

# npm
package="package-name"
curl -s -o /dev/null -w "npm: %{http_code}\n" https://registry.npmjs.org/$package
```

## One-Liner Verification Scripts

### Verify Everything for a Project
```bash
project="evolux-ai" && \
echo "=== Verifying $project ===" && \
echo "GitHub: $(curl -s -o /dev/null -w "%{http_code}" https://github.com/prakashgbid/$project)" && \
echo "Wiki: $(curl -s -o /dev/null -w "%{http_code}" https://github.com/prakashgbid/$project/wiki)" && \
echo "Pages: $(curl -s -o /dev/null -w "%{http_code}" https://prakashgbid.github.io/$project/)" && \
echo "==================="
```

### Batch Verify All Projects
```bash
for repo in evolux-ai cognitron-engine codeforge-ai strategix-planner autonomix-engine flowmaster-orchestrator memcore-ai; do
  echo "$repo: $(curl -s -o /dev/null -w "%{http_code}" https://github.com/prakashgbid/$repo)"
done
```

## Using the Main Script

### Single Verification
```bash
~/.claude/verify_web_actions.sh github evolux-ai
~/.claude/verify_web_actions.sh wiki cognitron-engine
~/.claude/verify_web_actions.sh pages codeforge-ai
~/.claude/verify_web_actions.sh pypi evolux
```

### Batch Operations
```bash
# Verify all GitHub repos
~/.claude/verify_web_actions.sh batch github evolux-ai cognitron-engine codeforge-ai

# Verify all wikis
~/.claude/verify_web_actions.sh batch wiki evolux-ai cognitron-engine codeforge-ai

# Verify all Pages sites
~/.claude/verify_web_actions.sh batch pages evolux-ai cognitron-engine codeforge-ai
```

### Generate Report
```bash
~/.claude/verify_web_actions.sh report verification_report.md
```

## Python Agent Usage

### Quick Python Verification
```python
import asyncio
from web_verification_agent import WebVerificationAgent

async def verify():
    agent = WebVerificationAgent()
    results = await agent.batch_verify('github', ['evolux-ai', 'cognitron-engine'])
    print(agent.generate_report())

asyncio.run(verify())
```

## Expected HTTP Status Codes

| Action | Expected Code | Notes |
|--------|--------------|-------|
| GitHub Repo | 200 | Immediate |
| GitHub Wiki | 200 | Immediate |
| GitHub Pages | 200 | 5-10 min delay on first deploy |
| PyPI Package | 200 | After publish completes |
| npm Package | 200 | After publish completes |
| API Endpoint | 200, 201, 204 | Depends on endpoint |

## Troubleshooting

### 404 Not Found
- Check URL format is correct
- Verify resource was actually created
- Wait and retry (especially for Pages)

### 403 Forbidden
- Check permissions
- Verify authentication if needed

### Connection Timeout
- Check network connectivity
- Verify service is running
- Check firewall rules

## Remember
- Always verify, never assume
- Use actual URLs in responses
- Automate verification in parallel with actions
- Report real status to user