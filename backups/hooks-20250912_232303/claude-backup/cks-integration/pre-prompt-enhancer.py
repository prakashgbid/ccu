#!/usr/bin/env python3
"""
CKS Pre-Prompt Enhancer
Intercepts and enhances all CC prompts with CKS knowledge
"""

import sys
import json
import requests
import logging
import hashlib
import re
from pathlib import Path
from typing import Dict, List, Any, Optional
from datetime import datetime
import pickle

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/Users/MAC/.claude/cks-integration/logs/pre-prompt.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class CKSPrePromptEnhancer:
    """Enhances CC prompts with CKS context."""
    
    def __init__(self):
        self.cache_dir = Path('/Users/MAC/.claude/cks-integration/cache')
        self.cache_dir.mkdir(exist_ok=True)
        self.endpoints = [
            'http://localhost:5002/api/cks',
            'http://localhost:5001/api/cks',
            'http://localhost:5000'
        ]
        
        # Keywords that trigger different types of CKS queries
        self.action_keywords = {
            'create': ['create', 'build', 'implement', 'make', 'develop', 'construct'],
            'modify': ['update', 'modify', 'change', 'edit', 'refactor', 'improve'],
            'fix': ['fix', 'debug', 'solve', 'repair', 'patch', 'resolve'],
            'add': ['add', 'extend', 'append', 'include', 'integrate'],
            'search': ['find', 'search', 'locate', 'where', 'show'],
            'explain': ['explain', 'what', 'how', 'why', 'understand']
        }
        
        # Code-related keywords
        self.code_keywords = [
            'function', 'class', 'method', 'component', 'module',
            'api', 'endpoint', 'service', 'utility', 'helper',
            'model', 'schema', 'interface', 'type', 'struct'
        ]
    
    def query_cks(self, endpoint: str, query: Dict[str, Any]) -> Optional[Dict]:
        """Query CKS with caching."""
        cache_key = hashlib.md5(json.dumps(query, sort_keys=True).encode()).hexdigest()
        cache_file = self.cache_dir / f"{cache_key}.pkl"
        
        # Check cache (5 minute TTL)
        if cache_file.exists():
            age = datetime.now().timestamp() - cache_file.stat().st_mtime
            if age < 300:  # 5 minutes
                try:
                    with open(cache_file, 'rb') as f:
                        return pickle.load(f)
                except:
                    pass
        
        # Query CKS
        for base_endpoint in self.endpoints:
            try:
                url = f"{base_endpoint}{endpoint}"
                response = requests.post(url, json=query, timeout=2)
                if response.status_code == 200:
                    result = response.json()
                    # Cache result
                    with open(cache_file, 'wb') as f:
                        pickle.dump(result, f)
                    return result
            except Exception as e:
                continue
        
        return None
    
    def extract_intent(self, prompt: str) -> Dict[str, Any]:
        """Extract the user's intent from the prompt."""
        prompt_lower = prompt.lower()
        
        intent = {
            'action': None,
            'target': None,
            'is_code_related': False,
            'entities': []
        }
        
        # Determine action
        for action, keywords in self.action_keywords.items():
            if any(keyword in prompt_lower for keyword in keywords):
                intent['action'] = action
                break
        
        # Check if code-related
        if any(keyword in prompt_lower for keyword in self.code_keywords):
            intent['is_code_related'] = True
        
        # Extract potential function/class names (CamelCase or snake_case)
        patterns = [
            r'\b[A-Z][a-zA-Z0-9]+\b',  # CamelCase
            r'\b[a-z]+_[a-z_]+\b',      # snake_case
            r'\b[a-z]+[A-Z][a-zA-Z0-9]+\b'  # camelCase
        ]
        
        for pattern in patterns:
            matches = re.findall(pattern, prompt)
            intent['entities'].extend(matches)
        
        return intent
    
    def get_similar_code(self, prompt: str) -> List[Dict]:
        """Find similar code in CKS."""
        result = self.query_cks('/search', {
            'query': prompt,
            'type': 'semantic',
            'limit': 5,
            'threshold': 0.7
        })
        
        if result and 'results' in result:
            return result['results']
        return []
    
    def get_recent_changes(self, minutes: int = 30) -> List[Dict]:
        """Get recent code changes."""
        result = self.query_cks('/recent', {
            'minutes': minutes,
            'limit': 10
        })
        
        if result and 'changes' in result:
            return result['changes']
        return []
    
    def get_patterns(self, context: str) -> List[Dict]:
        """Get relevant patterns from CKS."""
        result = self.query_cks('/patterns', {
            'context': context,
            'limit': 3
        })
        
        if result and 'patterns' in result:
            return result['patterns']
        return []
    
    def get_dependencies(self, entities: List[str]) -> Dict[str, List]:
        """Get dependency information."""
        result = self.query_cks('/dependencies', {
            'entities': entities,
            'depth': 2
        })
        
        if result:
            return result
        return {}
    
    def enhance_prompt(self, original_prompt: str) -> str:
        """Enhance the prompt with CKS context."""
        logger.info(f"Enhancing prompt: {original_prompt[:100]}...")
        
        # Extract intent
        intent = self.extract_intent(original_prompt)
        
        # Build context based on intent
        context_parts = []
        
        # Add header
        context_parts.append("\n[🧠 CKS CONTEXT INJECTION]")
        context_parts.append("=" * 50)
        
        # 1. Check for similar existing code
        if intent['is_code_related'] and intent['action'] in ['create', 'add', 'implement']:
            similar_code = self.get_similar_code(original_prompt)
            if similar_code:
                context_parts.append("\n📍 EXISTING SIMILAR CODE:")
                for item in similar_code[:3]:
                    context_parts.append(f"  • {item.get('file', 'Unknown')}:{item.get('line', '?')} - {item.get('description', '')}")
                    if item.get('similarity', 0) > 0.85:
                        context_parts.append(f"    ⚠️ HIGH SIMILARITY ({item['similarity']:.0%}) - Consider reusing")
        
        # 2. Show recent relevant changes
        if intent['action'] in ['modify', 'fix', 'update']:
            recent = self.get_recent_changes(30)
            if recent:
                context_parts.append("\n🕐 RECENT RELATED CHANGES:")
                for change in recent[:3]:
                    time_ago = change.get('time_ago', 'unknown')
                    context_parts.append(f"  • {change.get('file', 'Unknown')} - {time_ago}")
                    context_parts.append(f"    {change.get('description', '')}")
        
        # 3. Add relevant patterns
        if intent['is_code_related']:
            patterns = self.get_patterns(original_prompt)
            if patterns:
                context_parts.append("\n📐 ESTABLISHED PATTERNS:")
                for pattern in patterns:
                    context_parts.append(f"  • {pattern.get('name', 'Unknown')}: {pattern.get('description', '')}")
                    if pattern.get('example'):
                        context_parts.append(f"    Example: {pattern['example']}")
        
        # 4. Add dependency information
        if intent['entities']:
            deps = self.get_dependencies(intent['entities'])
            if deps:
                context_parts.append("\n🔗 AVAILABLE DEPENDENCIES:")
                for entity, dep_list in list(deps.items())[:3]:
                    if dep_list:
                        context_parts.append(f"  • {entity}: {', '.join(dep_list[:5])}")
        
        # 5. Add action-specific guidance
        if intent['action'] == 'create' and intent['is_code_related']:
            context_parts.append("\n⚡ CKS RECOMMENDATIONS:")
            context_parts.append("  1. Check if similar functionality exists (see above)")
            context_parts.append("  2. Follow established patterns")
            context_parts.append("  3. Reuse available utilities")
            context_parts.append("  4. Maintain consistency with recent changes")
        
        # 6. Add statistics
        stats = self.query_cks('/stats', {})
        if stats:
            context_parts.append(f"\n📊 CKS STATUS: {stats.get('total_files', 0)} files indexed, "
                               f"{stats.get('total_functions', 0)} functions tracked, "
                               f"Last update: {stats.get('last_update', 'unknown')}")
        
        context_parts.append("=" * 50)
        context_parts.append("\n[Original Request]:")
        
        # Combine enhanced prompt
        enhanced = '\n'.join(context_parts) + '\n' + original_prompt
        
        # Log enhancement
        logger.info(f"Enhanced prompt with {len(context_parts)} context items")
        
        # Save to log for analysis
        with open('/Users/MAC/.claude/cks-integration/logs/enhancements.jsonl', 'a') as f:
            json.dump({
                'timestamp': datetime.now().isoformat(),
                'original': original_prompt[:500],
                'intent': intent,
                'context_items': len(context_parts),
                'enhanced_length': len(enhanced)
            }, f)
            f.write('\n')
        
        return enhanced
    
    def process(self, prompt: str) -> str:
        """Main processing function."""
        try:
            # Skip enhancement for certain prompts
            skip_keywords = ['hello', 'hi', 'thanks', 'help', 'status']
            if any(keyword in prompt.lower()[:20] for keyword in skip_keywords):
                return prompt
            
            # Enhance the prompt
            enhanced = self.enhance_prompt(prompt)
            
            return enhanced
            
        except Exception as e:
            logger.error(f"Error enhancing prompt: {e}")
            # Return original prompt on error
            return prompt


def main():
    """Main entry point for hook integration."""
    # Read prompt from stdin or command line
    if len(sys.argv) > 1:
        prompt = ' '.join(sys.argv[1:])
    else:
        prompt = sys.stdin.read().strip()
    
    if not prompt:
        return
    
    # Create enhancer
    enhancer = CKSPrePromptEnhancer()
    
    # Process and output enhanced prompt
    enhanced = enhancer.process(prompt)
    print(enhanced)


if __name__ == "__main__":
    main()