# Projects Directory Structure

## Active Projects

### 🎯 Main Projects
- **caia/** - Comprehensive AI Agent framework (MAIN PROJECT)
- **admin/** - Administrative tools and scripts for project management

### 📱 Client Projects  
- **standalone-apps/roulette-community/** - Gaming community platform (separate client project)

### 📚 Reference
- **standalone-apps/omnimind-wiki/** - Historical OmniMind documentation

### 🔧 Utilities
- **.claude/** - Claude configuration files
- **.github-workflows/** - GitHub Actions workflows
- **temp-scripts/** - Temporary scripts (auto-cleaned)

## Project Consolidation

All CAIA-related components have been consolidated into the main CAIA monorepo:
- 20 external repos → 1 unified CAIA monorepo
- Better dependency management via Lerna
- Single source of truth for all components

## Quick Commands

```bash
# Navigate to main project
cd caia

# Check project status  
admin/scripts/quick_status.sh

# View CAIA components
ls caia/packages/
```

---
*Updated after CAIA consolidation - August 2025*
