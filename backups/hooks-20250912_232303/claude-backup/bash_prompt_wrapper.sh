#!/bin/bash
#
# Bash Prompt Wrapper with Logging
# Logs all prompts and user choices for pattern learning
#

PROMPT_LOGGER="$HOME/.claude/prompt_choice_logger.py"

# Override common prompt commands to log them
prompt_with_logging() {
    local prompt_type="$1"
    local prompt_text="$2"
    shift 2
    local options=("$@")
    
    # Log the prompt
    local prompt_id=$(python3 "$PROMPT_LOGGER" prompt \
        --type "$prompt_type" \
        --text "$prompt_text" \
        --options "${options[@]}" 2>/dev/null | grep "Prompt ID:" | cut -d: -f2 | tr -d ' ')
    
    # Store prompt ID for choice logging
    export LAST_PROMPT_ID="$prompt_id"
    
    echo "$prompt_text"
    if [ ${#options[@]} -gt 0 ]; then
        echo "Options:"
        local i=1
        for opt in "${options[@]}"; do
            echo "  $i) $opt"
            ((i++))
        done
    fi
}

# Wrapper for 'read' command with logging
read_with_logging() {
    local var_name="$1"
    local prompt_text="${2:-Enter value: }"
    
    # Log the prompt
    local prompt_id=$(python3 "$PROMPT_LOGGER" prompt \
        --type "input" \
        --text "$prompt_text" 2>/dev/null | grep "Prompt ID:" | cut -d: -f2 | tr -d ' ')
    
    # Original read
    builtin read -p "$prompt_text" "$var_name"
    
    # Log the choice
    local choice="${!var_name}"
    python3 "$PROMPT_LOGGER" choice \
        --prompt-id "$prompt_id" \
        --choice "$choice" 2>/dev/null
    
    export LAST_PROMPT_ID="$prompt_id"
    export LAST_CHOICE="$choice"
}

# Wrapper for 'select' command with logging
select_with_logging() {
    local var_name="$1"
    local prompt_text="$2"
    shift 2
    local options=("$@")
    
    # Log the prompt
    local prompt_id=$(python3 "$PROMPT_LOGGER" prompt \
        --type "select" \
        --text "$prompt_text" \
        --options "${options[@]}" 2>/dev/null | grep "Prompt ID:" | cut -d: -f2 | tr -d ' ')
    
    echo "$prompt_text"
    PS3="Select option: "
    select choice in "${options[@]}"; do
        if [ -n "$choice" ]; then
            # Log the choice
            python3 "$PROMPT_LOGGER" choice \
                --prompt-id "$prompt_id" \
                --choice "$choice" 2>/dev/null
            
            eval "$var_name='$choice'"
            export LAST_PROMPT_ID="$prompt_id"
            export LAST_CHOICE="$choice"
            break
        fi
    done
}

# Enhanced yes/no prompt with logging
confirm_with_logging() {
    local prompt_text="${1:-Continue?}"
    local default="${2:-n}"
    
    # Log the prompt
    local prompt_id=$(python3 "$PROMPT_LOGGER" prompt \
        --type "confirm" \
        --text "$prompt_text [y/n]" \
        --options "yes" "no" 2>/dev/null | grep "Prompt ID:" | cut -d: -f2 | tr -d ' ')
    
    local choice
    builtin read -p "$prompt_text [y/n] (default: $default): " choice
    choice="${choice:-$default}"
    
    # Log the choice
    python3 "$PROMPT_LOGGER" choice \
        --prompt-id "$prompt_id" \
        --choice "$choice" 2>/dev/null
    
    export LAST_PROMPT_ID="$prompt_id"
    export LAST_CHOICE="$choice"
    
    [[ "$choice" =~ ^[Yy] ]]
}

# Function to log CC's prompts to users
cc_prompt_log() {
    local prompt_type="$1"
    local prompt_text="$2"
    shift 2
    local options=("$@")
    
    python3 "$PROMPT_LOGGER" prompt \
        --type "$prompt_type" \
        --text "$prompt_text" \
        --options "${options[@]}" 2>/dev/null
}

# Function to log user's choice
cc_choice_log() {
    local prompt_id="${1:-$LAST_PROMPT_ID}"
    local choice="$2"
    local reasoning="$3"
    
    python3 "$PROMPT_LOGGER" choice \
        --prompt-id "$prompt_id" \
        --choice "$choice" \
        --reasoning "$reasoning" 2>/dev/null
}

# Backtrack function
prompt_backtrack() {
    local search="${1}"
    local last="${2:-20}"
    
    python3 "$PROMPT_LOGGER" backtrack \
        --search "$search" \
        --last "$last"
}

# Analyze patterns
prompt_analyze() {
    python3 "$PROMPT_LOGGER" analyze
}

# Replay session
prompt_replay() {
    local session="${1}"
    python3 "$PROMPT_LOGGER" replay --session "$session"
}

# Export functions for use (only in bash, not zsh)
if [ -n "$BASH_VERSION" ]; then
    export -f prompt_with_logging 2>/dev/null
    export -f read_with_logging 2>/dev/null
    export -f select_with_logging 2>/dev/null
    export -f confirm_with_logging 2>/dev/null
    export -f cc_prompt_log 2>/dev/null
    export -f cc_choice_log 2>/dev/null
    export -f prompt_backtrack 2>/dev/null
    export -f prompt_analyze 2>/dev/null
    export -f prompt_replay 2>/dev/null
fi

# Aliases for common operations
alias pread='read_with_logging'
alias pselect='select_with_logging'
alias pconfirm='confirm_with_logging'
alias pback='prompt_backtrack'
alias panalyze='prompt_analyze'
alias preplay='prompt_replay'

# Silently activated - no message needed