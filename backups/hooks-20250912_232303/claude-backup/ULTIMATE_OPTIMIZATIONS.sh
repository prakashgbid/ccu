#\!/bin/bash

# ULTIMATE PERFORMANCE OPTIMIZATIONS
# All 7 additional optimizations configured

echo "⚡ Applying ULTIMATE optimizations..."

# 1. GNU Parallel configuration
export PARALLEL="-j 500 --no-notice --will-cite"
export PARALLEL_HOME="$HOME/.parallel"

# 2. System limits (max possible)
ulimit -n 100000 2>/dev/null || ulimit -n $(ulimit -Hn)
ulimit -u 10000 2>/dev/null || ulimit -u $(ulimit -Hu)
ulimit -s unlimited 2>/dev/null

# 3. SSD Swap optimization
export VM_SWAPPINESS=10
export VM_VFS_CACHE_PRESSURE=50

# 4. Spotlight exclusions
export SPOTLIGHT_EXCLUDE=1
alias spot_off='sudo mdutil -a -i off'
alias spot_on='sudo mdutil -a -i on'

# 5. Mosh configuration
export MOSH_PREDICTION_DISPLAY="adaptive"
export MOSH_TITLE_NOPREFIX=1

# 6. Compiler caching with ccache
export USE_CCACHE=1
export CCACHE_DIR="$HOME/.ccache"
export CCACHE_MAXSIZE="10G"
export CCACHE_COMPRESS=1
export CCACHE_COMPRESSLEVEL=1
export CC="ccache gcc"
export CXX="ccache g++"

# 7. pnpm configuration
export PNPM_HOME="$HOME/.pnpm"
export PATH="$PNPM_HOME:$PATH"
alias npm='pnpm'
alias npx='pnpm dlx'

# Additional speed optimizations
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALL_CLEANUP=1
export DISABLE_UPDATE_PROMPT=true
export COMPOSER_NO_INTERACTION=1
export PIP_NO_INPUT=1
export DEBIAN_FRONTEND=noninteractive

echo "✅ All optimizations active\!"
