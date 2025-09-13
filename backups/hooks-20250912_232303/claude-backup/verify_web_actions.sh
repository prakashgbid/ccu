#!/bin/bash

# Automated Web Action Verification Script
# This script automatically verifies web actions without manual intervention

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
GITHUB_USER="prakashgbid"
MAX_RETRIES=3
RETRY_DELAY=10

# Log function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

# Success function
success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Error function
error() {
    echo -e "${RED}❌ $1${NC}"
}

# Warning function
warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Verify GitHub Repository
verify_github_repo() {
    local repo=$1
    local url="https://github.com/${GITHUB_USER}/${repo}"
    
    log "Verifying GitHub repository: $url"
    
    for i in $(seq 1 $MAX_RETRIES); do
        response=$(curl -s -o /dev/null -w "%{http_code}" "$url")
        if [ "$response" = "200" ]; then
            success "GitHub repository verified: $url"
            return 0
        fi
        warning "Attempt $i/$MAX_RETRIES failed (HTTP $response)"
        [ $i -lt $MAX_RETRIES ] && sleep $RETRY_DELAY
    done
    
    error "GitHub repository verification failed: $url"
    return 1
}

# Verify GitHub Wiki
verify_github_wiki() {
    local repo=$1
    local url="https://github.com/${GITHUB_USER}/${repo}/wiki"
    
    log "Verifying GitHub wiki: $url"
    
    for i in $(seq 1 $MAX_RETRIES); do
        response=$(curl -s -o /dev/null -w "%{http_code}" "$url")
        if [ "$response" = "200" ]; then
            success "GitHub wiki verified: $url"
            return 0
        fi
        warning "Attempt $i/$MAX_RETRIES failed (HTTP $response)"
        [ $i -lt $MAX_RETRIES ] && sleep $RETRY_DELAY
    done
    
    error "GitHub wiki verification failed: $url"
    return 1
}

# Verify GitHub Pages
verify_github_pages() {
    local repo=$1
    local url="https://${GITHUB_USER}.github.io/${repo}/"
    
    log "Verifying GitHub Pages: $url"
    
    # GitHub Pages can take longer to deploy
    local pages_retries=6
    local pages_delay=30
    
    for i in $(seq 1 $pages_retries); do
        response=$(curl -s -o /dev/null -w "%{http_code}" "$url")
        if [ "$response" = "200" ]; then
            success "GitHub Pages verified: $url"
            return 0
        fi
        warning "Attempt $i/$pages_retries failed (HTTP $response) - Pages may still be building"
        [ $i -lt $pages_retries ] && sleep $pages_delay
    done
    
    warning "GitHub Pages not yet available: $url (may still be building)"
    return 1
}

# Verify PyPI Package
verify_pypi_package() {
    local package=$1
    local url="https://pypi.org/project/${package}/"
    local json_url="https://pypi.org/pypi/${package}/json"
    
    log "Verifying PyPI package: $package"
    
    for i in $(seq 1 $MAX_RETRIES); do
        response=$(curl -s -o /dev/null -w "%{http_code}" "$json_url")
        if [ "$response" = "200" ]; then
            success "PyPI package verified: $url"
            return 0
        fi
        warning "Attempt $i/$MAX_RETRIES failed (HTTP $response)"
        [ $i -lt $MAX_RETRIES ] && sleep $RETRY_DELAY
    done
    
    error "PyPI package verification failed: $url"
    return 1
}

# Verify npm Package
verify_npm_package() {
    local package=$1
    local url="https://www.npmjs.com/package/${package}"
    local registry_url="https://registry.npmjs.org/${package}"
    
    log "Verifying npm package: $package"
    
    for i in $(seq 1 $MAX_RETRIES); do
        response=$(curl -s -o /dev/null -w "%{http_code}" "$registry_url")
        if [ "$response" = "200" ]; then
            success "npm package verified: $url"
            return 0
        fi
        warning "Attempt $i/$MAX_RETRIES failed (HTTP $response)"
        [ $i -lt $MAX_RETRIES ] && sleep $RETRY_DELAY
    done
    
    error "npm package verification failed: $url"
    return 1
}

