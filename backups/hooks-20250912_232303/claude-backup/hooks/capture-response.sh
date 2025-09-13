#!/bin/bash
# Capture CC responses for training
if [ -n "$1" ]; then
    echo "$1" > /tmp/last_cc_response.txt
    echo "[$(date)] Captured response" >> /tmp/cks_capture.log
fi
