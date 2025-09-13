#!/bin/bash

# Parallel Execution Framework
# Execute multiple commands in parallel with monitoring

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
MAX_PARALLEL=${MAX_PARALLEL:-10}
CACHE_DIR=~/.claude/cache
LOG_DIR=~/.claude/logs
PIDS=()

# Setup directories
mkdir -p "$CACHE_DIR" "$LOG_DIR"

# Logging
log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

# Execute command in background with logging
run_parallel() {
    local cmd="$1"
    local name="${2:-task}"
    local log_file="$LOG_DIR/${name}_$(date +%s).log"
    
    log "Starting: $name"
    eval "$cmd" > "$log_file" 2>&1 &
    local pid=$!
    PIDS+=($pid)
    
    # Monitor in background
    (
        if wait $pid; then
            success "$name completed"
        else
            error "$name failed (see $log_file)"
        fi
    ) &
}

# Batch file operations
batch_files() {
    local operation="$1"
    shift
    local files=("$@")
    
    log "Batch $operation on ${#files[@]} files"
    
    for file in "${files[@]}"; do
        case "$operation" in
            read)
                cat "$file" &
                ;;
            edit)
                sed -i.bak 's/old/new/g' "$file" &
                ;;
            delete)
                rm -f "$file" &
                ;;
            *)
                error "Unknown operation: $operation"
                ;;
        esac
    done
    wait
}

# Parallel git operations
git_parallel() {
    local repos=("$@")
    
    for repo in "${repos[@]}"; do
        run_parallel "git -C $repo pull" "git_$repo"
    done
}

# Parallel npm/yarn operations
npm_parallel() {
    local dirs=("$@")
    
    for dir in "${dirs[@]}"; do
        if [ -f "$dir/package.json" ]; then
            run_parallel "cd $dir && npm install" "npm_$dir"
        fi
    done
}

# Parallel Python operations
python_parallel() {
    local scripts=("$@")
    
    for script in "${scripts[@]}"; do
        run_parallel "python3 $script" "py_$(basename $script)"
    done
}

# Parallel testing
test_parallel() {
    local test_files=("$@")
    
    for test in "${test_files[@]}"; do
        run_parallel "pytest $test" "test_$(basename $test)"
    done
}

# Cache operations
cache_get() {
    local key="$1"
    local cache_file="$CACHE_DIR/${key}.cache"
    [ -f "$cache_file" ] && cat "$cache_file"
}

cache_set() {
    local key="$1"
    local value="$2"
    echo "$value" > "$CACHE_DIR/${key}.cache"
}

# Cached command execution
cached_exec() {
    local cmd="$1"
    local cache_key=$(echo "$cmd" | md5sum | cut -d' ' -f1)
    local result=$(cache_get "$cache_key")
    
    if [ -z "$result" ]; then
        result=$(eval "$cmd")
        cache_set "$cache_key" "$result"
        log "Cached: $cmd"
    else
        log "Using cache for: $cmd"
    fi
    
    echo "$result"
}

# Process pool simulation
process_pool() {
    local max_jobs="$1"
    shift
    local commands=("$@")
    
    for cmd in "${commands[@]}"; do
        while [ $(jobs -r | wc -l) -ge $max_jobs ]; do
            sleep 0.1
        done
        eval "$cmd" &
    done
    wait
}

# Stream processing pipeline
pipeline() {
    local input="$1"
    shift
    local pipeline="$@"
    
    local cmd="cat $input"
    for stage in $pipeline; do
        cmd="$cmd | $stage"
    done
    
    eval "$cmd"
}

# Parallel find and process
find_parallel() {
    local pattern="$1"
    local action="$2"
    
    find . -name "$pattern" -print0 | \
        xargs -0 -P $MAX_PARALLEL -I {} sh -c "$action"
}

# Parallel grep across files
grep_parallel() {
    local pattern="$1"
    shift
    local files=("$@")
    
    printf '%s\n' "${files[@]}" | \
        xargs -P $MAX_PARALLEL grep -l "$pattern"
}

# Monitor all background processes
monitor_jobs() {
    log "Monitoring ${#PIDS[@]} background jobs..."
    
    local failed=0
    for pid in "${PIDS[@]}"; do
        if ! wait $pid; then
            ((failed++))
        fi
    done
    
    if [ $failed -eq 0 ]; then
        success "All jobs completed successfully!"
    else
        error "$failed jobs failed"
    fi
}

# Performance timer
time_it() {
    local start=$(date +%s%N)
    "$@"
    local end=$(date +%s%N)
    local duration=$((($end - $start) / 1000000))
    log "Execution time: ${duration}ms"
}

# Main execution
main() {
    case "${1:-help}" in
        batch)
            shift
            batch_files "$@"
            ;;
        git)
            shift
            git_parallel "$@"
            ;;
        npm)
            shift
            npm_parallel "$@"
            ;;
        python)
            shift
            python_parallel "$@"
            ;;
        test)
            shift
            test_parallel "$@"
            ;;
        pool)
            shift
            process_pool "$@"
            ;;
        find)
            shift
            find_parallel "$@"
            ;;
        grep)
            shift
            grep_parallel "$@"
            ;;
        cache)
            shift
            cached_exec "$@"
            ;;
        monitor)
            monitor_jobs
            ;;
        help)
            cat << EOF
Parallel Execution Framework

Usage: $0 <command> [arguments]

Commands:
  batch <op> <files>     Batch file operations
  git <repos>           Parallel git operations
  npm <dirs>            Parallel npm install
  python <scripts>      Parallel Python execution
  test <files>          Parallel test execution
  pool <max> <cmds>     Process pool execution
  find <pattern> <cmd>  Parallel find and process
  grep <pattern> <files> Parallel grep
  cache <command>       Cached command execution
  monitor              Monitor background jobs
  help                 Show this help

Environment Variables:
  MAX_PARALLEL         Maximum parallel jobs (default: 10)
  CACHE_DIR           Cache directory (default: ~/.claude/cache)
  LOG_DIR             Log directory (default: ~/.claude/logs)

Examples:
  $0 batch read file1.txt file2.txt file3.txt
  $0 git repo1 repo2 repo3
  $0 npm project1 project2 project3
  $0 python script1.py script2.py script3.py
  $0 test test_*.py
  $0 pool 5 "cmd1" "cmd2" "cmd3" "cmd4" "cmd5"
  $0 find "*.js" "eslint {}"
  $0 grep "TODO" *.py
  $0 cache "expensive_command"
EOF
            ;;
        *)
            error "Unknown command: $1"
            echo "Run '$0 help' for usage"
            exit 1
            ;;
    esac
}

# Trap to clean up background jobs on exit
trap 'kill $(jobs -p) 2>/dev/null' EXIT

# Run main if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi