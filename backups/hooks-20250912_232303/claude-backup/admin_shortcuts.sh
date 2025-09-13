#!/bin/bash

# Admin Shortcuts for Claude Code Sessions
# Add this to your .bashrc or .zshrc: source ~/.claude/admin_shortcuts.sh

# Quick admin command function
# Using 'adm' as the main command instead of % to avoid shell conflicts
adm() {
    if [[ -z "$1" ]]; then
        # No arguments - show menu
        /Users/MAC/Documents/projects/admin/scripts/admin_menu.sh
    else
        # Process shortcuts
        case "$1" in
            help|h)
                adm_help
                ;;
            # Status Commands
            s|status)
                /Users/MAC/Documents/projects/admin/scripts/quick_status.sh
                ;;
            c|caia)
                /Users/MAC/Documents/projects/admin/scripts/caia_status.sh
                ;;
            sum|summary)
                python3 /Users/MAC/Documents/projects/admin/scripts/query_context.py --command summary
                ;;
            
            # Decision Management
            d|decisions)
                python3 /Users/MAC/Documents/projects/admin/scripts/query_context.py --command decisions --days ${2:-7}
                ;;
            l|log)
                # Quick decision log with parameters
                if [[ -n "$2" && -n "$3" && -n "$4" ]]; then
                    python3 /Users/MAC/Documents/projects/admin/scripts/log_decision.py \
                        --type decision --title "$2" --description "$3" --project "$4"
                else
                    echo "Usage: adm l \"title\" \"description\" \"project\""
                fi
                ;;
            p|progress)
                # Quick progress log
                if [[ -n "$2" && -n "$3" && -n "$4" ]]; then
                    python3 /Users/MAC/Documents/projects/admin/scripts/log_decision.py \
                        --type progress --title "$2" --project "$3" --completion "$4"
                else
                    echo "Usage: adm p \"title\" \"project\" completion_percentage"
                fi
                ;;
            disc|discussion)
                if [[ -n "$2" && -n "$3" && -n "$4" ]]; then
                    python3 /Users/MAC/Documents/projects/admin/scripts/log_decision.py \
                        --type discussion --title "$2" --description "$3" --project "$4"
                else
                    echo "Usage: adm disc \"title\" \"description\" \"project\""
                fi
                ;;
            
            # Context Management
            ctx|context)
                python3 /Users/MAC/Documents/projects/admin/scripts/capture_context.py --hours ${2:-1}
                ;;
            daemon)
                ps aux | grep capture_context.py | grep -v grep && echo "✅ Daemon running" || echo "❌ Daemon not running"
                ;;
            daemon-start)
                /Users/MAC/Documents/projects/admin/scripts/start_context_daemon.sh
                ;;
            daemon-stop)
                /Users/MAC/Documents/projects/admin/scripts/stop_context_daemon.sh
                ;;
            daemon-log)
                tail -f /Users/MAC/Documents/projects/admin/logs/context_daemon.log
                ;;
            
            # Monitoring & Quality
            monitor)
                python3 /Users/MAC/Documents/projects/admin/scripts/realtime_monitor.py --watch
                ;;
            scan)
                python3 /Users/MAC/Documents/projects/admin/scripts/realtime_monitor.py --scan
                ;;
            qa)
                python3 /Users/MAC/Documents/projects/admin/scripts/qa_automation.py --all
                ;;
            qa-fix)
                python3 /Users/MAC/Documents/projects/admin/scripts/qa_automation.py --fix
                ;;
            security)
                python3 /Users/MAC/Documents/projects/admin/scripts/qa_automation.py --security
                ;;
            deps)
                python3 /Users/MAC/Documents/projects/admin/scripts/daily_update_check.py --deps-only
                ;;
            
            # CAIA Management
            tracker)
                python3 /Users/MAC/Documents/projects/admin/scripts/caia_tracker.py
                ;;
            roadmap)
                python3 /Users/MAC/Documents/projects/admin/scripts/caia_tracker.py --roadmap
                ;;
            components)
                python3 /Users/MAC/Documents/projects/admin/scripts/caia_tracker.py --report
                ;;
            migrate)
                python3 /Users/MAC/Documents/projects/admin/scripts/monorepo_manager.py --migrate
                ;;
            
            # Updates
            update)
                python3 /Users/MAC/Documents/projects/admin/scripts/daily_update_check.py
                ;;
            news)
                python3 /Users/MAC/Documents/projects/admin/scripts/daily_update_check.py --news-only
                ;;
            self-update)
                python3 /Users/MAC/Documents/projects/admin/scripts/daily_update_check.py --self-update
                ;;
            
            # Performance
            ccu)
                /Users/MAC/Documents/projects/admin/scripts/test_ccu_integration.sh
                ;;
            cco)
                /Users/MAC/Documents/projects/admin/scripts/test_cco_integration.sh
                ;;
            perf)
                python3 /Users/MAC/Documents/projects/admin/scripts/caia_progress_tracker.py status
                ;;
            test-ccu)
                /Users/MAC/Documents/projects/admin/scripts/test_ccu_integration.sh
                ;;
            test-cco)
                /Users/MAC/Documents/projects/admin/scripts/verify_cco.sh
                ;;
            
            # Project Management
            project|proj)
                if [[ -n "$2" ]]; then
                    python3 /Users/MAC/Documents/projects/admin/scripts/query_context.py --command project --project "$2"
                else
                    echo "Usage: adm project <project-name>"
                fi
                ;;
            todos)
                grep -r "TODO\|FIXME\|HACK" /Users/MAC/Documents/projects --include="*.py" --include="*.js" --include="*.ts" | head -20
                ;;
            commits)
                python3 /Users/MAC/Documents/projects/admin/scripts/query_context.py --command commits
                ;;
            branches)
                python3 /Users/MAC/Documents/projects/admin/scripts/query_context.py --command branches
                ;;
            
            # Utilities
            menu)
                /Users/MAC/Documents/projects/admin/scripts/admin_menu.sh
                ;;
            dashboard)
                python3 /Users/MAC/Documents/projects/admin/scripts/admin_dashboard.py
                ;;
            actions)
                python3 /Users/MAC/Documents/projects/admin/scripts/admin_dashboard.py --actions
                ;;
            health)
                python3 /Users/MAC/Documents/projects/admin/scripts/admin_dashboard.py --health
                ;;
            
            # Progress Tracking
            progress-today|pt)
                python3 /Users/MAC/Documents/projects/admin/scripts/progress_logger.py today
                ;;
            progress-week|pw)
                python3 /Users/MAC/Documents/projects/admin/scripts/progress_logger.py week
                ;;
            progress-repo|pr)
                if [[ -n "$2" ]]; then
                    python3 /Users/MAC/Documents/projects/admin/scripts/ecosystem_progress_dashboard.py project --project "$2"
                else
                    echo "Usage: adm progress-repo <repo-name>"
                fi
                ;;
            progress-caia|pc)
                python3 /Users/MAC/Documents/projects/admin/scripts/caia_progress_aggregator.py status
                ;;
            progress-ecosystem|pe)
                python3 /Users/MAC/Documents/projects/admin/scripts/ecosystem_progress_dashboard.py dashboard
                ;;
            log-progress|lp)
                if [[ -n "$2" && -n "$3" ]]; then
                    python3 /Users/MAC/Documents/projects/admin/scripts/progress_logger.py add "$2" "$3" --type "${4:-feature}" --complexity "${5:-medium}" --impact "${6:-medium}"
                else
                    echo "Usage: adm log-progress \"title\" \"description\" [type] [complexity] [impact]"
                fi
                ;;
            progress-trends|trends)
                python3 /Users/MAC/Documents/projects/admin/scripts/ecosystem_progress_dashboard.py weekly
                ;;
            progress-blockers|blockers)
                if [[ -n "$2" && -n "$3" ]]; then
                    python3 /Users/MAC/Documents/projects/admin/scripts/progress_logger.py block "$2" "$3" --plan "${4:-}"
                else
                    echo "Usage: adm progress-blockers \"title\" \"impact\" [plan]"
                fi
                ;;
            progress-milestones|milestones)
                python3 /Users/MAC/Documents/projects/admin/scripts/caia_progress_aggregator.py rollup
                ;;
            
            *)
                echo "Unknown command: $1 (try: adm help)"
                echo "Press TAB after 'adm ' to see all available commands"
                ;;
        esac
    fi
}

