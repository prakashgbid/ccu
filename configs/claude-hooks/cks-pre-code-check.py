#!/usr/bin/env python3
"""
CKS Pre-Code Check Hook
Automatically checks CKS before CC writes any code
"""

import json
import sys
import requests
import hashlib
from pathlib import Path

def check_cks_for_similar(task_description):
    """Check if similar code exists in CKS."""
    
    endpoints = [
        'http://localhost:5002/api/cks/search',
        'http://localhost:5001/api/cks/search',
        'http://localhost:5000/search'
    ]
    
    for endpoint in endpoints:
        try:
            response = requests.post(
                endpoint,
                json={'query': task_description, 'threshold': 0.7},
                timeout=2
            )
            if response.status_code == 200:
                return response.json()
        except:
            continue
    
    return None

def main():
    # Read the command/task from stdin
    task = sys.stdin.read().strip()
    
    # Keywords that trigger CKS check
    code_keywords = [
        'implement', 'create', 'write', 'build', 'add',
        'function', 'class', 'component', 'api', 'endpoint',
        'feature', 'module', 'service', 'utility', 'helper'
    ]
    
    # Check if this is a code-writing task
    if any(keyword in task.lower() for keyword in code_keywords):
        print(f"🔍 Checking CKS for existing implementations...")
        
        results = check_cks_for_similar(task)
        
        if results and results.get('similar_found'):
            print("⚠️  CKS ALERT: Similar code already exists!")
            print("📍 Found in:", results.get('locations', []))
            print("💡 Suggestion: Consider reusing or extending existing code")
            print("-" * 50)
            
            # Return non-zero to pause CC
            return 1
    
    return 0

if __name__ == "__main__":
    sys.exit(main())