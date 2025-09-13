#!/usr/bin/env python3
"""
Prompt and Choice Logger for Claude Code
Tracks all prompts, user choices, and patterns for CLS learning
"""
import json
import sys
import os
import time
import hashlib
from datetime import datetime
from pathlib import Path
import readline
import atexit

class PromptChoiceLogger:
    def __init__(self):
        self.session_id = f"session_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        self.log_dir = Path.home() / "Documents/projects/caia/knowledge-system/logs/prompts"
        self.log_dir.mkdir(parents=True, exist_ok=True)
        
        # Main prompt log file
        self.prompt_log = self.log_dir / f"prompts_{self.session_id}.jsonl"
        
        # Pattern tracking for CLS
        self.pattern_file = self.log_dir / "prompt_patterns.json"
        self.patterns = self._load_patterns()
        
        # Console replay file for backtracking
        self.console_log = self.log_dir / f"console_{self.session_id}.txt"
        
        # History tracking
        self.prompt_history = []
        self.choice_history = []
        
        # Setup readline history
        self.history_file = Path.home() / ".claude" / "prompt_history"
        self._setup_readline()
    
    def _setup_readline(self):
        """Setup readline for better prompt history"""
        try:
            readline.read_history_file(self.history_file)
        except (FileNotFoundError, PermissionError):
            pass  # Ignore if can't read history file
        try:
            readline.set_history_length(1000)
            atexit.register(readline.write_history_file, self.history_file)
        except:
            pass  # Ignore readline setup errors
    
    def _load_patterns(self):
        """Load existing patterns for CLS learning"""
        if self.pattern_file.exists():
            with open(self.pattern_file, 'r') as f:
                return json.load(f)
        return {
            "prompt_types": {},
            "choice_patterns": {},
            "decision_sequences": [],
            "common_workflows": []
        }
    
    def _save_patterns(self):
        """Save patterns for CLS learning"""
        with open(self.pattern_file, 'w') as f:
            json.dump(self.patterns, f, indent=2)
    
    def log_prompt(self, prompt_type, prompt_text, options=None, context=None):
        """Log a prompt that was shown to the user"""
        timestamp = datetime.now().isoformat()
        prompt_id = hashlib.md5(f"{timestamp}{prompt_text}".encode()).hexdigest()[:8]
        
        prompt_entry = {
            "id": prompt_id,
            "timestamp": timestamp,
            "session_id": self.session_id,
            "type": prompt_type,
            "prompt": prompt_text,
            "options": options,
            "context": context or {},
            "awaiting_response": True
        }
        
        # Log to JSONL file
        with open(self.prompt_log, 'a') as f:
            f.write(json.dumps(prompt_entry) + '\n')
        
        # Log to console file for replay
        with open(self.console_log, 'a') as f:
            f.write(f"\n{'='*60}\n")
            f.write(f"[{timestamp}] PROMPT ({prompt_type})\n")
            f.write(f"{'='*60}\n")
            f.write(f"{prompt_text}\n")
            if options:
                f.write("\nOPTIONS:\n")
                for i, opt in enumerate(options, 1):
                    f.write(f"  {i}. {opt}\n")
            f.write(f"{'='*60}\n")
        
        # Console output with color
        print(f"\033[1;36m[PROMPT-LOG] [{datetime.now().strftime('%H:%M:%S')}] Prompt shown: {prompt_type}\033[0m")
        
        # Track in current session
        self.prompt_history.append(prompt_entry)
        
        # Update patterns for CLS
        if prompt_type not in self.patterns["prompt_types"]:
            self.patterns["prompt_types"][prompt_type] = {"count": 0, "choices": {}}
        self.patterns["prompt_types"][prompt_type]["count"] += 1
        
        return prompt_id
    
    def log_choice(self, prompt_id, choice, choice_index=None, reasoning=None):
        """Log the user's choice for a prompt"""
        timestamp = datetime.now().isoformat()
        
        choice_entry = {
            "prompt_id": prompt_id,
            "timestamp": timestamp,
            "choice": choice,
            "choice_index": choice_index,
            "reasoning": reasoning,
            "response_time": None  # Calculate if we have the prompt timestamp
        }
        
        # Find the original prompt and calculate response time
        for prompt in reversed(self.prompt_history):
            if prompt["id"] == prompt_id:
                prompt_time = datetime.fromisoformat(prompt["timestamp"])
                response_time = (datetime.now() - prompt_time).total_seconds()
                choice_entry["response_time"] = response_time
                prompt["awaiting_response"] = False
                prompt["choice"] = choice
                break
        
        # Log to JSONL file
        with open(self.prompt_log, 'a') as f:
            f.write(json.dumps(choice_entry) + '\n')
        
        # Log to console file
        with open(self.console_log, 'a') as f:
            f.write(f"[{timestamp}] CHOICE: {choice}\n")
            if reasoning:
                f.write(f"  Reasoning: {reasoning}\n")
            if choice_entry["response_time"]:
                f.write(f"  Response time: {choice_entry['response_time']:.2f}s\n")
            f.write(f"{'='*60}\n\n")
        
        # Console output
        print(f"\033[1;32m[CHOICE-LOG] [{datetime.now().strftime('%H:%M:%S')}] User chose: {choice}\033[0m")
        
        # Track in session
        self.choice_history.append(choice_entry)
        
        # Update patterns for CLS learning
        self._update_choice_patterns(prompt_id, choice)
        
        # Send to CLS for immediate learning
        self._send_to_cls(prompt_id, choice_entry)
        
        return choice_entry
    
    def _update_choice_patterns(self, prompt_id, choice):
        """Update choice patterns for machine learning"""
        # Find the prompt type
        for prompt in self.prompt_history:
            if prompt["id"] == prompt_id:
                prompt_type = prompt["type"]
                
                # Track choice frequency
                if prompt_type in self.patterns["prompt_types"]:
                    choices = self.patterns["prompt_types"][prompt_type]["choices"]
                    if choice not in choices:
                        choices[choice] = 0
                    choices[choice] += 1
                
                # Track decision sequences
                if len(self.choice_history) > 1:
                    sequence = [self.choice_history[-2]["choice"], choice]
                    self.patterns["decision_sequences"].append({
                        "sequence": sequence,
                        "timestamp": datetime.now().isoformat()
                    })
                
                break
        
        self._save_patterns()
    
    def _send_to_cls(self, prompt_id, choice_entry):
        """Send choice to CLS for immediate learning"""
        try:
            import subprocess
            cls_path = Path.home() / "Documents/projects/caia/knowledge-system/cls"
            if cls_path.exists():
                subprocess.run([
                    "python3",
                    str(cls_path / "learn_from_choice.py"),
                    "--prompt-id", prompt_id,
                    "--choice", json.dumps(choice_entry)
                ], capture_output=True, timeout=1)
        except:
            pass  # Don't block on CLS
    
    def get_prompt_history(self, last_n=10):
        """Get recent prompt/choice history"""
        history = []
        for prompt in self.prompt_history[-last_n:]:
            choice = next((c for c in self.choice_history 
                          if c["prompt_id"] == prompt["id"]), None)
            history.append({
                "prompt": prompt,
                "choice": choice
            })
        return history
    
    def replay_session(self, session_id=None):
        """Replay a session's prompts and choices"""
        if not session_id:
            session_id = self.session_id
        
        console_file = self.log_dir / f"console_{session_id}.txt"
        if console_file.exists():
            with open(console_file, 'r') as f:
                print(f.read())
        else:
            print(f"No console log found for session: {session_id}")
    
    def analyze_patterns(self):
        """Analyze patterns in prompts and choices"""
        analysis = {
            "total_prompts": len(self.prompt_history),
            "total_choices": len(self.choice_history),
            "avg_response_time": 0,
            "most_common_choices": {},
            "prompt_type_distribution": {}
        }
        
        # Calculate average response time
        response_times = [c["response_time"] for c in self.choice_history 
                         if c.get("response_time")]
        if response_times:
            analysis["avg_response_time"] = sum(response_times) / len(response_times)
        
        # Analyze prompt types
        for ptype, data in self.patterns["prompt_types"].items():
            analysis["prompt_type_distribution"][ptype] = data["count"]
            if data["choices"]:
                most_common = max(data["choices"].items(), key=lambda x: x[1])
                analysis["most_common_choices"][ptype] = most_common
        
        return analysis
    
    def backtrack(self, search_term=None, last_n=20):
        """Backtrack through console to find prompts and choices"""
        print("\033[1;33m" + "="*60 + "\033[0m")
        print("\033[1;33mBACKTRACKING PROMPT/CHOICE HISTORY\033[0m")
        print("\033[1;33m" + "="*60 + "\033[0m\n")
        
        history = self.get_prompt_history(last_n)
        
        for i, item in enumerate(history, 1):
            prompt = item["prompt"]
            choice = item["choice"]
            
            # Filter by search term if provided
            if search_term:
                if search_term.lower() not in prompt["prompt"].lower():
                    if not choice or search_term.lower() not in choice["choice"].lower():
                        continue
            
            # Display prompt
            print(f"\033[1;36m[{i}] {prompt['timestamp']}\033[0m")
            print(f"\033[1;36mType: {prompt['type']}\033[0m")
            print(f"Prompt: {prompt['prompt'][:100]}...")
            
            if prompt.get("options"):
                print("Options:", ", ".join(prompt["options"][:3]))
            
            # Display choice if made
            if choice:
                print(f"\033[1;32m  → Choice: {choice['choice']}\033[0m")
                if choice.get("response_time"):
                    print(f"     (Response time: {choice['response_time']:.2f}s)")
            else:
                print("\033[1;33m  → Awaiting response...\033[0m")
            
            print("-" * 60)
        
        # Show pattern analysis
        print("\n\033[1;35mPATTERN ANALYSIS:\033[0m")
        analysis = self.analyze_patterns()
        print(f"Total prompts: {analysis['total_prompts']}")
        print(f"Total choices: {analysis['total_choices']}")
        if analysis['avg_response_time']:
            print(f"Avg response time: {analysis['avg_response_time']:.2f}s")
        
        if analysis['most_common_choices']:
            print("\nMost common choices by prompt type:")
            for ptype, (choice, count) in analysis['most_common_choices'].items():
                print(f"  {ptype}: '{choice}' ({count} times)")

