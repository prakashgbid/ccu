#!/bin/bash

# Enable Wiki and GitHub Pages for all repositories
# Requires GitHub CLI (gh) to be installed and authenticated

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔧 Enabling GitHub Features for All Repositories${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

REPOS=(
    "prakashgbid/caia"
    "prakashgbid/roulette-community"
    "prakashgbid/orchestra"
    "prakashgbid/application-development-platform"
    "prakashgbid/caia-admin"
    "prakashgbid/memcore-ai"
    "prakashgbid/paraforge"
    "prakashgbid/smart-agents-training-system"
)

for repo in "${REPOS[@]}"; do
    echo -e "${YELLOW}Processing $repo...${NC}"
    
    # Enable Wiki
    gh api repos/$repo --method PATCH -f has_wiki=true 2>/dev/null && \
        echo -e "${GREEN}  ✅ Wiki enabled${NC}" || \
        echo -e "${YELLOW}  ⚠️  Could not enable Wiki${NC}"
    
    # Enable Issues (needed for discussions)
    gh api repos/$repo --method PATCH -f has_issues=true 2>/dev/null && \
        echo -e "${GREEN}  ✅ Issues enabled${NC}" || \
        echo -e "${YELLOW}  ⚠️  Issues already enabled${NC}"
    
    # Note: GitHub Pages must be configured manually through Settings
    echo -e "${BLUE}  ℹ️  GitHub Pages: Configure manually in Settings → Pages → Source: GitHub Actions${NC}"
    
    echo ""
done

echo -e "${GREEN}✅ Feature enablement complete!${NC}"
echo ""
echo -e "${YELLOW}📋 Manual Steps Still Required:${NC}"
echo "1. Enable GitHub Pages for each repository:"
echo "   - Go to: Settings → Pages"
echo "   - Source: Select 'GitHub Actions'"
echo "   - Click Save"
echo ""
echo -e "${BLUE}🔗 Quick Links to Repository Settings:${NC}"
for repo in "${REPOS[@]}"; do
    echo "  • https://github.com/$repo/settings/pages"
done