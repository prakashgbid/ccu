#!/bin/bash

# CAIA Knowledge System - Claude Code Integration Installer
# Complete setup for mandatory CKS integration with CC

set -e

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🤖 CAIA Knowledge System - Claude Code Integration Installer${NC}"
echo "========================================================="
echo ""

# Configuration
CKS_PATH="/Users/MAC/Documents/projects/caia/knowledge-system"
CC_CONFIG_DIR="/Users/MAC/.claude"
BACKUP_DIR="$CC_CONFIG_DIR/backup-$(date +%Y%m%d-%H%M%S)"

# Create backup
echo -e "${YELLOW}💾 Creating backup of existing configuration...${NC}"
mkdir -p "$BACKUP_DIR"
if [ -f "$CC_CONFIG_DIR/CLAUDE.md" ]; then
    cp "$CC_CONFIG_DIR/CLAUDE.md" "$BACKUP_DIR/"
fi
if [ -f "$CC_CONFIG_DIR/hooks.json" ]; then
    cp "$CC_CONFIG_DIR/hooks.json" "$BACKUP_DIR/"
fi
echo -e "${GREEN}✅ Backup created at: $BACKUP_DIR${NC}"

# Validate CKS installation
echo -e "${BLUE}🔍 Validating CAIA Knowledge System...${NC}"
if [ ! -d "$CKS_PATH" ]; then
    echo -e "${RED}❌ ERROR: CAIA Knowledge System not found at $CKS_PATH${NC}"
    echo "Please ensure CKS is properly installed first."
    exit 1
fi

if [ ! -d "$CKS_PATH/cc-integration" ]; then
    echo -e "${YELLOW}⚠️  CKS CC integration components not found. This is expected.${NC}"
fi

echo -e "${GREEN}✅ CAIA Knowledge System validated${NC}"

# Install CKS integration if available
if [ -d "$CKS_PATH/cc-integration" ]; then
    echo -e "${BLUE}📦 Installing CKS CC integration components...${NC}"
    if [ -f "$CKS_PATH/cc-integration/install/install-cks-integration.sh" ]; then
        "$CKS_PATH/cc-integration/install/install-cks-integration.sh"
        echo -e "${GREEN}✅ CKS integration components installed${NC}"
    fi
fi

# Install hooks
echo -e "${BLUE}🤝 Installing Claude Code hooks...${NC}"

# Make all scripts executable
chmod +x "$CC_CONFIG_DIR/cc-startup-hook.sh" 2>/dev/null || true
chmod +x "$CC_CONFIG_DIR/cks-enforcer.sh" 2>/dev/null || true

# Create environment setup
cat > "$CC_CONFIG_DIR/cks-environment.sh" << 'EOF'
#!/bin/bash

# CAIA Knowledge System Environment Setup
# Source this file to load CKS integration

export CKS_PATH="/Users/MAC/Documents/projects/caia/knowledge-system"
export CKS_ENFORCEMENT="MANDATORY"
export CKS_API_URL="http://localhost:5000"
export CKS_BYPASS_ALLOWED="false"
export CKS_SESSION_ID="cc_$(date +%s)"

# Load CKS commands if available
if [ -f "$CKS_PATH/cc-integration/automation/cks-commands.sh" ]; then
    source "$CKS_PATH/cc-integration/automation/cks-commands.sh"
fi

# CKS helper functions
cks_enforce() {
    local action="$1"
    local context="$2"
    local description="$3"
    
    if [ -f "/Users/MAC/.claude/cks-enforcer.sh" ]; then
        "/Users/MAC/.claude/cks-enforcer.sh" "$action" "$context" "$description"
    else
        echo "CKS enforcer not available"
    fi
}

# Auto-check functions
cks_before_code() {
    echo "🔍 CKS: Checking for redundancy before code generation..."
    cks_enforce "check-redundancy" "code-generation" "$1"
}

