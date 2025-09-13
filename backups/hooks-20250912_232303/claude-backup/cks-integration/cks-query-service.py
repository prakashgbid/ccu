#!/usr/bin/env python3
"""
CKS Query Service
Fast, efficient queries to CKS with caching and optimization
"""

import os
import sys
import json
import sqlite3
import hashlib
import pickle
import time
import threading
from pathlib import Path
from typing import Dict, List, Any, Optional, Set
from datetime import datetime, timedelta
from collections import defaultdict
import requests
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/Users/MAC/.claude/cks-integration/logs/query-service.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class CKSQueryService:
    """High-performance CKS query service."""
    
    def __init__(self):
        self.cache_dir = Path('/Users/MAC/.claude/cks-integration/cache')
        self.cache_dir.mkdir(exist_ok=True)
        
        # Initialize cache database
        self.cache_db = self.cache_dir / 'query_cache.db'
        self.init_cache_db()
        
        # API endpoints
        self.endpoints = [
            'http://localhost:5002/api/cks',
            'http://localhost:5001/api/cks',  
            'http://localhost:5000'
        ]
        
        # In-memory cache for hot data
        self.memory_cache = {}
        self.cache_hits = 0
        self.cache_misses = 0
        
        # Preload common patterns
        self.preload_patterns()
        
        # Start background cache cleanup
        self.start_cache_cleanup()
    
    def init_cache_db(self):
        """Initialize cache database."""
        conn = sqlite3.connect(str(self.cache_db))
        cursor = conn.cursor()
        
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS query_cache (
                query_hash TEXT PRIMARY KEY,
                query_text TEXT,
                result TEXT,
                created_at TIMESTAMP,
                access_count INTEGER DEFAULT 1,
                last_accessed TIMESTAMP
            )
        ''')
        
        cursor.execute('''
            CREATE INDEX IF NOT EXISTS idx_created_at ON query_cache(created_at)
        ''')
        
        cursor.execute('''
            CREATE INDEX IF NOT EXISTS idx_access_count ON query_cache(access_count)
        ''')
        
        conn.commit()
        conn.close()
    
    def preload_patterns(self):
        """Preload commonly used patterns."""
        common_queries = [
            {'type': 'patterns', 'context': 'general'},
            {'type': 'conventions', 'subtype': 'naming'},
            {'type': 'stats'},
            {'type': 'recent_changes', 'minutes': 60}
        ]
        
        for query in common_queries:
            self.query('preload', query)
        
        logger.info(f"Preloaded {len(common_queries)} common patterns")
    
    def start_cache_cleanup(self):
        """Start background thread for cache cleanup."""
        def cleanup():
            while True:
                time.sleep(3600)  # Run every hour
                self.cleanup_cache()
        
        thread = threading.Thread(target=cleanup, daemon=True)
        thread.start()
    
    def cleanup_cache(self):
        """Clean up old cache entries."""
        try:
            conn = sqlite3.connect(str(self.cache_db))
            cursor = conn.cursor()
            
            # Remove entries older than 24 hours with low access count
            cutoff = datetime.now() - timedelta(hours=24)
            cursor.execute('''
                DELETE FROM query_cache 
                WHERE created_at < ? AND access_count < 3
            ''', (cutoff,))
            
            # Keep only top 1000 most accessed entries
            cursor.execute('''
                DELETE FROM query_cache
                WHERE query_hash NOT IN (
                    SELECT query_hash FROM query_cache
                    ORDER BY access_count DESC, last_accessed DESC
                    LIMIT 1000
                )
            ''')
            
            conn.commit()
            conn.close()
            
            # Clear old memory cache
            self.memory_cache = {k: v for k, v in self.memory_cache.items() 
                               if v.get('timestamp', 0) > time.time() - 300}
            
            logger.info("Cache cleanup completed")
            
        except Exception as e:
            logger.error(f"Cache cleanup error: {e}")
    
    def get_cache_key(self, endpoint: str, data: Dict) -> str:
        """Generate cache key."""
        key_data = f"{endpoint}:{json.dumps(data, sort_keys=True)}"
        return hashlib.md5(key_data.encode()).hexdigest()
    
    def get_from_cache(self, cache_key: str) -> Optional[Dict]:
        """Get from cache."""
        # Check memory cache first
        if cache_key in self.memory_cache:
            if self.memory_cache[cache_key]['timestamp'] > time.time() - 300:  # 5 min TTL
                self.cache_hits += 1
                return self.memory_cache[cache_key]['data']
        
        # Check database cache
        try:
            conn = sqlite3.connect(str(self.cache_db))
            cursor = conn.cursor()
            
            cursor.execute('''
                SELECT result, created_at FROM query_cache
                WHERE query_hash = ?
            ''', (cache_key,))
            
            row = cursor.fetchone()
            
            if row:
                result_json, created_at = row
                created_time = datetime.fromisoformat(created_at)
                
                # Check if cache is still valid (1 hour TTL)
                if datetime.now() - created_time < timedelta(hours=1):
                    # Update access count
                    cursor.execute('''
                        UPDATE query_cache 
                        SET access_count = access_count + 1,
                            last_accessed = ?
                        WHERE query_hash = ?
                    ''', (datetime.now(), cache_key))
                    
                    conn.commit()
                    conn.close()
                    
                    result = json.loads(result_json)
                    
                    # Add to memory cache
                    self.memory_cache[cache_key] = {
                        'data': result,
                        'timestamp': time.time()
                    }
                    
                    self.cache_hits += 1
                    return result
            
            conn.close()
            
        except Exception as e:
            logger.error(f"Cache read error: {e}")
        
        self.cache_misses += 1
        return None
    
    def save_to_cache(self, cache_key: str, query_text: str, result: Dict):
        """Save to cache."""
        # Save to memory cache
        self.memory_cache[cache_key] = {
            'data': result,
            'timestamp': time.time()
        }
        
        # Save to database
        try:
            conn = sqlite3.connect(str(self.cache_db))
            cursor = conn.cursor()
            
            cursor.execute('''
                INSERT OR REPLACE INTO query_cache 
                (query_hash, query_text, result, created_at, last_accessed)
                VALUES (?, ?, ?, ?, ?)
            ''', (cache_key, query_text, json.dumps(result), 
                 datetime.now(), datetime.now()))
            
            conn.commit()
            conn.close()
            
        except Exception as e:
            logger.error(f"Cache write error: {e}")
    
    def query(self, endpoint: str, data: Dict, use_cache: bool = True) -> Optional[Dict]:
        """Execute CKS query with caching."""
        cache_key = self.get_cache_key(endpoint, data)
        
        # Check cache
        if use_cache:
            cached = self.get_from_cache(cache_key)
            if cached:
                return cached
        
        # Query CKS
        for base_endpoint in self.endpoints:
            try:
                url = f"{base_endpoint}/{endpoint}" if not endpoint.startswith('/') else f"{base_endpoint}{endpoint}"
                response = requests.post(url, json=data, timeout=3)
                
                if response.status_code == 200:
                    result = response.json()
                    
                    # Save to cache
                    self.save_to_cache(cache_key, f"{endpoint}:{data}", result)
                    
                    return result
                    
            except Exception as e:
                continue
        
        return None
    
    def search_code(self, query: str, search_type: str = 'semantic', limit: int = 10) -> List[Dict]:
        """Search for code in CKS."""
        result = self.query('search', {
            'query': query,
            'type': search_type,
            'limit': limit,
            'include_context': True
        })
        
        if result and 'results' in result:
            return result['results']
        return []
    
    def find_similar_functions(self, function_name: str, threshold: float = 0.7) -> List[Dict]:
        """Find similar functions."""
        result = self.query('similar_functions', {
            'name': function_name,
            'threshold': threshold,
            'include_signature': True
        })
        
        if result and 'functions' in result:
            return result['functions']
        return []
    
    def get_file_dependencies(self, file_path: str) -> Dict[str, List]:
        """Get dependencies for a file."""
        result = self.query('file_dependencies', {
            'file': file_path,
            'depth': 2,
            'include_external': True
        })
        
        if result:
            return result
        return {'imports': [], 'exports': [], 'dependencies': []}
    
    def check_pattern_compliance(self, code: str, pattern_type: str = 'all') -> Dict:
        """Check if code complies with patterns."""
        result = self.query('check_patterns', {
            'code': code,
            'pattern_type': pattern_type,
            'return_violations': True
        })
        
        if result:
            return result
        return {'compliant': True, 'violations': []}
    
    def get_code_context(self, file_path: str, line_number: int, context_lines: int = 10) -> Dict:
        """Get context around a specific line."""
        result = self.query('code_context', {
            'file': file_path,
            'line': line_number,
            'context_lines': context_lines,
            'include_ast': True
        })
        
        if result:
            return result
        return {}
    
    def validate_import_path(self, import_path: str, from_file: str = None) -> Dict:
        """Validate an import path."""
        result = self.query('validate_import', {
            'import_path': import_path,
            'from_file': from_file,
            'suggest_alternatives': True
        })
        
        if result:
            return result
        return {'valid': False, 'exists': False, 'suggestions': []}
    
    def get_naming_conventions(self) -> Dict:
        """Get naming conventions."""
        result = self.query('conventions', {
            'type': 'naming',
            'include_examples': True
        })
        
        if result:
            return result
        return {}
    
    def get_recent_changes(self, minutes: int = 30, file_pattern: str = None) -> List[Dict]:
        """Get recent code changes."""
        result = self.query('recent_changes', {
            'minutes': minutes,
            'file_pattern': file_pattern,
            'include_diffs': False
        })
        
        if result and 'changes' in result:
            return result['changes']
        return []
    
    def get_codebase_stats(self) -> Dict:
        """Get codebase statistics."""
        result = self.query('stats', {
            'detailed': True,
            'include_languages': True,
            'include_complexity': True
        })
        
        if result:
            return result
        return {}
    
    def find_unused_code(self, scope: str = 'all') -> List[Dict]:
        """Find potentially unused code."""
        result = self.query('unused_code', {
            'scope': scope,
            'confidence_threshold': 0.8
        })
        
        if result and 'unused' in result:
            return result['unused']
        return []
    
    def get_security_issues(self, severity: str = 'all') -> List[Dict]:
        """Get security issues from CKS."""
        result = self.query('security_scan', {
            'severity': severity,
            'include_fixes': True
        })
        
        if result and 'issues' in result:
            return result['issues']
        return []
    
    def batch_query(self, queries: List[Dict]) -> List[Optional[Dict]]:
        """Execute multiple queries in batch."""
        results = []
        
        for query_def in queries:
            endpoint = query_def.get('endpoint')
            data = query_def.get('data', {})
            result = self.query(endpoint, data)
            results.append(result)
        
        return results
    
    def get_cache_stats(self) -> Dict:
        """Get cache statistics."""
        total_requests = self.cache_hits + self.cache_misses
        hit_rate = (self.cache_hits / total_requests * 100) if total_requests > 0 else 0
        
        return {
            'cache_hits': self.cache_hits,
            'cache_misses': self.cache_misses,
            'hit_rate': f"{hit_rate:.1f}%",
            'memory_cache_size': len(self.memory_cache),
            'total_requests': total_requests
        }


# Global instance
_service_instance = None

def get_service() -> CKSQueryService:
    """Get singleton service instance."""
    global _service_instance
    if _service_instance is None:
        _service_instance = CKSQueryService()
    return _service_instance


def main():
    """CLI interface for testing."""
    if len(sys.argv) < 2:
        print("Usage: cks-query-service.py <command> [args]")
        print("Commands: search, similar, stats, recent, cache-stats")
        return
    
    service = get_service()
    command = sys.argv[1]
    
    if command == 'search' and len(sys.argv) > 2:
        query = ' '.join(sys.argv[2:])
        results = service.search_code(query)
        print(json.dumps(results, indent=2))
    
    elif command == 'similar' and len(sys.argv) > 2:
        func_name = sys.argv[2]
        results = service.find_similar_functions(func_name)
        print(json.dumps(results, indent=2))
    
    elif command == 'stats':
        stats = service.get_codebase_stats()
        print(json.dumps(stats, indent=2))
    
    elif command == 'recent':
        changes = service.get_recent_changes()
        print(json.dumps(changes, indent=2))
    
    elif command == 'cache-stats':
        stats = service.get_cache_stats()
        print(json.dumps(stats, indent=2))
    
    else:
        print(f"Unknown command: {command}")


if __name__ == "__main__":
    main()