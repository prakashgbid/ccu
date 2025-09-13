#\!/bin/bash
# Exclude project directories from Spotlight
PROJECT_DIRS=(
    "$HOME/Documents/projects"
    "$HOME/.claude"
    "/tmp/ramdisk"
    "/Volumes/ULTRARAM"
)

for dir in "${PROJECT_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        touch "$dir/.metadata_never_index"
        echo "Excluded from Spotlight: $dir"
    fi
done
echo "✅ Spotlight disabled for project directories"
