#!/usr/bin/env python3
"""
Enhanced Verbose Logger for Claude Code
Tracks tool attribution and custom utility usage
"""
import sys
import json
import time
import os
import re
from datetime import datetime
from pathlib import Path
import subprocess
import inspect

class EnhancedCCLogger:
    def __init__(self):
        self.session_id = f"session_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        self.log_dir = Path.home() / "Documents/projects/caia/knowledge-system/logs"
        self.log_dir.mkdir(parents=True, exist_ok=True)
        self.log_file = self.log_dir / f"cc_enhanced_{self.session_id}.jsonl"
        
        # Track custom tools and utilities
        self.custom_tools = self._discover_custom_tools()
        
        # Console colors for different sources
        self.source_colors = {
            "CC_NATIVE": "\033[1;36m",      # Cyan - Claude native
            "CAIA_TOOL": "\033[1;35m",      # Magenta - CAIA tools
            "CCO": "\033[1;32m",            # Green - CC Orchestrator
            "CKS": "\033[1;33m",            # Yellow - Knowledge System
            "INTEGRATION": "\033[1;34m",     # Blue - Integration Agent
            "CUSTOM_SCRIPT": "\033[0;35m",   # Purple - Custom scripts
            "PARALLEL": "\033[1;32m",        # Green - Parallel execution
            "ERROR": "\033[1;31m",           # Red - Errors
            "RESET": "\033[0m"
        }
        
        # Tool attribution mapping
        self.tool_attribution = {
            # CAIA Core Tools
            "cc-orchestrator": "CAIA/CCO",
            "cco": "CAIA/CCO",
            "integration-agent": "CAIA/IntegrationAgent",
            "knowledge-system": "CAIA/CKS",
            "cks": "CAIA/CKS",
            "cls": "CAIA/CLS",
            
            # CC Enhancement Systems
            "cps": "CAIA/CPS-ContextPersistence",
            "ckf": "CAIA/CKF-KnowledgeFusion",
            "cwa": "CAIA/CWA-WorkflowAutomator",
            "cav": "CAIA/CAV-AccuracyValidator",
            "cse": "CAIA/CSE-SelfEvolution",
            "cpe": "CAIA/CPE-PredictionEngine",
            "cer": "CAIA/CER-ErrorRecovery",
            "cmo": "CAIA/CMO-MultiAgentOrchestrator",
            "cpo": "CAIA/CPO-PerformanceOptimizer",
            "crt": "CAIA/CRT-RealTimeCollaborator",
            "cqa": "CAIA/CQA-QualityAssurance",
            "cdm": "CAIA/CDM-DecisionMemory",
            "cpa": "CAIA/CPA-PatternAnalyzer",
            "crc": "CAIA/CRC-ResourceController",
            "csm": "CAIA/CSM-SessionManager",
            "cih": "CAIA/CIH-IntegrationHub",
            
            # Admin Scripts
            "log_decision.py": "ADMIN/DecisionLogger",
            "capture_context.py": "ADMIN/ContextCapture",
            "query_context.py": "ADMIN/ContextQuery",
            "caia_tracker.py": "ADMIN/CAIATracker",
            "quick_status.sh": "ADMIN/QuickStatus",
            
            # Custom Scripts
            "parallel_executor.sh": "CUSTOM/ParallelExecutor",
            "batch_templates.sh": "CUSTOM/BatchTemplates",
            "verify_web_actions.sh": "CUSTOM/WebVerifier",
            
            # CC Ultimate Tools
            "ccu": "CCU/ConfigOptimizer",
            "test_ccu_integration.sh": "CCU/IntegrationTest",
            
            # Native CC Tools
            "Read": "CC_NATIVE/Read",
            "Write": "CC_NATIVE/Write",
            "Edit": "CC_NATIVE/Edit",
            "MultiEdit": "CC_NATIVE/MultiEdit",
            "Bash": "CC_NATIVE/Bash",
            "Task": "CC_NATIVE/Task",
            "Grep": "CC_NATIVE/Grep",
            "Glob": "CC_NATIVE/Glob",
            "WebFetch": "CC_NATIVE/WebFetch",
            "WebSearch": "CC_NATIVE/WebSearch",
            "TodoWrite": "CC_NATIVE/TodoWrite"
        }
    
    def _discover_custom_tools(self):
        """Discover all custom tools in the project"""
        tools = {}
        base_paths = [
            Path.home() / "Documents/projects/caia",
            Path.home() / "Documents/projects/admin",
            Path.home() / ".claude",
            Path.home() / "Documents/projects/claude-code-ultimate"
        ]
        
        for base_path in base_paths:
            if base_path.exists():
                # Find all executable scripts
                for script in base_path.rglob("*.sh"):
                    if os.access(script, os.X_OK):
                        tools[script.name] = str(script)
                
                # Find all Python scripts
                for script in base_path.rglob("*.py"):
                    tools[script.name] = str(script)
                
                # Find all JS tools
                for script in base_path.rglob("index.js"):
                    parent_name = script.parent.name
                    tools[parent_name] = str(script)
        
        return tools
    
    def log(self, action_type, details, source="CC_NATIVE", tool_used=None, 
            project=None, file_path=None, metadata=None):
        """Enhanced logging with tool attribution"""
        timestamp = datetime.now().isoformat()
        
        # Detect tool from details if not provided
        if not tool_used and details:
            tool_used = self._detect_tool_from_details(details)
        
        # Get tool attribution
        attribution = self._get_attribution(tool_used, source)
        
        log_entry = {
            "timestamp": timestamp,
            "session_id": self.session_id,
            "action_type": action_type,
            "details": details,
            "source": source,
            "tool_used": tool_used,
            "attribution": attribution,
            "project": project or self._detect_project(file_path),
            "file_path": file_path,
            "metadata": metadata or {}
        }
        
        # Write to JSON log file
        with open(self.log_file, 'a') as f:
            f.write(json.dumps(log_entry) + '\n')
        
        # Enhanced console output with attribution
        self._console_output(log_entry)
        
        # Send to CKS with attribution
        self._send_to_cks(log_entry)
        
        return log_entry
    
    def _detect_tool_from_details(self, details):
        """Detect which tool is being used from the details string"""
        details_lower = details.lower()
        
        # Check for known tool patterns
        patterns = {
            r"cc.?orchestrator|cco": "cc-orchestrator",
            r"integration.?agent": "integration-agent",
            r"knowledge.?system|cks": "knowledge-system",
            r"log_decision\.py": "log_decision.py",
            r"capture_context\.py": "capture_context.py",
            r"parallel_executor": "parallel_executor.sh",
            r"ccu|cc.?ultimate": "ccu",
            r"jira.?connect": "jira-connect",
            r"github|gh\s": "github-cli",
            r"npm|pnpm|yarn": "package-manager",
            r"python3?|pip3?": "python",
            r"git\s": "git",
            r"docker": "docker",
            r"pytest|test": "testing-framework"
        }
        
        for pattern, tool in patterns.items():
            if re.search(pattern, details_lower):
                return tool
        
        # Check for file paths in custom tools
        for tool_name, tool_path in self.custom_tools.items():
            if tool_name in details or tool_path in details:
                return tool_name
        
        return None
    
    def _get_attribution(self, tool_used, source):
        """Get detailed attribution for the tool"""
        if not tool_used:
            return f"{source}/Direct"
        
        # Check if it's a known attributed tool
        if tool_used in self.tool_attribution:
            return self.tool_attribution[tool_used]
        
        # Check if it's a custom tool
        if tool_used in self.custom_tools:
            tool_path = Path(self.custom_tools[tool_used])
            if "caia" in str(tool_path):
                return f"CAIA/{tool_used}"
            elif "admin" in str(tool_path):
                return f"ADMIN/{tool_used}"
            elif "claude-code-ultimate" in str(tool_path):
                return f"CCU/{tool_used}"
            else:
                return f"CUSTOM/{tool_used}"
        
        # Default attribution
        return f"{source}/{tool_used}"
    
    def _detect_project(self, file_path):
        """Detect which project the action belongs to"""
        if not file_path:
            return None
        
        path_str = str(file_path).lower()
        
        # Project detection patterns
        projects = {
            "caia": ["caia", "knowledge-system", "cc-orchestrator"],
            "ccu": ["claude-code-ultimate", "ccu"],
            "admin": ["admin/scripts"],
            "roulette": ["roulette-community"],
            "omnimind": ["omnimind"],
            "paraforge": ["paraforge"]
        }
        
        for project, patterns in projects.items():
            for pattern in patterns:
                if pattern in path_str:
                    return project
        
        return None
    
    def _console_output(self, log_entry):
        """Enhanced console output with attribution"""
        timestamp = datetime.now().strftime("%H:%M:%S.%f")[:-3]
        action_type = log_entry['action_type']
        details = log_entry['details']
        attribution = log_entry['attribution']
        tool_used = log_entry['tool_used']
        
        # Determine color based on source
        source = log_entry['source']
        color = self.source_colors.get(source, self.source_colors["CC_NATIVE"])
        reset = self.source_colors["RESET"]
        
        # Format the message with attribution
        if tool_used:
            console_msg = f"{color}[CC-LOG] [{timestamp}] [{attribution}] {action_type}: {details}{reset}"
        else:
            console_msg = f"{color}[CC-LOG] [{timestamp}] {action_type}: {details}{reset}"
        
        print(console_msg, flush=True)
        
        # If it's a custom tool, show additional info
        if tool_used and tool_used in self.custom_tools:
            tool_path = self.custom_tools[tool_used]
            print(f"  └─ Tool Path: {tool_path}", flush=True)
    
    def _send_to_cks(self, log_entry):
        """Send enhanced log entry to CKS for pattern learning"""
        try:
            cks_path = Path.home() / "Documents/projects/caia/knowledge-system"
            if cks_path.exists():
                # Include attribution in CKS learning
                subprocess.run([
                    "python3",
                    str(cks_path / "cli/knowledge_cli.py"),
                    "log-cc-action",
                    "--json", json.dumps(log_entry),
                    "--attribution", log_entry.get('attribution', 'Unknown')
                ], capture_output=True, timeout=1)
        except:
            pass
    
    def log_tool_usage(self, tool_name, tool_type, args=None, result=None):
        """Specific logging for tool usage"""
        attribution = self._get_attribution(tool_name, tool_type)
        
        details = f"Using tool: {tool_name}"
        if args:
            args_str = str(args)[:100] + "..." if len(str(args)) > 100 else str(args)
            details += f" with args: {args_str}"
        
        self.log(
            action_type="TOOL_USAGE",
            details=details,
            source=tool_type,
            tool_used=tool_name,
            metadata={"args": args, "result": result}
        )
    
    def log_parallel_operation(self, operations, orchestrator="CCO"):
        """Log parallel operations with attribution"""
        for i, op in enumerate(operations):
            self.log(
                action_type="PARALLEL",
                details=f"Operation {i+1}/{len(operations)}: {op}",
                source="CAIA_TOOL",
                tool_used=orchestrator,
                metadata={"total_operations": len(operations), "index": i}
            )
    
    def generate_session_summary(self):
        """Generate a summary of tool usage for the session"""
        tool_usage = {}
        native_vs_custom = {"CC_NATIVE": 0, "CUSTOM": 0}
        
        with open(self.log_file, 'r') as f:
            for line in f:
                try:
                    entry = json.loads(line)
                    attribution = entry.get('attribution', 'Unknown')
                    
                    if attribution not in tool_usage:
                        tool_usage[attribution] = 0
                    tool_usage[attribution] += 1
                    
                    if "CC_NATIVE" in attribution:
                        native_vs_custom["CC_NATIVE"] += 1
                    else:
                        native_vs_custom["CUSTOM"] += 1
                except:
                    continue
        
        summary = {
            "session_id": self.session_id,
            "tool_usage": tool_usage,
            "native_vs_custom": native_vs_custom,
            "most_used_tool": max(tool_usage.items(), key=lambda x: x[1]) if tool_usage else None
        }
        
        # Print summary
        print("\n" + "="*60)
        print(f"SESSION SUMMARY: {self.session_id}")
        print("="*60)
        print(f"Native CC Operations: {native_vs_custom['CC_NATIVE']}")
        print(f"Custom Tool Operations: {native_vs_custom['CUSTOM']}")
        print("\nTop Tools Used:")
        for tool, count in sorted(tool_usage.items(), key=lambda x: x[1], reverse=True)[:10]:
            print(f"  {tool}: {count} operations")
        print("="*60)
        
        return summary

# Global logger instance
logger = EnhancedCCLogger()

# Convenience functions
def log_cc_action(action_type, details, **kwargs):
    """Quick logging function"""
    return logger.log(action_type, details, **kwargs)

def log_tool(tool_name, tool_type="CUSTOM", **kwargs):
    """Log tool usage"""
    return logger.log_tool_usage(tool_name, tool_type, **kwargs)

def log_parallel(operations, orchestrator="CCO"):
    """Log parallel operations"""
    return logger.log_parallel_operation(operations, orchestrator)

if __name__ == "__main__":
    # CLI interface
    if len(sys.argv) > 2:
        action = sys.argv[1]
        
        if action == "log":
            action_type = sys.argv[2]
            details = sys.argv[3] if len(sys.argv) > 3 else ""
            tool = sys.argv[4] if len(sys.argv) > 4 else None
            logger.log(action_type, details, tool_used=tool)
        
        elif action == "tool":
            tool_name = sys.argv[2]
            tool_type = sys.argv[3] if len(sys.argv) > 3 else "CUSTOM"
            logger.log_tool_usage(tool_name, tool_type)
        
        elif action == "summary":
            logger.generate_session_summary()