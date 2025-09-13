#!/usr/bin/env python3
"""
Database Logger Integration
Replaces all file-based logging with unified database logging
"""
import sys
import json
import time
from pathlib import Path
from datetime import datetime

# Add path for unified database
sys.path.append(str(Path.home() / "Documents/projects/caia/knowledge-system"))
from unified_ai_database import unified_db

class DatabaseLogger:
    """
    Drop-in replacement for file-based loggers
    Everything goes to the unified database
    """
    
    def __init__(self):
        self.db = unified_db
        self.session_id = self.db.get_current_session()
        self.operation_stack = []  # Track operation hierarchy
    
    def log(self, action_type, details, source="CC_NATIVE", tool_used=None, 
            project=None, file_path=None, metadata=None):
        """
        Universal logging function - everything goes to database
        """
        # Determine tool if not provided
        if not tool_used:
            tool_used = self._detect_tool(details, source)
        
        # Log as operation
        operation_id = self.db.log_operation(
            operation_type=action_type,
            tool_used=tool_used,
            details=details,
            input_data={
                'project': project,
                'file_path': file_path,
                'source': source,
                'metadata': metadata
            },
            parent_operation_id=self.operation_stack[-1] if self.operation_stack else None
        )
        
        # Track operation hierarchy
        if action_type in ['PLANNING', 'PARALLEL']:
            self.operation_stack.append(operation_id)
        elif action_type in ['RESULT', 'COMPLETE']:
            if self.operation_stack:
                self.operation_stack.pop()
        
        # Console output for immediate feedback
        self._console_output(action_type, details, tool_used)
        
        return operation_id
    
    def log_prompt(self, prompt_type, prompt_text, options=None, context=None):
        """Log prompt to database"""
        current_op = self.operation_stack[-1] if self.operation_stack else None
        
        prompt_id = self.db.log_prompt(
            prompt_type=prompt_type,
            prompt_text=prompt_text,
            options=options,
            context=context,
            operation_id=current_op
        )
        
        # Console output
        print(f"\033[1;36m[DB-PROMPT] [{datetime.now().strftime('%H:%M:%S')}] {prompt_type}\033[0m")
        
        return prompt_id
    
    def log_choice(self, prompt_id, choice, reasoning=None, response_time_ms=None):
        """Log choice to database"""
        choice_id = self.db.log_choice(
            prompt_id=prompt_id,
            choice_value=choice,
            reasoning=reasoning,
            response_time_ms=response_time_ms or 0
        )
        
        # Console output
        print(f"\033[1;32m[DB-CHOICE] [{datetime.now().strftime('%H:%M:%S')}] {choice}\033[0m")
        
        return choice_id
    
    def log_pattern(self, operations):
        """Detect and log pattern"""
        pattern_id = self.db.detect_pattern(operations)
        
        print(f"\033[1;35m[DB-PATTERN] Pattern detected: {pattern_id[:8]}...\033[0m")
        
        return pattern_id
    
    def query_similar(self, operation_type, limit=5):
        """Query database for similar operations"""
        # This would query embeddings for similarity
        # For now, query by type
        conn = self.db.db_path
        # Implementation would go here
        pass
    
    def get_insights(self):
        """Get AI learning insights from database"""
        insights = self.db.get_learning_insights()
        
        print("\033[1;33m[DB-INSIGHTS] Recent learnings:\033[0m")
        for timestamp, learning_type, insight, confidence in insights:
            print(f"  • {insight} (confidence: {confidence:.2f})")
        
        return insights
    
    def predict_next(self):
        """Predict next likely action"""
        prediction = self.db.predict_next_action({})
        
        if prediction:
            print(f"\033[1;34m[DB-PREDICT] Next likely: {prediction}\033[0m")
        
        return prediction
    
    def _detect_tool(self, details, source):
        """Detect tool from details"""
        details_lower = details.lower()
        
        tool_patterns = {
            'cc-orchestrator': ['cco', 'orchestrator', 'parallel instances'],
            'knowledge-system': ['cks', 'knowledge', 'redundancy'],
            'integration-agent': ['integration', 'jira', 'github api'],
            'git': ['git ', 'commit', 'push', 'pull'],
            'npm': ['npm ', 'install', 'package'],
            'python': ['python', 'pip'],
        }
        
        for tool, patterns in tool_patterns.items():
            for pattern in patterns:
                if pattern in details_lower:
                    return tool
        
        return source
    
    def _console_output(self, action_type, details, tool_used):
        """Console output with color coding"""
        colors = {
            'PLANNING': '\033[1;36m',
            'EXECUTING': '\033[1;33m',
            'PARALLEL': '\033[1;32m',
            'RESULT': '\033[0;32m',
            'ERROR': '\033[1;31m',
            'DECISION': '\033[1;35m'
        }
        
        color = colors.get(action_type, '\033[0;37m')
        reset = '\033[0m'
        
        timestamp = datetime.now().strftime('%H:%M:%S')
        attribution = self.db._get_attribution(tool_used)
        
        print(f"{color}[DB-LOG] [{timestamp}] [{attribution}] {action_type}: {details}{reset}")

# Global instance - replaces file-based logger
db_logger = DatabaseLogger()

# Override the file-based loggers
def override_file_loggers():
    """Replace all file-based loggers with database logger"""
    
    # Override enhanced_verbose_logger
    sys.modules['enhanced_verbose_logger'] = sys.modules[__name__]
    
    # Override prompt_choice_logger
    sys.modules['prompt_choice_logger'] = sys.modules[__name__]
    
    print("✅ All logging now goes to unified database!")

# Convenience functions that match old interface
def log(*args, **kwargs):
    return db_logger.log(*args, **kwargs)

def log_prompt(*args, **kwargs):
    return db_logger.log_prompt(*args, **kwargs)

def log_choice(*args, **kwargs):
    return db_logger.log_choice(*args, **kwargs)

def get_insights():
    return db_logger.get_insights()

def predict_next():
    return db_logger.predict_next()

if __name__ == "__main__":
    print("="*60)
    print("🗄️ DATABASE LOGGER INTEGRATION")
    print("="*60)
    print("\n✅ All operations now logged to unified database:")
    print(f"   {unified_db.db_path}")
    print("\n📊 Database features:")
    print("  • Real-time operation tracking")
    print("  • Pattern detection & learning")
    print("  • Knowledge graph building")
    print("  • AI prediction capabilities")
    print("  • Tool performance analytics")
    print("\n🚀 No more scattered log files!")
    print("="*60)