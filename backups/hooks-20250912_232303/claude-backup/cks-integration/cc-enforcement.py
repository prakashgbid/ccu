#!/usr/bin/env python3
"""
CC Enforcement Mechanism
Forces Claude Code to check CKS before any code generation
"""

import os
import sys
import json
import sqlite3
import logging
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional, Tuple
import hashlib

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/Users/MAC/.claude/cks-integration/logs/enforcement.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class CKSEnforcer:
    """Enforce CKS usage in CC operations."""
    
    def __init__(self):
        self.cks_db = '/Users/MAC/Documents/projects/caia/knowledge-system/data/caia_knowledge.db'
        self.enforcement_db = '/Users/MAC/.claude/cks-integration/enforcement.db'
        self.init_enforcement_db()
        
        # Enforcement rules
        self.rules = {
            'block_duplicates': True,
            'require_cks_check': True,
            'validate_imports': True,
            'enforce_patterns': True,
            'log_violations': True
        }
        
        # Track violations
        self.session_violations = []
    
    def init_enforcement_db(self):
        """Initialize enforcement tracking database."""
        conn = sqlite3.connect(self.enforcement_db)
        cursor = conn.cursor()
        
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS enforcement_log (
                id INTEGER PRIMARY KEY,
                timestamp TIMESTAMP,
                action TEXT,
                target TEXT,
                cks_checked BOOLEAN,
                violation_type TEXT,
                blocked BOOLEAN,
                details TEXT
            )
        ''')
        
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS violations (
                id INTEGER PRIMARY KEY,
                timestamp TIMESTAMP,
                type TEXT,
                severity TEXT,
                message TEXT,
                file_context TEXT,
                resolved BOOLEAN DEFAULT 0
            )
        ''')
        
        conn.commit()
        conn.close()
    
    def check_cks_before_code(self, intent: str, context: Dict) -> Tuple[bool, List[Dict]]:
        """Check CKS before allowing code generation."""
        logger.info(f"Enforcing CKS check for: {intent[:100]}...")
        
        violations = []
        allow_proceed = True
        
        # 1. Check for existing implementations
        existing = self.find_existing_implementation(intent)
        if existing:
            violations.append({
                'type': 'duplicate_implementation',
                'severity': 'high',
                'message': f"Similar implementation exists: {existing['file']}:{existing['line']}",
                'suggestion': 'Use existing implementation or extend it'
            })
            
            if self.rules['block_duplicates']:
                allow_proceed = False
        
        # 2. Verify CKS was consulted
        if not context.get('cks_checked', False):
            violations.append({
                'type': 'no_cks_consultation',
                'severity': 'critical',
                'message': 'CKS was not consulted before code generation',
                'suggestion': 'Must check CKS for existing code first'
            })
            
            if self.rules['require_cks_check']:
                allow_proceed = False
        
        # Log enforcement action
        self.log_enforcement(intent, context, violations, not allow_proceed)
        
        return allow_proceed, violations
    
    def find_existing_implementation(self, query: str) -> Optional[Dict]:
        """Find existing implementation in CKS."""
        try:
            conn = sqlite3.connect(self.cks_db)
            cursor = conn.cursor()
            
            # Search for similar functions
            cursor.execute('''
                SELECT f.name, f.signature, fi.path, f.line_start
                FROM functions f
                JOIN files fi ON f.file_id = fi.id
                WHERE f.name LIKE ? OR f.docstring LIKE ?
                LIMIT 1
            ''', (f'%{query.split()[0]}%', f'%{query}%'))
            
            row = cursor.fetchone()
            conn.close()
            
            if row:
                return {
                    'name': row[0],
                    'signature': row[1],
                    'file': row[2],
                    'line': row[3]
                }
        
        except Exception as e:
            logger.error(f"Error searching CKS: {e}")
        
        return None
    
    def validate_imports(self, imports: List[str]) -> List[Dict]:
        """Validate import statements against CKS."""
        violations = []
        
        try:
            conn = sqlite3.connect(self.cks_db)
            cursor = conn.cursor()
            
            for import_path in imports:
                # Check if module exists in codebase
                cursor.execute('''
                    SELECT COUNT(*) FROM files
                    WHERE path LIKE ?
                ''', (f'%{import_path.replace(".", "/")}%',))
                
                count = cursor.fetchone()[0]
                
                if count == 0:
                    violations.append({
                        'type': 'invalid_import',
                        'severity': 'high',
                        'message': f"Import '{import_path}' not found in codebase",
                        'suggestion': 'Check import path or create the module first'
                    })
            
            conn.close()
        
        except Exception as e:
            logger.error(f"Error validating imports: {e}")
        
        return violations
    
    def enforce_patterns(self, code: str) -> List[Dict]:
        """Enforce coding patterns from CKS."""
        violations = []
        
        # Check for common anti-patterns
        anti_patterns = [
            ('eval(', 'Using eval() is forbidden'),
            ('exec(', 'Using exec() is forbidden'),
            ('password =', 'Hardcoded passwords forbidden'),
            ('api_key =', 'Hardcoded API keys forbidden')
        ]
        
        for pattern, message in anti_patterns:
            if pattern in code:
                violations.append({
                    'type': 'anti_pattern',
                    'severity': 'critical',
                    'message': message,
                    'suggestion': 'Remove forbidden pattern'
                })
        
        return violations
    
    def log_enforcement(self, action: str, context: Dict, violations: List[Dict], blocked: bool):
        """Log enforcement action."""
        try:
            conn = sqlite3.connect(self.enforcement_db)
            cursor = conn.cursor()
            
            cursor.execute('''
                INSERT INTO enforcement_log 
                (timestamp, action, target, cks_checked, violation_type, blocked, details)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            ''', (
                datetime.now(),
                action[:100],
                context.get('file', 'unknown'),
                context.get('cks_checked', False),
                violations[0]['type'] if violations else None,
                blocked,
                json.dumps(violations)
            ))
            
            # Log individual violations
            for violation in violations:
                cursor.execute('''
                    INSERT INTO violations
                    (timestamp, type, severity, message, file_context)
                    VALUES (?, ?, ?, ?, ?)
                ''', (
                    datetime.now(),
                    violation['type'],
                    violation['severity'],
                    violation['message'],
                    context.get('file', 'unknown')
                ))
            
            conn.commit()
            conn.close()
            
        except Exception as e:
            logger.error(f"Error logging enforcement: {e}")
    
    def get_enforcement_stats(self) -> Dict:
        """Get enforcement statistics."""
        try:
            conn = sqlite3.connect(self.enforcement_db)
            cursor = conn.cursor()
            
            stats = {}
            
            # Total enforcements
            cursor.execute('SELECT COUNT(*) FROM enforcement_log')
            stats['total_enforcements'] = cursor.fetchone()[0]
            
            # Blocked actions
            cursor.execute('SELECT COUNT(*) FROM enforcement_log WHERE blocked = 1')
            stats['blocked_actions'] = cursor.fetchone()[0]
            
            # Violations by type
            cursor.execute('''
                SELECT type, COUNT(*) 
                FROM violations 
                GROUP BY type
            ''')
            stats['violations_by_type'] = dict(cursor.fetchall())
            
            # Recent violations
            cursor.execute('''
                SELECT timestamp, type, message
                FROM violations
                ORDER BY timestamp DESC
                LIMIT 5
            ''')
            stats['recent_violations'] = [
                {'time': row[0], 'type': row[1], 'message': row[2]}
                for row in cursor.fetchall()
            ]
            
            conn.close()
            return stats
            
        except Exception as e:
            logger.error(f"Error getting stats: {e}")
            return {}
    
    def enforce_pre_commit(self, files_changed: List[str]) -> Tuple[bool, List[Dict]]:
        """Enforce CKS validation before commit."""
        logger.info(f"Pre-commit enforcement for {len(files_changed)} files")
        
        all_violations = []
        
        for file_path in files_changed:
            # Check if file is in CKS
            if not self.is_file_indexed(file_path):
                all_violations.append({
                    'file': file_path,
                    'type': 'not_indexed',
                    'message': 'File not indexed in CKS',
                    'suggestion': 'Run CKS indexer before committing'
                })
        
        allow_commit = len(all_violations) == 0
        
        return allow_commit, all_violations
    
    def is_file_indexed(self, file_path: str) -> bool:
        """Check if file is indexed in CKS."""
        try:
            conn = sqlite3.connect(self.cks_db)
            cursor = conn.cursor()
            
            cursor.execute('SELECT COUNT(*) FROM files WHERE path = ?', (file_path,))
            count = cursor.fetchone()[0]
            
            conn.close()
            return count > 0
            
        except:
            return False


