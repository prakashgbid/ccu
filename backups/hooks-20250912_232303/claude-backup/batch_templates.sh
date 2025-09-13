#!/bin/bash

# Batch Operation Templates for Maximum Speed
# Pre-built templates for common operations

# Multi-repo operations
update_all_repos() {
    echo "📦 Updating all repositories in parallel..."
    find . -type d -name ".git" -prune | while read git_dir; do
        repo_dir=$(dirname "$git_dir")
        (
            cd "$repo_dir"
            echo "Updating: $(basename $repo_dir)"
            git pull --rebase
        ) &
    done
    wait
    echo "✅ All repos updated"
}

# Mass file operations
mass_replace() {
    local old="$1"
    local new="$2"
    local pattern="${3:-*.py}"
    
    echo "🔄 Replacing '$old' with '$new' in $pattern files..."
    find . -type f -name "$pattern" -print0 | \
        xargs -0 -P 10 -I {} sed -i "s/$old/$new/g" {}
    echo "✅ Replacement complete"
}

# Parallel testing
test_all() {
    echo "🧪 Running all tests in parallel..."
    find . -name "*test*.py" -o -name "*_test.py" | \
        parallel -j 10 "echo Testing: {} && python3 {}"
    echo "✅ All tests complete"
}

# Build all projects
build_all() {
    echo "🔨 Building all projects in parallel..."
    find . -name "package.json" -not -path "*/node_modules/*" | while read pkg; do
        dir=$(dirname "$pkg")
        (
            cd "$dir"
            echo "Building: $(basename $dir)"
            npm run build
        ) &
    done
    wait
    echo "✅ All builds complete"
}

# Install dependencies everywhere
install_all_deps() {
    echo "📦 Installing dependencies in all projects..."
    
    # Node projects
    find . -name "package.json" -not -path "*/node_modules/*" | while read pkg; do
        (cd $(dirname "$pkg") && npm install) &
    done
    
    # Python projects
    find . -name "requirements.txt" | while read req; do
        (cd $(dirname "$req") && pip install -r requirements.txt) &
    done
    
    wait
    echo "✅ All dependencies installed"
}

# Clean all projects
clean_all() {
    echo "🧹 Cleaning all projects..."
    
    # Remove node_modules
    find . -type d -name "node_modules" -exec rm -rf {} + 2>/dev/null &
    
    # Remove Python cache
    find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null &
    find . -type f -name "*.pyc" -delete &
    
    # Remove build directories
    find . -type d -name "dist" -o -name "build" -exec rm -rf {} + 2>/dev/null &
    
    wait
    echo "✅ All projects cleaned"
}

# Lint all code
lint_all() {
    echo "🔍 Linting all code in parallel..."
    
    # Python
    find . -name "*.py" | parallel -j 10 "ruff check {}" &
    
    # JavaScript/TypeScript
    find . -name "*.js" -o -name "*.ts" | parallel -j 10 "eslint {}" &
    
    wait
    echo "✅ Linting complete"
}

# Format all code
format_all() {
    echo "✨ Formatting all code..."
    
    # Python
    find . -name "*.py" | parallel -j 10 "black {}" &
    
    # JavaScript/TypeScript
    find . -name "*.js" -o -name "*.ts" | parallel -j 10 "prettier --write {}" &
    
    wait
    echo "✅ Formatting complete"
}

# Deploy all services
deploy_all() {
    echo "🚀 Deploying all services..."
    
    # Find all deploy scripts
    find . -name "deploy.sh" -o -name "deploy.py" | while read script; do
        (
            cd $(dirname "$script")
            echo "Deploying: $(basename $(pwd))"
            bash "$script" || python3 "$script"
        ) &
    done
    wait
    echo "✅ All deployments complete"
}

# Docker operations
docker_build_all() {
    echo "🐳 Building all Docker images..."
    find . -name "Dockerfile" | while read dockerfile; do
        dir=$(dirname "$dockerfile")
        name=$(basename "$dir")
        (
            cd "$dir"
            echo "Building: $name"
            docker build -t "$name:latest" .
        ) &
    done
    wait
    echo "✅ All Docker images built"
}

# Create multiple projects
scaffold_projects() {
    local template="$1"
    shift
    local projects=("$@")
    
    echo "🏗️ Scaffolding ${#projects[@]} projects..."
    for project in "${projects[@]}"; do
        (
            echo "Creating: $project"
            npx create-$template "$project" --yes
        ) &
    done
    wait
    echo "✅ All projects scaffolded"
}

# Verify all URLs
verify_all_urls() {
    echo "🔗 Verifying all URLs in parallel..."
    grep -r "http[s]*://" --include="*.md" --include="*.txt" | \
        cut -d: -f2- | \
        grep -o 'http[s]*://[^ ]*' | \
        sort -u | \
        parallel -j 20 "curl -s -o /dev/null -w '%{http_code} {}\\n' {}"
    echo "✅ URL verification complete"
}

# Backup all projects
backup_all() {
    local backup_dir="${1:-backups/$(date +%Y%m%d_%H%M%S)}"
    mkdir -p "$backup_dir"
    
    echo "💾 Backing up all projects to $backup_dir..."
    find . -maxdepth 1 -type d -not -name ".*" | while read dir; do
        name=$(basename "$dir")
        tar -czf "$backup_dir/${name}.tar.gz" "$dir" &
    done
    wait
    echo "✅ All backups complete"
}

# Generate all documentation
generate_all_docs() {
    echo "📚 Generating documentation for all projects..."
    
    # Python projects
    find . -name "setup.py" -o -name "pyproject.toml" | while read proj; do
        (
            cd $(dirname "$proj")
            echo "Documenting: $(basename $(pwd))"
            sphinx-build -b html docs docs/_build
        ) &
    done
    
    # JavaScript projects
    find . -name "package.json" | while read pkg; do
        if grep -q "jsdoc" "$pkg"; then
            (
                cd $(dirname "$pkg")
                npm run docs
            ) &
        fi
    done
    
    wait
    echo "✅ All documentation generated"
}

# Security scan all
security_scan_all() {
    echo "🔒 Running security scans..."
    
    # Python
    find . -name "requirements.txt" | while read req; do
        (safety check -r "$req") &
    done
    
    # Node
    find . -name "package.json" -not -path "*/node_modules/*" | while read pkg; do
        (cd $(dirname "$pkg") && npm audit) &
    done
    
    wait
    echo "✅ Security scans complete"
}

# Performance benchmark
benchmark_all() {
    echo "⚡ Running performance benchmarks..."
    find . -name "*bench*.py" -o -name "*perf*.py" | \
        parallel -j 5 "echo Benchmarking: {} && python3 {}"
    echo "✅ Benchmarks complete"
}