# Aliases for even quicker access
alias @='adm'  # Allow @ as shortcut to adm
alias @s='adm status'
alias @c='adm caia'
alias @d='adm decisions'
alias @sum='adm summary'
alias @ctx='adm context'
alias @l='adm log'
alias @p='adm progress'

# Alternative with comma prefix (very quick to type)
alias ,='adm'
alias ,s='adm status'
alias ,c='adm caia'
alias ,d='adm decisions'
alias ,sum='adm summary'
alias ,ctx='adm context'
alias ,l='adm log'
alias ,p='adm progress'

# Auto-completion for % command (for zsh)
if [[ -n "$ZSH_VERSION" ]]; then
    _admin_complete() {
        local -a options
        options=(
            'help:Show help'
            's:Quick status'
            'status:Quick status'
            'c:CAIA status'
            'caia:CAIA status'
            'sum:Executive summary'
            'summary:Executive summary'
            'd:Recent decisions'
            'decisions:Recent decisions'
            'l:Log decision'
            'log:Log decision'
            'p:Log progress'
            'progress:Log progress'
            'ctx:Capture context'
            'context:Capture context'
            'daemon:Check daemon'
        )
        _describe 'admin command' options
    }
    compdef _admin_complete adm 2>/dev/null
fi

# Show reminder on load
# echo "🎯 Admin commands loaded! Type 'adm', '@', or ',' for menu. Quick help: 'adm help'"