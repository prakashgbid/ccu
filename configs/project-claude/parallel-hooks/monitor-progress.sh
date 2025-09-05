#!/bin/bash
# Real-time Progress Monitoring Dashboard for Parallel Hook Implementation

SHARED_PATH="/Users/MAC/Documents/projects/.claude/parallel-hooks/shared"
PROGRESS_FILE="$SHARED_PATH/state/progress.json"
EVENTS_FILE="$SHARED_PATH/events/hook-events.jsonl"

# Colors for dashboard
RED='\033[0;31m'
GREEN='\033[0;32m' 
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD='\033[1m'
NC='\033[0m'

clear_screen() {
    clear
    echo -e "${BOLD}${CYAN}🚀 PARALLEL HOOK IMPLEMENTATION DASHBOARD${NC}"
    echo -e "${CYAN}════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${BOLD}📊 Real-time Status of 8 CC Instances Building Comprehensive Hook System${NC}"
    echo ""
}

display_progress() {
    echo -e "${BOLD}🎯 Instance Progress & Status:${NC}"
    echo ""
    
    # Status color mapping
    declare -A STATUS_COLORS=(
        ["launching"]="${YELLOW}🔄"
        ["active"]="${GREEN}⚡"
        ["completed"]="${GREEN}✅"
        ["error"]="${RED}❌"
        ["idle"]="${BLUE}💤"
        ["integrating"]="${CYAN}🔗"
    )
    
    # Instance definitions with colors
    declare -A INSTANCE_COLORS=(
        ["cc1-cognitive"]="${RED}"
        ["cc2-cks"]="${GREEN}"
        ["cc3-quality"]="${YELLOW}"
        ["cc4-project"]="${BLUE}"
        ["cc5-health"]="${PURPLE}"
        ["cc6-enhancement"]="${CYAN}"
        ["cc7-professional"]="${WHITE}"
        ["cc8-coordination"]="${BOLD}${YELLOW}"
    )
    
    instances=("cc1-cognitive" "cc2-cks" "cc3-quality" "cc4-project" "cc5-health" "cc6-enhancement" "cc7-professional" "cc8-coordination")
    
    for instance in "${instances[@]}"; do
        instance_color="${INSTANCE_COLORS[$instance]}"
        
        # Read actual progress if file exists
        if [ -f "$PROGRESS_FILE" ]; then
            progress=$(jq -r ".instances.\"$instance\".progress_percentage // 0" "$PROGRESS_FILE" 2>/dev/null)
            status=$(jq -r ".instances.\"$instance\".status // \"launching\"" "$PROGRESS_FILE" 2>/dev/null)
            current_task=$(jq -r ".instances.\"$instance\".current_task // \"initializing...\"" "$PROGRESS_FILE" 2>/dev/null)
            completed_hooks=$(jq -r ".instances.\"$instance\".hooks_completed | length" "$PROGRESS_FILE" 2>/dev/null)
        else
            progress=0
            status="launching"  
            current_task="initializing..."
            completed_hooks=0
        fi
        
        status_icon="${STATUS_COLORS[$status]}"
        
        # Create progress bar
        progress_bar=""
        filled=$((progress / 10))
        
        for ((i=0; i<10; i++)); do
            if [ $i -lt $filled ]; then
                progress_bar="${progress_bar}█"
            else
                progress_bar="${progress_bar}░"
            fi
        done
        
        echo -e "${status_icon}${NC} ${instance_color}${instance}${NC}: [${GREEN}${progress_bar}${NC}] ${progress}% (${completed_hooks}/8 hooks)"
        echo -e "   ${CYAN}→${NC} ${current_task}"
        echo ""
    done
}

