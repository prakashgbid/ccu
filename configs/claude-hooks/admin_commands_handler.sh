#!/bin/bash

# Claude Code Admin Commands Handler
# This hook intercepts % prefix to show admin commands

# Check if the input starts with %
if [[ "$1" == "%"* ]]; then
    # Extract command after %
    cmd="${1:1}"
    
    case "$cmd" in
        "") 
            # Just % - show the menu
            /Users/MAC/Documents/projects/admin/scripts/admin_menu.sh
            ;;
        "help")
            # %help - show quick help
            echo "🎯 Admin Commands Quick Reference:"
            echo "  % or %menu    → Show full admin menu"
            echo "  %status       → Quick project status"
            echo "  %caia         → CAIA status"
            echo "  %summary      → Executive summary"
            echo "  %decisions    → Recent decisions"
            echo "  %log          → Log a decision"
            echo "  %progress     → Log progress"
            echo "  %context      → Capture context now"
            echo "  %daemon       → Check daemon status"
            ;;
        "menu")
            /Users/MAC/Documents/projects/admin/scripts/admin_menu.sh
            ;;
        "status"|"s")
            /Users/MAC/Documents/projects/admin/scripts/quick_status.sh
            ;;
        "caia"|"c")
            /Users/MAC/Documents/projects/admin/scripts/caia_status.sh
            ;;
        "summary"|"sum")
            python3 /Users/MAC/Documents/projects/admin/scripts/query_context.py --command summary
            ;;
        "decisions"|"d")
            python3 /Users/MAC/Documents/projects/admin/scripts/query_context.py --command decisions --days 7
            ;;
        "log"|"l")
            echo "Quick Decision Log (for full options use %menu)"
            echo -n "Title: "
            read title
            echo -n "Description: "
            read desc
            echo -n "Project: "
            read proj
            python3 /Users/MAC/Documents/projects/admin/scripts/log_decision.py \
                --type decision --title "$title" --description "$desc" --project "$proj"
            ;;
        "progress"|"p")
            echo "Quick Progress Log"
            echo -n "Title: "
            read title
            echo -n "Project: "
            read proj
            echo -n "Completion %: "
            read comp
            python3 /Users/MAC/Documents/projects/admin/scripts/log_decision.py \
                --type progress --title "$title" --project "$proj" --completion $comp
            ;;
        "context"|"ctx")
            python3 /Users/MAC/Documents/projects/admin/scripts/capture_context.py --hours 1
            ;;
        "daemon")
            ps aux | grep capture_context.py | grep -v grep && echo "✅ Daemon running" || echo "❌ Daemon not running"
            ;;
        *)
            echo "Unknown admin command: %$cmd"
            echo "Type %help for available commands"
            ;;
    esac
    
    # Return 0 to indicate we handled this
    exit 0
fi

# Not an admin command, let it pass through
exit 1