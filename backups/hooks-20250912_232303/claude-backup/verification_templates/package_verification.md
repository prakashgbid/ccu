# Package Registry Verification Template

## PyPI Package Verification
```bash
# Check if package exists on PyPI
curl -s https://pypi.org/pypi/{package}/json | jq -r '.info.name'

# Expected: Package name returned
# URL Format: https://pypi.org/project/{package-name}/
# Install: pip install {package-name}
```

## npm Package Verification
```bash
# Check if package exists on npm
npm view {package} name 2>/dev/null

# Or using curl:
curl -s https://registry.npmjs.org/{package} | jq -r '.name'

# Expected: Package name returned
# URL Format: https://www.npmjs.com/package/{package-name}
# Install: npm install {package-name}
```

## Docker Hub Verification
```bash
# Check if image exists on Docker Hub
curl -s https://hub.docker.com/v2/repositories/{username}/{image}/ | jq -r '.name'

# Expected: Image name returned
# URL Format: https://hub.docker.com/r/{username}/{image-name}
# Pull: docker pull {username}/{image-name}
```

## Quick Package Verification
```bash
# PyPI
package="evolux"
curl -s -o /dev/null -w "%{http_code}" https://pypi.org/pypi/$package/json

# npm
package="@myorg/package"
curl -s -o /dev/null -w "%{http_code}" https://registry.npmjs.org/$package

# Docker
image="myuser/myimage"
curl -s -o /dev/null -w "%{http_code}" https://hub.docker.com/v2/repositories/$image/
```

## Using the verification script
```bash
~/.claude/verify_web_actions.sh pypi evolux
~/.claude/verify_web_actions.sh npm @myorg/package
```