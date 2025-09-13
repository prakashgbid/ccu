#!/bin/bash
# Monitor parallel processes
watch -n 0.5 "ps aux | grep -E 'git|npm|python|make' | grep -v grep | wc -l | xargs echo 'Active parallel processes:'"
