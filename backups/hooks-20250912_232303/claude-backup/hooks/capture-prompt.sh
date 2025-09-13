#!/bin/bash
# Capture user prompts for training
if [ -n "$1" ]; then
    echo "$1" > /tmp/last_user_prompt.txt
    echo "[$(date)] Captured prompt" >> /tmp/cks_capture.log
fi
