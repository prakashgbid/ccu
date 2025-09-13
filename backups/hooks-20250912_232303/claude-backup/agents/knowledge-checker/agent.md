# Knowledge Checker Agent

A specialized agent that checks CKS before any code generation to prevent duplicates and suggest reuse.

## Configuration

```yaml
name: knowledge-checker
description: Checks CKS for existing code before generation
auto_invoke: true
priority: high
tools:
  - Bash
  - Read
  - Grep
```

## Triggers

This agent automatically activates when:
- User asks to "create", "implement", "build" something
- Before any Write or MultiEdit operation
- When generating new components or functions

## Actions

1. **Check for Duplicates**: Searches CKS for similar code
2. **Suggest Reuse**: Points to existing implementations
3. **Prevent Redundancy**: Warns before creating duplicates
4. **Learn Patterns**: Updates knowledge base with new code

## Usage

The agent runs automatically via hooks. No manual invocation needed.

## Implementation

See `/Users/MAC/.claude/agents/knowledge-checker/index.js`