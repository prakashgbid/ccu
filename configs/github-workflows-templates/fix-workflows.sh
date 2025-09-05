#!/bin/bash

# Fix workflow files to handle missing lock files

echo "🔧 Fixing GitHub Actions workflows to handle missing lock files..."

# List of projects to fix
PROJECTS=(
    "/Users/MAC/Documents/projects/caia"
    "/Users/MAC/Documents/projects/standalone-apps/roulette-community"
    "/Users/MAC/Documents/projects/standalone-apps/orchestra-platform"
    "/Users/MAC/Documents/projects/standalone-apps/adp"
    "/Users/MAC/Documents/projects/admin"
    "/Users/MAC/Documents/projects/old-projects/omnimind"
    "/Users/MAC/Documents/projects/old-projects/paraforge"
    "/Users/MAC/Documents/projects/old-projects/smart-agents-training-system"
)

for project in "${PROJECTS[@]}"; do
    if [ -d "$project/.github/workflows" ]; then
        echo "📁 Fixing workflows in $(basename $project)..."
        
        # Fix pages-deploy.yml - remove cache requirement
        if [ -f "$project/.github/workflows/pages-deploy.yml" ]; then
            sed -i.bak "s/cache: 'npm'/# cache: 'npm' # Disabled due to missing lock file/" "$project/.github/workflows/pages-deploy.yml"
        fi
        
        # Fix auto-docs.yml - remove cache requirement
        if [ -f "$project/.github/workflows/auto-docs.yml" ]; then
            sed -i.bak "/cache:/d" "$project/.github/workflows/auto-docs.yml"
        fi
        
        # Commit the fixes
        cd "$project"
        if git diff --quiet; then
            echo "  No changes needed"
        else
            git add .github/workflows/
            git commit -m "🔧 Fix workflows to handle missing lock files" 2>/dev/null
            git push 2>/dev/null && echo "  ✅ Fixed and pushed" || echo "  ⚠️  Fixed locally"
        fi
    fi
done

echo ""
echo "✅ Workflow fixes complete!"