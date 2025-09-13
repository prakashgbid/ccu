#!/usr/bin/env python3
"""
Real-time CC Attribution Monitor
Shows which tools are being used in real-time
"""
import json
import time
import os
import sys
from pathlib import Path
from datetime import datetime
from collections import defaultdict, deque
import curses

class CCAttributionMonitor:
    def __init__(self):
        self.log_dir = Path.home() / "Documents/projects/caia/knowledge-system/logs"
        self.stats = defaultdict(int)
        self.recent_operations = deque(maxlen=20)
        self.tool_colors = {}
        self.session_start = datetime.now()
        
    def find_latest_log(self):
        """Find the most recent log file"""
        log_files = list(self.log_dir.glob("cc_enhanced_*.jsonl"))
        if not log_files:
            return None
        return max(log_files, key=os.path.getctime)
    
    def parse_log_entry(self, line):
        """Parse a log entry and extract attribution info"""
        try:
            entry = json.loads(line)
            return {
                'timestamp': entry.get('timestamp', ''),
                'action': entry.get('action_type', ''),
                'details': entry.get('details', '')[:50],  # Truncate for display
                'tool': entry.get('tool_used', 'CC_NATIVE'),
                'attribution': entry.get('attribution', 'Unknown'),
                'project': entry.get('project', '-'),
                'source': entry.get('source', 'CC_NATIVE')
            }
        except:
            return None
    
    def update_stats(self, entry):
        """Update statistics from entry"""
        if entry:
            self.stats['total'] += 1
            self.stats[f"tool:{entry['tool']}"] += 1
            self.stats[f"source:{entry['source']}"] += 1
            self.stats[f"project:{entry['project']}"] += 1
            self.recent_operations.append(entry)
    
    def display_dashboard(self, stdscr):
        """Display real-time dashboard"""
        curses.curs_set(0)  # Hide cursor
        stdscr.nodelay(1)    # Non-blocking input
        
        # Color pairs
        curses.init_pair(1, curses.COLOR_GREEN, curses.COLOR_BLACK)   # CAIA tools
        curses.init_pair(2, curses.COLOR_CYAN, curses.COLOR_BLACK)    # CC Native
        curses.init_pair(3, curses.COLOR_YELLOW, curses.COLOR_BLACK)  # Custom scripts
        curses.init_pair(4, curses.COLOR_MAGENTA, curses.COLOR_BLACK) # Integration
        curses.init_pair(5, curses.COLOR_RED, curses.COLOR_BLACK)     # Errors
        curses.init_pair(6, curses.COLOR_WHITE, curses.COLOR_BLACK)   # Default
        
        log_file = self.find_latest_log()
        if not log_file:
            stdscr.addstr(0, 0, "No log file found. Waiting...")
            stdscr.refresh()
            return
        
        # Track file position
        with open(log_file, 'r') as f:
            # Skip to end for real-time monitoring
            f.seek(0, 2)
            
            while True:
                # Clear screen
                stdscr.clear()
                
                # Header
                stdscr.addstr(0, 0, "╔" + "═"*78 + "╗")
                stdscr.addstr(1, 0, "║")
                stdscr.addstr(1, 2, "CC ATTRIBUTION MONITOR - Real-time Tool Usage", curses.A_BOLD)
                stdscr.addstr(1, 79, "║")
                stdscr.addstr(2, 0, "╠" + "═"*78 + "╣")
                
                # Statistics section
                row = 3
                stdscr.addstr(row, 0, "║ STATISTICS")
                stdscr.addstr(row, 79, "║")
                row += 1
                stdscr.addstr(row, 0, "║" + "-"*78 + "║")
                row += 1
                
                # Calculate percentages
                total = self.stats.get('total', 0)
                native_count = self.stats.get('source:CC_NATIVE', 0)
                custom_count = total - native_count
                
                if total > 0:
                    native_pct = (native_count / total) * 100
                    custom_pct = (custom_count / total) * 100
                else:
                    native_pct = custom_pct = 0
                
                # Display stats
                stdscr.addstr(row, 0, "║")
                stdscr.addstr(row, 2, f"Total Operations: {total}")
                stdscr.addstr(row, 30, f"Session: {(datetime.now() - self.session_start).seconds}s")
                stdscr.addstr(row, 79, "║")
                row += 1
                
                stdscr.addstr(row, 0, "║")
                stdscr.addstr(row, 2, f"CC Native: {native_count} ({native_pct:.1f}%)", 
                            curses.color_pair(2))
                stdscr.addstr(row, 30, f"Custom Tools: {custom_count} ({custom_pct:.1f}%)", 
                            curses.color_pair(1))
                stdscr.addstr(row, 79, "║")
                row += 1
                
                # Top tools
                stdscr.addstr(row, 0, "║" + "-"*78 + "║")
                row += 1
                stdscr.addstr(row, 0, "║ TOP TOOLS USED")
                stdscr.addstr(row, 79, "║")
                row += 1
                
                # Get top 5 tools
                tool_stats = {k.replace('tool:', ''): v 
                            for k, v in self.stats.items() 
                            if k.startswith('tool:')}
                top_tools = sorted(tool_stats.items(), key=lambda x: x[1], reverse=True)[:5]
                
                for tool, count in top_tools:
                    stdscr.addstr(row, 0, "║")
                    tool_display = f"  {tool[:30]:<30} {count:>5} ops"
                    if "caia" in tool.lower() or "cc-orchestrator" in tool.lower():
                        stdscr.addstr(row, 2, tool_display, curses.color_pair(1))
                    elif tool == "CC_NATIVE" or tool.startswith("CC_NATIVE"):
                        stdscr.addstr(row, 2, tool_display, curses.color_pair(2))
                    else:
                        stdscr.addstr(row, 2, tool_display, curses.color_pair(3))
                    stdscr.addstr(row, 79, "║")
                    row += 1
                
                # Recent operations
                stdscr.addstr(row, 0, "║" + "-"*78 + "║")
                row += 1
                stdscr.addstr(row, 0, "║ RECENT OPERATIONS")
                stdscr.addstr(row, 79, "║")
                row += 1
                stdscr.addstr(row, 0, "║" + "-"*78 + "║")
                row += 1
                
                # Display recent ops
                for op in list(self.recent_operations)[-10:]:  # Last 10 operations
                    if row >= curses.LINES - 3:
                        break
                    
                    stdscr.addstr(row, 0, "║")
                    
                    # Format operation line
                    time_str = datetime.fromisoformat(op['timestamp']).strftime("%H:%M:%S")
                    op_line = f" {time_str} [{op['attribution'][:20]:<20}] {op['details'][:35]}"
                    
                    # Color based on source
                    if "CAIA" in op['source']:
                        stdscr.addstr(row, 1, op_line[:78], curses.color_pair(1))
                    elif op['source'] == "CC_NATIVE":
                        stdscr.addstr(row, 1, op_line[:78], curses.color_pair(2))
                    else:
                        stdscr.addstr(row, 1, op_line[:78], curses.color_pair(3))
                    
                    stdscr.addstr(row, 79, "║")
                    row += 1
                
                # Footer
                stdscr.addstr(row, 0, "╚" + "═"*78 + "╝")
                
                # Instructions
                if row + 2 < curses.LINES:
                    stdscr.addstr(row + 2, 0, "Press 'q' to quit, 'r' to reset stats", curses.A_DIM)
                
                stdscr.refresh()
                
                # Read new log entries
                line = f.readline()
                if line:
                    entry = self.parse_log_entry(line)
                    if entry:
                        self.update_stats(entry)
                
                # Check for user input
                key = stdscr.getch()
                if key == ord('q'):
                    break
                elif key == ord('r'):
                    self.stats.clear()
                    self.recent_operations.clear()
                
                time.sleep(0.1)  # Small delay to prevent CPU spinning
    
    def run(self):
        """Run the monitor"""
        try:
            curses.wrapper(self.display_dashboard)
        except KeyboardInterrupt:
            pass
        
        # Print final summary
        print("\n" + "="*60)
        print("SESSION SUMMARY")
        print("="*60)
        print(f"Total Operations: {self.stats.get('total', 0)}")
        print(f"CC Native: {self.stats.get('source:CC_NATIVE', 0)}")
        print(f"Custom Tools: {self.stats.get('total', 0) - self.stats.get('source:CC_NATIVE', 0)}")
        print("="*60)

if __name__ == "__main__":
    monitor = CCAttributionMonitor()
    monitor.run()