# Verify Generic URL
verify_url() {
    local url=$1
    local description="${2:-URL}"
    
    log "Verifying $description: $url"
    
    for i in $(seq 1 $MAX_RETRIES); do
        response=$(curl -s -o /dev/null -w "%{http_code}" "$url")
        if [ "$response" = "200" ] || [ "$response" = "301" ] || [ "$response" = "302" ]; then
            success "$description verified: $url (HTTP $response)"
            return 0
        fi
        warning "Attempt $i/$MAX_RETRIES failed (HTTP $response)"
        [ $i -lt $MAX_RETRIES ] && sleep $RETRY_DELAY
    done
    
    error "$description verification failed: $url"
    return 1
}

# Batch verify multiple items
batch_verify() {
    local action=$1
    shift
    local items=("$@")
    local failed=0
    
    echo ""
    log "Starting batch verification for: $action"
    echo ""
    
    for item in "${items[@]}"; do
        case "$action" in
            "github")
                verify_github_repo "$item" || ((failed++))
                ;;
            "wiki")
                verify_github_wiki "$item" || ((failed++))
                ;;
            "pages")
                verify_github_pages "$item" || ((failed++))
                ;;
            "pypi")
                verify_pypi_package "$item" || ((failed++))
                ;;
            "npm")
                verify_npm_package "$item" || ((failed++))
                ;;
            *)
                error "Unknown action: $action"
                ((failed++))
                ;;
        esac
        echo ""
    done
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if [ $failed -eq 0 ]; then
        success "All verifications passed!"
    else
        warning "$failed verification(s) failed or pending"
    fi
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    return $failed
}

# Generate verification report
generate_report() {
    local output_file="${1:-verification_report.md}"
    local timestamp=$(date +'%Y-%m-%d %H:%M:%S')
    
    cat > "$output_file" << EOF
# Web Action Verification Report

Generated: $timestamp

## Verification Results

| Type | URL | Status | Timestamp |
|------|-----|--------|-----------|
EOF
    
    log "Report generated: $output_file"
}

# Main function for CLI usage
main() {
    case "${1:-help}" in
        github)
            shift
            verify_github_repo "$@"
            ;;
        wiki)
            shift
            verify_github_wiki "$@"
            ;;
        pages)
            shift
            verify_github_pages "$@"
            ;;
        pypi)
            shift
            verify_pypi_package "$@"
            ;;
        npm)
            shift
            verify_npm_package "$@"
            ;;
        url)
            shift
            verify_url "$@"
            ;;
        batch)
            shift
            batch_verify "$@"
            ;;
        report)
            shift
            generate_report "$@"
            ;;
        help|--help|-h)
            cat << EOF
Web Action Verification Script

Usage: $0 <command> [arguments]

Commands:
  github <repo>           Verify GitHub repository
  wiki <repo>            Verify GitHub wiki
  pages <repo>           Verify GitHub Pages site
  pypi <package>         Verify PyPI package
  npm <package>          Verify npm package
  url <url> [desc]       Verify generic URL
  batch <type> <items>   Batch verify multiple items
  report [file]          Generate verification report
  help                   Show this help message

Examples:
  $0 github evolux-ai
  $0 wiki cognitron-engine
  $0 pages codeforge-ai
  $0 pypi evolux
  $0 npm @myorg/package
  $0 url https://example.com "API Endpoint"
  $0 batch github evolux-ai cognitron-engine codeforge-ai
  $0 report verification.md

Environment Variables:
  GITHUB_USER    GitHub username (default: prakashgbid)
  MAX_RETRIES    Maximum retry attempts (default: 3)
  RETRY_DELAY    Delay between retries in seconds (default: 10)
EOF
            ;;
        *)
            error "Unknown command: $1"
            echo "Run '$0 help' for usage information"
            exit 1
            ;;
    esac
}

# Run main function if script is executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi