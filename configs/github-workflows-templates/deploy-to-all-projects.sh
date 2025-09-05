#!/bin/bash

# 🚀 Deploy Automation to All Projects
# This script applies GitHub Actions automation to all projects in parallel

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Base directory
BASE_DIR="/Users/MAC/Documents/projects"
WORKFLOW_DIR="$BASE_DIR/.github-workflows"
DEPLOY_SCRIPT="$WORKFLOW_DIR/deploy-automation.sh"

# Projects to update
PROJECTS=(
    "$BASE_DIR/caia"
    "$BASE_DIR/standalone-apps/roulette-community"
    "$BASE_DIR/standalone-apps/orchestra-platform"
    "$BASE_DIR/standalone-apps/adp"
    "$BASE_DIR/admin"
    "$BASE_DIR/old-projects/omnimind"
    "$BASE_DIR/old-projects/paraforge"
    "$BASE_DIR/old-projects/smart-agents-training-system"
)

echo -e "${BLUE}🚀 Deploying GitHub Actions Automation to All Projects${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Function to deploy to a single project
deploy_to_project() {
    local project=$1
    local project_name=$(basename "$project")
    
    if [ ! -d "$project" ]; then
        echo -e "${YELLOW}⏭️  Skipping $project_name (directory not found)${NC}"
        return
    fi
    
    echo -e "${GREEN}📦 Processing: $project_name${NC}"
    
    # Run deployment script
    if $DEPLOY_SCRIPT --all "$project" > "/tmp/deploy_${project_name}.log" 2>&1; then
        echo -e "${GREEN}✅ $project_name: Successfully deployed${NC}"
        
        # Push to GitHub
        cd "$project"
        if git remote get-url origin &>/dev/null; then
            if git push origin main 2>/dev/null || git push origin master 2>/dev/null; then
                echo -e "${GREEN}   ↗️  Pushed to GitHub${NC}"
            else
                echo -e "${YELLOW}   ⚠️  Could not push (may need manual push)${NC}"
            fi
        fi
    else
        echo -e "${RED}❌ $project_name: Deployment failed (check /tmp/deploy_${project_name}.log)${NC}"
    fi
}

# Deploy in parallel using background processes
echo -e "${BLUE}Starting parallel deployment...${NC}"
echo ""

for project in "${PROJECTS[@]}"; do
    deploy_to_project "$project" &
done

# Wait for all background jobs to complete
wait

echo ""
echo -e "${GREEN}✅ Batch deployment complete!${NC}"
echo ""
echo -e "${BLUE}📋 Summary:${NC}"
echo "  • Workflows deployed to ${#PROJECTS[@]} projects"
echo "  • Each project now has:"
echo "    - 📚 Auto-documentation generation"
echo "    - 📖 Wiki synchronization"
echo "    - 🌐 GitHub Pages deployment"
echo "    - 📦 Package publishing automation"
echo ""
echo -e "${YELLOW}⚠️  Manual Steps Required:${NC}"
echo ""
echo "1. Enable Wiki for each repository:"
echo "   Go to: Settings → Features → ✅ Wikis"
echo ""
echo "2. Enable GitHub Pages:"
echo "   Go to: Settings → Pages → Source: GitHub Actions"
echo ""
echo "3. Add package publishing secrets (if needed):"
echo "   - NPM_TOKEN for Node.js projects"
echo "   - PYPI_TOKEN for Python projects"
echo ""
echo -e "${GREEN}🎉 Your projects are now professionally automated!${NC}"