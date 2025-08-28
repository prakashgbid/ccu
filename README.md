# Claude Code Ultimate (CCU)

Optimized configurations and hooks for maximum Claude Code performance.

## Features

### 🧠 Automatic CKS Integration
CAIA Knowledge System automatically starts with every CC session:
- Health check on startup
- Auto-launch if not running
- Fallback to minimal API
- Context loading for knowledge reuse

### ⚡ Performance Optimizations
- 50+ parallel workers configured
- RAM disk for temp files
- Optimized tool batching
- Background process management

### 📊 Session Intelligence
- Real-time project status
- Active process monitoring
- Decision tracking integration
- Context awareness

## Installation

```bash
# Clone the repository
git clone https://github.com/prakashgbid/ccu.git ~/.claude/ccu

# Link the session hook
ln -sf ~/.claude/ccu/configs/hooks/caia-session-startup.sh ~/.claude/hooks/session-startup.sh
```

## CKS Auto-Startup

The session hook automatically:
1. Checks if CKS is running on port 5000
2. Starts CKS if not running
3. Waits for successful startup
4. Falls back to minimal API if needed

### Manual CKS Control

```bash
# Check CKS status
curl http://localhost:5000/health

# Start CKS manually
/Users/MAC/Documents/projects/caia/knowledge-system/scripts/start_cks_simple.sh

# Stop CKS
lsof -ti:5000 | xargs kill -9
```

## Configuration Files

- `configs/hooks/caia-session-startup.sh` - Main session startup hook
- More configurations coming soon...

## Contributing

This repository tracks optimizations and configurations for Claude Code. Submit PRs with performance improvements, useful hooks, or configuration enhancements.

## License

MIT