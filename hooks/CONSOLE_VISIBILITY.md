# Hook Console Visibility System

All Claude Code hooks now display their name and action on the console when triggered, providing real-time visibility into what's happening.

## Console Output Format

Each hook displays a box with:
- 🪝 **HOOK**: The hook's name
- 📋 **ACTION**: What the hook is doing
- Additional context-specific information

## Active Hooks with Console Output

### 1. Session Start Hook
```
╔════════════════════════════════════════════════════════════╗
║ 🪝 HOOK: session-start.sh                                  ║
║ 📋 ACTION: Initializing Claude Code session                ║
╚════════════════════════════════════════════════════════════╝
```
**When**: CC session starts
**Shows**: Service initialization status

### 2. Pre-Tool Use Hook
```
┌──────────────────────────────────────────┐
│ 🪝 HOOK: pre-tool-use                    │
│ 🔧 TOOL: Write                           │
│ ⏰ TIME: 2025-01-13 14:45:00             │
└──────────────────────────────────────────┘
```
**When**: Before any tool executes
**Shows**: Tool name and timestamp

### 3. Post-Tool Use Hook
```
┌──────────────────────────────────────────┐
│ 🪝 HOOK: post-tool-use                   │
│ 🔧 TOOL: Write                           │
│ ✅ STATUS: SUCCESS (exit: 0)             │
└──────────────────────────────────────────┘
```
**When**: After tool execution
**Shows**: Tool name and success/failure status

### 4. User Prompt Submit Hook
```
╭──────────────────────────────────────────╮
│ 🪝 HOOK: user-prompt-submit              │
│ 💬 PROMPT: test it again...              │
│ 📝 ACTION: Capturing & enhancing         │
╰──────────────────────────────────────────╯
```
**When**: User submits a prompt
**Shows**: Prompt preview

### 5. Auto-Commit Hook
```
┌──────────────────────────────────────────┐
│ 🪝 HOOK: auto-commit-hook                │
│ 🔧 TOOL: Write                           │
│ 🔄 ACTION: Checking for uncommitted code │
└──────────────────────────────────────────┘
  📦 Auto-committing in: project-name
```
**When**: After Write/Edit/MultiEdit operations
**Shows**: Tool and projects being committed

### 6. Task Completion Commit Hook
```
╔══════════════════════════════════════════╗
║ 🪝 HOOK: task-completion-commit          ║
║ ✅ TRIGGER: Task marked complete         ║
║ 🔄 ACTION: Auto-committing changes       ║
╚══════════════════════════════════════════╝
```
**When**: TodoWrite marks tasks as complete
**Shows**: Task completion trigger

## Box Styles

Different hooks use different box styles for visual distinction:

- **Double-line box** `╔═╗`: Important system hooks (session-start, task-completion)
- **Single-line box** `┌─┐`: Regular operation hooks (pre/post-tool)
- **Rounded box** `╭─╮`: User-facing hooks (user-prompt)

## Icons Used

- 🪝 Hook indicator
- 🔧 Tool operation
- 📋 Action description
- ✅ Success status
- ❌ Failure status
- 🔄 Processing/checking
- 📦 Project/package
- 💬 User interaction
- ⏰ Timestamp
- ⚡ Fast operation

## Implementation

All hooks follow this pattern:

```bash
# Console output for visibility
echo "┌──────────────────────────────────────────┐" >&2
echo "│ 🪝 HOOK: hook-name                       │" >&2
echo "│ 📋 ACTION: What this hook does          │" >&2
echo "└──────────────────────────────────────────┘" >&2
```

Key points:
- Output to stderr (`>&2`) for console visibility
- Fixed-width formatting for alignment
- Concise but informative messages

## Benefits

1. **Transparency**: See exactly what's happening
2. **Debugging**: Easier to troubleshoot issues
3. **Confidence**: Know hooks are working
4. **Learning**: Understand the flow of operations
5. **Monitoring**: Track automated actions

## Creating New Hooks

Use `/Users/MAC/.config/claude/hooks/HOOK_TEMPLATE.sh` as a starting point. It includes:
- Pre-configured console output
- Multiple style options
- Logging setup
- Error handling
- Common patterns

## Testing Visibility

To test hook visibility:
```bash
# Trigger a write operation
echo "test" > /tmp/test.txt

# Watch for hook output in console
# You should see boxes showing each hook's execution
```

## Configuration

Hooks can be made quieter or more verbose by adjusting:
- Log level in individual hooks
- Console output verbosity
- Background vs foreground execution

## Future Enhancements

- Color coding for different hook types
- Progress bars for long operations  
- Sound notifications for important events
- Web dashboard for hook monitoring
- Metrics collection and reporting