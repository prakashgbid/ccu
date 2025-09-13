# Snapshot file
# Unset all aliases to avoid conflicts with functions
unalias -a 2>/dev/null || true
# Functions
adm () {
	if [[ -z "$1" ]]
	then
		/Users/MAC/Documents/projects/admin/scripts/admin_menu.sh
	else
		case "$1" in
			(help | h) adm_help ;;
			(s | status) /Users/MAC/Documents/projects/admin/scripts/quick_status.sh ;;
			(c | caia) /Users/MAC/Documents/projects/admin/scripts/caia_status.sh ;;
			(sum | summary) python3 /Users/MAC/Documents/projects/admin/scripts/query_context.py --command summary ;;
			(d | decisions) python3 /Users/MAC/Documents/projects/admin/scripts/query_context.py --command decisions --days ${2:-7} ;;
			(l | log) if [[ -n "$2" && -n "$3" && -n "$4" ]]
				then
					python3 /Users/MAC/Documents/projects/admin/scripts/log_decision.py --type decision --title "$2" --description "$3" --project "$4"
				else
					echo "Usage: adm l \"title\" \"description\" \"project\""
				fi ;;
			(p | progress) if [[ -n "$2" && -n "$3" && -n "$4" ]]
				then
					python3 /Users/MAC/Documents/projects/admin/scripts/log_decision.py --type progress --title "$2" --project "$3" --completion "$4"
				else
					echo "Usage: adm p \"title\" \"project\" completion_percentage"
				fi ;;
			(disc | discussion) if [[ -n "$2" && -n "$3" && -n "$4" ]]
				then
					python3 /Users/MAC/Documents/projects/admin/scripts/log_decision.py --type discussion --title "$2" --description "$3" --project "$4"
				else
					echo "Usage: adm disc \"title\" \"description\" \"project\""
				fi ;;
			(ctx | context) python3 /Users/MAC/Documents/projects/admin/scripts/capture_context.py --hours ${2:-1} ;;
			(daemon) ps aux | grep capture_context.py | grep -v grep && echo "✅ Daemon running" || echo "❌ Daemon not running" ;;
			(daemon-start) /Users/MAC/Documents/projects/admin/scripts/start_context_daemon.sh ;;
			(daemon-stop) /Users/MAC/Documents/projects/admin/scripts/stop_context_daemon.sh ;;
			(daemon-log) tail -f /Users/MAC/Documents/projects/admin/logs/context_daemon.log ;;
			(monitor) python3 /Users/MAC/Documents/projects/admin/scripts/realtime_monitor.py --watch ;;
			(scan) python3 /Users/MAC/Documents/projects/admin/scripts/realtime_monitor.py --scan ;;
			(qa) python3 /Users/MAC/Documents/projects/admin/scripts/qa_automation.py --all ;;
			(qa-fix) python3 /Users/MAC/Documents/projects/admin/scripts/qa_automation.py --fix ;;
			(security) python3 /Users/MAC/Documents/projects/admin/scripts/qa_automation.py --security ;;
			(deps) python3 /Users/MAC/Documents/projects/admin/scripts/daily_update_check.py --deps-only ;;
			(tracker) python3 /Users/MAC/Documents/projects/admin/scripts/caia_tracker.py ;;
			(roadmap) python3 /Users/MAC/Documents/projects/admin/scripts/caia_tracker.py --roadmap ;;
			(components) python3 /Users/MAC/Documents/projects/admin/scripts/caia_tracker.py --report ;;
			(migrate) python3 /Users/MAC/Documents/projects/admin/scripts/monorepo_manager.py --migrate ;;
			(update) python3 /Users/MAC/Documents/projects/admin/scripts/daily_update_check.py ;;
			(news) python3 /Users/MAC/Documents/projects/admin/scripts/daily_update_check.py --news-only ;;
			(self-update) python3 /Users/MAC/Documents/projects/admin/scripts/daily_update_check.py --self-update ;;
			(ccu) /Users/MAC/Documents/projects/admin/scripts/test_ccu_integration.sh ;;
			(cco) /Users/MAC/Documents/projects/admin/scripts/test_cco_integration.sh ;;
			(perf) python3 /Users/MAC/Documents/projects/admin/scripts/caia_progress_tracker.py status ;;
			(test-ccu) /Users/MAC/Documents/projects/admin/scripts/test_ccu_integration.sh ;;
			(test-cco) /Users/MAC/Documents/projects/admin/scripts/verify_cco.sh ;;
			(project | proj) if [[ -n "$2" ]]
				then
					python3 /Users/MAC/Documents/projects/admin/scripts/query_context.py --command project --project "$2"
				else
					echo "Usage: adm project <project-name>"
				fi ;;
			(todos) grep -r "TODO\|FIXME\|HACK" /Users/MAC/Documents/projects --include="*.py" --include="*.js" --include="*.ts" | head -20 ;;
			(commits) python3 /Users/MAC/Documents/projects/admin/scripts/query_context.py --command commits ;;
			(branches) python3 /Users/MAC/Documents/projects/admin/scripts/query_context.py --command branches ;;
			(menu) /Users/MAC/Documents/projects/admin/scripts/admin_menu.sh ;;
			(dashboard) python3 /Users/MAC/Documents/projects/admin/scripts/admin_dashboard.py ;;
			(actions) python3 /Users/MAC/Documents/projects/admin/scripts/admin_dashboard.py --actions ;;
			(health) python3 /Users/MAC/Documents/projects/admin/scripts/admin_dashboard.py --health ;;
			(progress-today | pt) python3 /Users/MAC/Documents/projects/admin/scripts/progress_logger.py today ;;
			(progress-week | pw) python3 /Users/MAC/Documents/projects/admin/scripts/progress_logger.py week ;;
			(progress-repo | pr) if [[ -n "$2" ]]
				then
					python3 /Users/MAC/Documents/projects/admin/scripts/ecosystem_progress_dashboard.py project --project "$2"
				else
					echo "Usage: adm progress-repo <repo-name>"
				fi ;;
			(progress-caia | pc) python3 /Users/MAC/Documents/projects/admin/scripts/caia_progress_aggregator.py status ;;
			(progress-ecosystem | pe) python3 /Users/MAC/Documents/projects/admin/scripts/ecosystem_progress_dashboard.py dashboard ;;
			(log-progress | lp) if [[ -n "$2" && -n "$3" ]]
				then
					python3 /Users/MAC/Documents/projects/admin/scripts/progress_logger.py add "$2" "$3" --type "${4:-feature}" --complexity "${5:-medium}" --impact "${6:-medium}"
				else
					echo "Usage: adm log-progress \"title\" \"description\" [type] [complexity] [impact]"
				fi ;;
			(progress-trends | trends) python3 /Users/MAC/Documents/projects/admin/scripts/ecosystem_progress_dashboard.py weekly ;;
			(progress-blockers | blockers) if [[ -n "$2" && -n "$3" ]]
				then
					python3 /Users/MAC/Documents/projects/admin/scripts/progress_logger.py block "$2" "$3" --plan "${4:-}"
				else
					echo "Usage: adm progress-blockers \"title\" \"impact\" [plan]"
				fi ;;
			(progress-milestones | milestones) python3 /Users/MAC/Documents/projects/admin/scripts/caia_progress_aggregator.py rollup ;;
			(*) echo "Unknown command: $1 (try: adm help)"
				echo "Press TAB after 'adm ' to see all available commands" ;;
		esac
	fi
}
cks_before_architecture () {
	local design_intent="$1" 
	echo "🏗️ CKS: Mandatory architecture pattern scan"
	echo "Design: $design_intent"
	if [ -f "$CKS_PATH/cli/knowledge_cli.py" ]
	then
		python3 "$CKS_PATH/cli/knowledge_cli.py" scan-architecture "$design_intent" 2> /dev/null || echo "New architectural pattern"
	else
		echo "Proceeding - CKS CLI not available"
	fi
}
cks_before_code () {
	local task_desc="$1" 
	echo "🔍 CKS: Mandatory redundancy check before code generation"
	echo "Task: $task_desc"
	if [ -f "$CKS_PATH/cli/knowledge_cli.py" ]
	then
		python3 "$CKS_PATH/cli/knowledge_cli.py" check-redundancy "$task_desc" 2> /dev/null || echo "Proceeding with new implementation"
	else
		echo "Proceeding - CKS CLI not available"
	fi
}
cks_before_suggestion () {
	local suggestion_context="$1" 
	echo "🔎 CKS: Mandatory capability search before suggestions"
	echo "Context: $suggestion_context"
	if [ -f "$CKS_PATH/cli/knowledge_cli.py" ]
	then
		python3 "$CKS_PATH/cli/knowledge_cli.py" search-capabilities "$suggestion_context" 2> /dev/null || echo "New capability needed"
	else
		echo "Proceeding - CKS CLI not available"
	fi
}
cks_enforce () {
	local action="$1" 
	local context="$2" 
	local description="$3" 
	if [ -f "/Users/MAC/.claude/cks-enforcer.sh" ]
	then
		"/Users/MAC/.claude/cks-enforcer.sh" "$action" "$context" "$description"
	else
		echo "🔍 CKS: $action check for '$description'"
		echo "Context: $context"
		if [ -d "$CKS_PATH" ]
		then
			echo "✅ CKS validation passed"
		else
			echo "⚠️  CKS path not found"
		fi
	fi
}
cks_load_context () {
	echo "📊 CKS: Loading CAIA project context"
	if [ -f "$CKS_PATH/scripts/validate-system.sh" ]
	then
		"$CKS_PATH/scripts/validate-system.sh" 2> /dev/null || echo "Context loaded"
	fi
}
cks_status () {
	echo "🤖 CKS Integration Status:"
	echo "  Path: $CKS_PATH"
	echo "  Enforcement: $CKS_ENFORCEMENT"
	echo "  Bypass Allowed: $CKS_BYPASS_ALLOWED"
	echo "  Session ID: $CKS_SESSION_ID"
	if [ -d "$CKS_PATH" ]
	then
		echo "  ✅ Knowledge System: Available"
	else
		echo "  ❌ Knowledge System: Not found"
	fi
}
prompt_analyze () {
	python3 "$PROMPT_LOGGER_PATH" analyze
}
prompt_backtrack () {
	local search="${1}" 
	local last="${2:-20}" 
	python3 "$PROMPT_LOGGER_PATH" backtrack --search "$search" --last "$last"
}
prompt_replay () {
	local session="${1}" 
	python3 "$PROMPT_LOGGER_PATH" replay --session "$session"
}
rc-full-dev () {
	echo "🚀 Running full RC development cycle..."
	cd /Users/MAC/Documents/projects/roulette-community
	for step in {1..11}
	do
		echo "Running step $step..."
		claude-workflow development --project /Users/MAC/Documents/projects/roulette-community --step $step
		if [ $? -ne 0 ]
		then
			echo "❌ Step $step failed. Stopping."
			return 1
		fi
	done
	echo "✅ Full development cycle complete!"
	git log --oneline -10
}
workflow-commit () {
	git add -A
	git commit -m "workflow: $1

Automated workflow commit
🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>"
}
workflow-status () {
	echo "📊 Workflow Status for $(pwd)"
	echo "="*60
	echo "Git Status:"
	git status -s
	echo ""
	echo "Recent Commits:"
	git log --oneline -5
	echo ""
	echo "Available Workflows:"
	claude-workflow
}
workflow-step () {
	local workflow=${1:-development} 
	local step=${2:-1} 
	local project=${3:-$(pwd)} 
	claude-workflow $workflow --project $project --step $step
}
# Shell Options
setopt nohashdirs
setopt login
# Aliases
alias -- ,=adm
alias -- ,c='adm caia'
alias -- ,ctx='adm context'
alias -- ,d='adm decisions'
alias -- ,l='adm log'
alias -- ,p='adm progress'
alias -- ,s='adm status'
alias -- ,sum='adm summary'
alias -- @=adm
alias -- @c='adm caia'
alias -- @ctx='adm context'
alias -- @d='adm decisions'
alias -- @l='adm log'
alias -- @p='adm progress'
alias -- @s='adm status'
alias -- @sum='adm summary'
alias -- ccl='python3 "$ENHANCED_LOGGER_PATH" log'
alias -- ccmon='python3 "$HOME/.claude/cc_attribution_monitor.py"'
alias -- ccsum='python3 "$ENHANCED_LOGGER_PATH" summary'
alias -- db_operations='echo "SELECT COUNT(*) as total, tool_used FROM operations GROUP BY tool_used;" | sqlite3 $UNIFIED_DB_PATH'
alias -- db_query='sqlite3 $UNIFIED_DB_PATH'
alias -- db_stats='echo "SELECT name FROM sqlite_master WHERE type=\"table\";" | sqlite3 $UNIFIED_DB_PATH'
alias -- deploy='claude-workflow deploy'
alias -- deploy-prod='claude-workflow deploy --project $(pwd)'
alias -- dev-here='claude-workflow development --project $(pwd)'
alias -- dev-here-interactive='claude-workflow development --project $(pwd) --interactive'
alias -- dev-step='claude-workflow development --step'
alias -- dev-workflow='claude-workflow development'
alias -- dev-workflow-interactive='claude-workflow development --interactive'
alias -- panalyze=prompt_analyze
alias -- pback=prompt_backtrack
alias -- plast='prompt_backtrack "" 5'
alias -- preplay=prompt_replay
alias -- qa='claude-workflow test --project $(pwd)'
alias -- rc-dev='claude-workflow development --project /Users/MAC/Documents/projects/roulette-community'
alias -- rc-dev-interactive='claude-workflow development --project /Users/MAC/Documents/projects/roulette-community --interactive'
alias -- run-help=man
alias -- test-workflow='claude-workflow test'
alias -- which-command=whence
alias -- workflows=claude-workflow
# Check for rg availability
if ! command -v rg >/dev/null 2>&1; then
  alias rg='/opt/homebrew/lib/node_modules/\@anthropic-ai/claude-code/vendor/ripgrep/arm64-darwin/rg'
fi
export PATH=/Users/MAC/Documents/projects/caia/bin\:/Users/MAC/bin\:/Users/MAC/.claude/bin\:/opt/homebrew/bin\:/opt/homebrew/sbin\:/usr/local/bin\:/System/Cryptexes/App/usr/bin\:/usr/bin\:/bin\:/usr/sbin\:/sbin\:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin\:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin\:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin
