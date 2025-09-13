#!/usr/bin/env python3
"""
Migrate existing file logs to unified database
"""
import json
import sys
from pathlib import Path
from datetime import datetime

sys.path.append(str(Path.home() / "Documents/projects/caia/knowledge-system"))
from unified_ai_database import unified_db

def migrate_logs():
    log_dir = Path.home() / "Documents/projects/caia/knowledge-system/logs"
    
    # Migrate JSONL logs
    for log_file in log_dir.glob("*.jsonl"):
        print(f"Migrating {log_file.name}...")
        with open(log_file, 'r') as f:
            for line in f:
                try:
                    entry = json.loads(line)
                    # Convert to database operation
                    unified_db.log_operation(
                        operation_type=entry.get('action_type', 'UNKNOWN'),
                        tool_used=entry.get('tool_used', 'UNKNOWN'),
                        details=entry.get('details', ''),
                        input_data=entry.get('metadata', {})
                    )
                except:
                    continue
    
    print("✅ Migration complete!")

if __name__ == "__main__":
    migrate_logs()