# Global logger instance
prompt_logger = PromptChoiceLogger()

# Convenience functions for shell integration
def log_prompt(prompt_type, prompt_text, options=None):
    """Quick function to log a prompt"""
    return prompt_logger.log_prompt(prompt_type, prompt_text, options)

def log_choice(prompt_id, choice, reasoning=None):
    """Quick function to log a choice"""
    return prompt_logger.log_choice(prompt_id, choice, reasoning=reasoning)

def backtrack(search_term=None, last_n=20):
    """Backtrack through prompts and choices"""
    prompt_logger.backtrack(search_term, last_n)

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Prompt and Choice Logger")
    parser.add_argument("action", choices=["prompt", "choice", "backtrack", "replay", "analyze"])
    parser.add_argument("--type", help="Prompt type")
    parser.add_argument("--text", help="Prompt text")
    parser.add_argument("--options", nargs="+", help="Prompt options")
    parser.add_argument("--prompt-id", help="Prompt ID for choice")
    parser.add_argument("--choice", help="User's choice")
    parser.add_argument("--reasoning", help="Reasoning for choice")
    parser.add_argument("--search", help="Search term for backtrack")
    parser.add_argument("--last", type=int, default=20, help="Number of items to show")
    parser.add_argument("--session", help="Session ID for replay")
    
    args = parser.parse_args()
    
    if args.action == "prompt":
        prompt_id = log_prompt(args.type or "general", args.text or "No text", args.options)
        print(f"Prompt ID: {prompt_id}")
    
    elif args.action == "choice":
        if args.prompt_id and args.choice:
            log_choice(args.prompt_id, args.choice, reasoning=args.reasoning)
    
    elif args.action == "backtrack":
        backtrack(args.search, args.last)
    
    elif args.action == "replay":
        prompt_logger.replay_session(args.session)
    
    elif args.action == "analyze":
        analysis = prompt_logger.analyze_patterns()
        print(json.dumps(analysis, indent=2))