# Enforcement wrapper for CC
def enforce_cks_check(func):
    """Decorator to enforce CKS checking."""
    def wrapper(*args, **kwargs):
        enforcer = CKSEnforcer()
        
        # Extract intent from arguments
        intent = str(args[0]) if args else str(kwargs)
        
        # Check CKS
        context = {'cks_checked': False, 'function': func.__name__}
        allow, violations = enforcer.check_cks_before_code(intent, context)
        
        if not allow:
            logger.warning(f"BLOCKED: {violations}")
            print("\n⚠️ CKS ENFORCEMENT BLOCKED THIS ACTION")
            for v in violations:
                print(f"  ❌ {v['message']}")
                print(f"     💡 {v['suggestion']}")
            return None
        
        # Proceed with original function
        return func(*args, **kwargs)
    
    return wrapper


def main():
    """CLI for enforcement management."""
    enforcer = CKSEnforcer()
    
    if len(sys.argv) > 1:
        command = sys.argv[1]
        
        if command == 'stats':
            stats = enforcer.get_enforcement_stats()
            print(json.dumps(stats, indent=2))
        
        elif command == 'check' and len(sys.argv) > 2:
            query = ' '.join(sys.argv[2:])
            existing = enforcer.find_existing_implementation(query)
            if existing:
                print(f"✅ Found existing: {existing}")
            else:
                print("❌ No existing implementation found")
        
        elif command == 'enable':
            print("CKS Enforcement ENABLED")
            Path('/Users/MAC/.claude/cks-integration/.enforcement_enabled').touch()
        
        elif command == 'disable':
            print("CKS Enforcement DISABLED")
            Path('/Users/MAC/.claude/cks-integration/.enforcement_enabled').unlink(missing_ok=True)
        
        else:
            print("Usage: cc-enforcement.py [stats|check <query>|enable|disable]")
    
    else:
        # Show current status
        enabled = Path('/Users/MAC/.claude/cks-integration/.enforcement_enabled').exists()
        print(f"CKS Enforcement: {'ENABLED ✅' if enabled else 'DISABLED ❌'}")
        
        stats = enforcer.get_enforcement_stats()
        print(f"Total enforcements: {stats.get('total_enforcements', 0)}")
        print(f"Blocked actions: {stats.get('blocked_actions', 0)}")


if __name__ == "__main__":
    main()