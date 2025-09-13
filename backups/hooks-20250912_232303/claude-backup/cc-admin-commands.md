# Claude Code Admin Commands Reference

## How to Use in CC Prompt

When you're in a Claude Code session, simply type these commands and I'll execute them for you:

### Quick Commands (Type these in CC prompt)

#### 📊 Status & Monitoring
- `%status` or `%s` - Quick project overview
- `%caia` or `%c` - CAIA-specific status  
- `%summary` or `%sum` - Executive summary of all projects
- `%monitor` - Start real-time monitoring
- `%scan` - One-time security/quality scan

#### 📝 Decision & Progress Management
- `%decisions` or `%d` - View recent decisions (last 7 days)
- `%log` or `%l` - Log a decision
- `%progress` or `%p` - Log progress update
- `%discussion` or `%disc` - Document team discussion

#### 🔄 Context Management
- `%context` or `%ctx` - Capture context snapshot
- `%daemon` - Check daemon status
- `%daemon-start` - Start hourly captures
- `%daemon-stop` - Stop automatic captures
- `%daemon-log` - View daemon logs

#### ✅ Quality & Security
- `%qa` - Run quality checks on all projects
- `%qa-fix` - Auto-fix linting and format issues
- `%security` - Security vulnerability scan
- `%deps` - Check for outdated dependencies

#### 🎯 CAIA Management
- `%tracker` - CAIA component tracking
- `%roadmap` - View development roadmap
- `%components` - List all components and status
- `%migrate` - Migrate project to monorepo

#### 🔄 Updates & News
- `%update` - Check and apply updates
- `%news` - Tech news and trending repos
- `%self-update` - Update admin system

#### ⚡ Performance
- `%ccu` - CC Ultimate status
- `%cco` - CC Orchestrator status
- `%perf` - Performance metrics
- `%test-ccu` - Test CCU integration
- `%test-cco` - Test CCO integration

#### 📁 Project Management
- `%project [name]` - Get project summary
- `%todos` - List all TODOs
- `%commits` - Recent git commits
- `%branches` - Active branches

#### 🛠️ Utilities
- `%menu` - Interactive command menu
- `%dashboard` - Full admin dashboard
- `%health` - System health check
- `%actions` - Available quick actions
- `%help` - Show this help

## Command Examples in CC

Just type these in your Claude Code prompt:

```
%s
```
Shows quick status

```
%log "Switched to TypeScript" "Better type safety" caia
```
Logs a decision

```
%progress "Auth module complete" roulette-community 100
```
Records progress

```
%decisions 7
```
Shows last week's decisions

```
%project caia
```
Gets CAIA project summary

## Special Features in CC

When you type a command starting with `%`, I will:
1. Recognize it as an admin command
2. Execute the appropriate script
3. Show you the results
4. Optionally log the action if significant

## Auto-Suggest in CC

When you type `%` and pause, I'll show you available commands with descriptions.

## Important Notes

- These commands work ONLY within Claude Code sessions
- They don't affect your system terminal
- All commands are executed through me (Claude)
- Results are displayed in the CC interface
- Commands are context-aware based on your current project

---

*These shortcuts make admin tasks instant within Claude Code without leaving your coding flow.*