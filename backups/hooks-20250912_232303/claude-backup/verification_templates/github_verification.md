# GitHub Verification Template

## Repository Verification
```bash
# Check if repository exists
curl -s -o /dev/null -w "%{http_code}" https://github.com/{user}/{repo}

# Expected: 200 OK
# URL Format: https://github.com/prakashgbid/{repo-name}
```

## Wiki Verification
```bash
# Check if wiki is accessible
curl -s -o /dev/null -w "%{http_code}" https://github.com/{user}/{repo}/wiki

# Expected: 200 OK
# URL Format: https://github.com/prakashgbid/{repo-name}/wiki
```

## GitHub Pages Verification
```bash
# Check if Pages site is live
curl -s -o /dev/null -w "%{http_code}" https://{user}.github.io/{repo}/

# Expected: 200 OK (may take 5-10 minutes after first deployment)
# URL Format: https://prakashgbid.github.io/{repo-name}/
```

## Quick Verification Commands
```bash
# Verify all at once
repo="evolux-ai"
echo "Repo: $(curl -s -o /dev/null -w "%{http_code}" https://github.com/prakashgbid/$repo)"
echo "Wiki: $(curl -s -o /dev/null -w "%{http_code}" https://github.com/prakashgbid/$repo/wiki)"
echo "Pages: $(curl -s -o /dev/null -w "%{http_code}" https://prakashgbid.github.io/$repo/)"
```

## Using the verification script
```bash
~/.claude/verify_web_actions.sh github evolux-ai
~/.claude/verify_web_actions.sh wiki evolux-ai
~/.claude/verify_web_actions.sh pages evolux-ai
```

## Batch verification
```bash
~/.claude/verify_web_actions.sh batch github evolux-ai cognitron-engine codeforge-ai
```