display_overall_stats() {
    if [ -f "$PROGRESS_FILE" ]; then
        overall_progress=$(jq -r ".overall_progress.percentage // 0" "$PROGRESS_FILE" 2>/dev/null)
        completed_hooks=$(jq -r ".overall_progress.hooks_completed // 0" "$PROGRESS_FILE" 2>/dev/null)
        estimated_hours=$(jq -r ".overall_progress.estimated_completion_hours // 10" "$PROGRESS_FILE" 2>/dev/null)
        current_phase=$(jq -r ".overall_progress.current_phase // \"initialization\"" "$PROGRESS_FILE" 2>/dev/null)
    else
        overall_progress=0
        completed_hooks=0
        estimated_hours=10
        current_phase="initialization"
    fi
    
    echo -e "${BOLD}📈 Overall Progress:${NC}"
    echo -e "   ${GREEN}Progress: ${overall_progress}%${NC} | ${BLUE}Hooks: ${completed_hooks}/64${NC} | ${YELLOW}Phase: ${current_phase}${NC}"
    echo -e "   ${PURPLE}⏱️  Estimated Completion: ${estimated_hours} hours${NC}"
    echo ""
}

display_recent_events() {
    echo -e "${BOLD}📋 Recent Hook Development Events:${NC}"
    echo ""
    
    if [ -f "$EVENTS_FILE" ]; then
        tail -5 "$EVENTS_FILE" 2>/dev/null | while read -r line; do
            if [ -n "$line" ]; then
                timestamp=$(echo "$line" | jq -r '.timestamp' 2>/dev/null | cut -c12-19 || echo "unknown")
                instance=$(echo "$line" | jq -r '.instance' 2>/dev/null || echo "unknown") 
                event=$(echo "$line" | jq -r '.event' 2>/dev/null || echo "unknown")
                category=$(echo "$line" | jq -r '.category' 2>/dev/null || echo "unknown")
                
                echo -e "${CYAN}[$timestamp]${NC} ${PURPLE}$instance${NC} → ${YELLOW}$category${NC}: $event"
            fi
        done
    else
        echo -e "${YELLOW}   No events logged yet... Instances initializing...${NC}"
    fi
    
    echo ""
}

display_commands() {
    echo -e "${BOLD}💻 Commands:${NC}"
    echo -e "   ${GREEN}q${NC} - Quit monitor    ${GREEN}r${NC} - Force refresh    ${GREEN}l${NC} - View logs"  
    echo -e "   ${GREEN}e${NC} - View events     ${GREEN}c${NC} - Coordinate     ${GREEN}s${NC} - System status"
    echo ""
}

# Main monitoring loop
while true; do
    clear_screen
    display_overall_stats
    display_progress
    display_recent_events  
    display_commands
    
    echo -e "${BOLD}${GREEN}🔄 Auto-refreshing every 5 seconds... (Press key for manual control)${NC}"
    
    read -t 5 -n 1 input
    case $input in
        q|Q) 
            echo -e "\n${YELLOW}Exiting parallel hook monitor...${NC}"
            exit 0
            ;;
        r|R)
            echo -e "\n${BLUE}Force refreshing...${NC}"
            continue
            ;;
        l|L)
            echo -e "\n${BLUE}Viewing logs...${NC}"
            echo "Available log files:"
            ls -la "$SHARED_PATH/logs/" 2>/dev/null || echo "No logs yet"
            read -p "Press enter to continue..."
            ;;
        e|E)
            echo -e "\n${BLUE}Recent events:${NC}"
            if [ -f "$EVENTS_FILE" ]; then
                tail -20 "$EVENTS_FILE" | jq -r '"\(.timestamp | split("T")[1] | split(".")[0]) [\(.instance)] \(.category): \(.event)"' 2>/dev/null || cat "$EVENTS_FILE"
            fi
            read -p "Press enter to continue..."
            ;;
        c|C)
            echo -e "\n${BLUE}Coordination interface would open here...${NC}"
            read -p "Press enter to continue..."
            ;;
        s|S)
            echo -e "\n${BLUE}System Status:${NC}"
            echo "CKS Health: $(curl -s http://localhost:5555/health | jq -r '.status' 2>/dev/null || echo 'unavailable')"
            echo "CLS Health: $(curl -s http://localhost:5003/health | jq -r '.service' 2>/dev/null || echo 'unavailable')"
            echo "Active CC Instances: $(ps aux | grep -c 'claude.*hook-' || echo '0')"
            read -p "Press enter to continue..."
            ;;
    esac
done