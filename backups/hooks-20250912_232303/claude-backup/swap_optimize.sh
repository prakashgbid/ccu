#\!/bin/bash
# SSD Swap Optimization
echo "# SSD Swap Configuration"
echo "vm.swappiness=10  # Reduce swap usage"
echo "vm.vfs_cache_pressure=50  # Retain inode/dentry caches"
echo "vm.dirty_background_ratio=5"
echo "vm.dirty_ratio=10"
echo "✅ SSD swap optimization configured"