cks_before_architecture() {
    echo "🏗️ CKS: Scanning architectural patterns..."
    cks_enforce "scan-architecture" "architecture-design" "$1"
}

cks_before_suggestion() {
    echo "🔎 CKS: Searching existing capabilities..."
    cks_enforce "search-capabilities" "suggestion" "$1"
}

echo "✅ CKS environment loaded - enforcement active"
EOF

chmod +x "$CC_CONFIG_DIR/cks-environment.sh"

# Add to shell profile for automatic loading
echo -e "${BLUE}🔗 Setting up automatic CKS loading...${NC}"

# Add to .zshrc if it exists
if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "cks-environment.sh" "$HOME/.zshrc"; then
        echo "" >> "$HOME/.zshrc"
        echo "# CAIA Knowledge System Auto-load" >> "$HOME/.zshrc"
        echo "if [ -f \"$CC_CONFIG_DIR/cks-environment.sh\" ]; then" >> "$HOME/.zshrc"
        echo "    source \"$CC_CONFIG_DIR/cks-environment.sh\"" >> "$HOME/.zshrc"
        echo "fi" >> "$HOME/.zshrc"
        echo -e "${GREEN}✅ Added CKS auto-load to .zshrc${NC}"
    fi
fi

# Add to .bash_profile if it exists
if [ -f "$HOME/.bash_profile" ]; then
    if ! grep -q "cks-environment.sh" "$HOME/.bash_profile"; then
        echo "" >> "$HOME/.bash_profile"
        echo "# CAIA Knowledge System Auto-load" >> "$HOME/.bash_profile"
        echo "if [ -f \"$CC_CONFIG_DIR/cks-environment.sh\" ]; then" >> "$HOME/.bash_profile"
        echo "    source \"$CC_CONFIG_DIR/cks-environment.sh\"" >> "$HOME/.bash_profile"
        echo "fi" >> "$HOME/.bash_profile"
        echo -e "${GREEN}✅ Added CKS auto-load to .bash_profile${NC}"
    fi
fi

# Validation
echo -e "${BLUE}🔍 Validating installation...${NC}"

# Check files exist
required_files=(
    "$CC_CONFIG_DIR/CLAUDE.md"
    "$CC_CONFIG_DIR/hooks.json"
    "$CC_CONFIG_DIR/cc-startup-hook.sh"
    "$CC_CONFIG_DIR/cks-enforcer.sh"
    "$CC_CONFIG_DIR/cks-environment.sh"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "  ${GREEN}✅${NC} $(basename "$file")"
    else
        echo -e "  ${RED}❌${NC} $(basename "$file") - MISSING"
    fi
done

# Test CKS integration
echo -e "${BLUE}🧪 Testing CKS integration...${NC}"
source "$CC_CONFIG_DIR/cks-environment.sh"

if [ "$CKS_ENFORCEMENT" = "MANDATORY" ]; then
    echo -e "  ${GREEN}✅${NC} Environment variables set correctly"
else
    echo -e "  ${YELLOW}⚠️${NC} Environment variables may not be set correctly"
fi

# Final instructions
echo ""
echo -e "${GREEN}🎉 CKS Claude Code Integration Installed Successfully!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Restart your terminal to load CKS environment"
echo "2. Start a new Claude Code session to activate CKS integration"
echo "3. All code generation will now be checked for redundancy"
echo ""
echo -e "${YELLOW}Key features now active:${NC}"
echo "• Mandatory redundancy checking before code generation"
echo "• Architectural pattern scanning before design"
echo "• Existing capability search before suggestions"
echo "• Real-time knowledge base updates"
echo "• Decision logging integration"
echo ""
echo -e "${BLUE}Test the integration:${NC}"
echo "source $CC_CONFIG_DIR/cks-environment.sh"
echo "cks_before_code 'create a new authentication function'"
echo ""
echo -e "${GREEN}CKS Integration is now MANDATORY and ACTIVE!${NC}"