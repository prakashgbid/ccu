#!/usr/bin/env python3
"""
Performance Monitoring System for Claude Operations
Tracks execution times and identifies optimization opportunities
"""

import time
import json
import os
import statistics
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Any, Callable
from functools import wraps
import asyncio
import concurrent.futures
from collections import defaultdict

class PerformanceMonitor:
    """Monitor and optimize Claude's performance"""
    
    def __init__(self, cache_dir: str = "~/.claude/performance"):
        self.cache_dir = Path(cache_dir).expanduser()
        self.cache_dir.mkdir(parents=True, exist_ok=True)
        self.metrics_file = self.cache_dir / "metrics.json"
        self.metrics = self._load_metrics()
        self.current_session = {
            'start_time': datetime.now().isoformat(),
            'operations': []
        }
    
    def _load_metrics(self) -> Dict:
        """Load historical metrics"""
        if self.metrics_file.exists():
            with open(self.metrics_file, 'r') as f:
                return json.load(f)
        return {'operations': defaultdict(list), 'optimizations': []}
    
    def _save_metrics(self):
        """Save metrics to disk"""
        with open(self.metrics_file, 'w') as f:
            json.dump(self.metrics, f, indent=2, default=str)
    
    def time_operation(self, name: str):
        """Decorator to time operations"""
        def decorator(func: Callable):
            @wraps(func)
            def wrapper(*args, **kwargs):
                start = time.perf_counter()
                result = func(*args, **kwargs)
                duration = time.perf_counter() - start
                
                self.record_operation(name, duration)
                return result
            return wrapper
        return decorator
    
    def record_operation(self, name: str, duration: float, metadata: Dict = None):
        """Record an operation's performance"""
        operation = {
            'name': name,
            'duration': duration,
            'timestamp': datetime.now().isoformat(),
            'metadata': metadata or {}
        }
        
        self.current_session['operations'].append(operation)
        self.metrics['operations'][name].append(duration)
        
        # Analyze for optimization opportunities
        if len(self.metrics['operations'][name]) > 5:
            self._analyze_performance(name)
        
        self._save_metrics()
    
    def _analyze_performance(self, operation_name: str):
        """Analyze performance and suggest optimizations"""
        durations = self.metrics['operations'][operation_name][-10:]
        avg_duration = statistics.mean(durations)
        
        # Check if operation is slow
        if avg_duration > 1.0:  # More than 1 second
            optimization = {
                'operation': operation_name,
                'avg_duration': avg_duration,
                'suggestion': self._get_optimization_suggestion(operation_name, avg_duration),
                'timestamp': datetime.now().isoformat()
            }
            
            if optimization['suggestion']:
                self.metrics['optimizations'].append(optimization)
                print(f"⚡ Optimization suggestion for {operation_name}:")
                print(f"   {optimization['suggestion']}")
    
    def _get_optimization_suggestion(self, operation: str, duration: float) -> str:
        """Get optimization suggestion based on operation type"""
        suggestions = {
            'file_read': "Use parallel reads with batch_files() or cache results",
            'git_operation': "Use git_parallel() for multiple repos",
            'search': "Use ripgrep (rg) with --threads flag",
            'edit': "Use MultiEdit for multiple changes in same file",
            'test': "Use parallel test execution with pytest-xdist",
            'build': "Enable parallel builds with -j flag",
            'install': "Cache dependencies or use parallel installation"
        }
        
        for key, suggestion in suggestions.items():
            if key in operation.lower():
                return f"{suggestion} (current: {duration:.2f}s)"
        
        if duration > 5:
            return f"Consider parallelization or caching (current: {duration:.2f}s)"
        return ""
    
    def get_statistics(self) -> Dict:
        """Get performance statistics"""
        stats = {}
        
        for operation, durations in self.metrics['operations'].items():
            if durations:
                stats[operation] = {
                    'count': len(durations),
                    'total': sum(durations),
                    'mean': statistics.mean(durations),
                    'median': statistics.median(durations),
                    'min': min(durations),
                    'max': max(durations),
                    'stdev': statistics.stdev(durations) if len(durations) > 1 else 0
                }
        
        return stats
    
    def print_report(self):
        """Print performance report"""
        stats = self.get_statistics()
        
        print("\n" + "="*60)
        print("📊 PERFORMANCE REPORT")
        print("="*60)
        
        # Sort by total time spent
        sorted_ops = sorted(stats.items(), key=lambda x: x[1]['total'], reverse=True)
        
        for operation, metrics in sorted_ops[:10]:
            print(f"\n📌 {operation}")
            print(f"   Executions: {metrics['count']}")
            print(f"   Total time: {metrics['total']:.2f}s")
            print(f"   Average: {metrics['mean']:.2f}s")
            print(f"   Min/Max: {metrics['min']:.2f}s / {metrics['max']:.2f}s")
            
            # Highlight slow operations
            if metrics['mean'] > 1.0:
                print(f"   ⚠️  SLOW - Consider optimization!")
        
        # Show recent optimizations
        if self.metrics['optimizations']:
            print("\n" + "="*60)
            print("💡 RECENT OPTIMIZATION SUGGESTIONS")
            print("="*60)
            
            for opt in self.metrics['optimizations'][-5:]:
                print(f"\n• {opt['operation']}: {opt['suggestion']}")
    
    def benchmark_parallel(self, tasks: List[Callable], max_workers: int = 10):
        """Benchmark parallel vs sequential execution"""
        # Sequential
        start = time.perf_counter()
        sequential_results = [task() for task in tasks]
        sequential_time = time.perf_counter() - start
        
        # Parallel
        start = time.perf_counter()
        with concurrent.futures.ThreadPoolExecutor(max_workers=max_workers) as executor:
            parallel_results = list(executor.map(lambda t: t(), tasks))
        parallel_time = time.perf_counter() - start
        
        speedup = sequential_time / parallel_time
        
        print(f"\n⚡ PARALLEL EXECUTION BENCHMARK")
        print(f"   Sequential: {sequential_time:.2f}s")
        print(f"   Parallel: {parallel_time:.2f}s")
        print(f"   Speedup: {speedup:.1f}x")
        
        return speedup


class CacheManager:
    """Intelligent caching system"""
    
    def __init__(self, cache_dir: str = "~/.claude/cache"):
        self.cache_dir = Path(cache_dir).expanduser()
        self.cache_dir.mkdir(parents=True, exist_ok=True)
        self.cache_stats = defaultdict(lambda: {'hits': 0, 'misses': 0})
    
    def cache_key(self, *args, **kwargs) -> str:
        """Generate cache key from arguments"""
        import hashlib
        key_str = f"{args}_{kwargs}"
        return hashlib.md5(key_str.encode()).hexdigest()
    
    def cache(self, ttl: int = 3600):
        """Decorator for caching function results"""
        def decorator(func: Callable):
            @wraps(func)
            def wrapper(*args, **kwargs):
                key = self.cache_key(func.__name__, args, kwargs)
                cache_file = self.cache_dir / f"{key}.cache"
                
                # Check cache
                if cache_file.exists():
                    age = time.time() - cache_file.stat().st_mtime
                    if age < ttl:
                        self.cache_stats[func.__name__]['hits'] += 1
                        with open(cache_file, 'r') as f:
                            return json.load(f)
                
                # Cache miss
                self.cache_stats[func.__name__]['misses'] += 1
                result = func(*args, **kwargs)
                
                # Save to cache
                with open(cache_file, 'w') as f:
                    json.dump(result, f)
                
                return result
            return wrapper
        return decorator
    
    def clear_cache(self):
        """Clear all cache files"""
        for cache_file in self.cache_dir.glob("*.cache"):
            cache_file.unlink()
        print(f"✅ Cache cleared: {self.cache_dir}")
    
    def print_stats(self):
        """Print cache statistics"""
        print("\n📦 CACHE STATISTICS")
        print("="*40)
        
        for func_name, stats in self.cache_stats.items():
            total = stats['hits'] + stats['misses']
            hit_rate = (stats['hits'] / total * 100) if total > 0 else 0
            
            print(f"{func_name}:")
            print(f"  Hits: {stats['hits']}")
            print(f"  Misses: {stats['misses']}")
            print(f"  Hit Rate: {hit_rate:.1f}%")


class ParallelExecutor:
    """Execute tasks in parallel with monitoring"""
    
    @staticmethod
    async def run_async_tasks(tasks: List[Callable]) -> List[Any]:
        """Run tasks asynchronously"""
        async def async_wrapper(task):
            return await asyncio.get_event_loop().run_in_executor(None, task)
        
        return await asyncio.gather(*[async_wrapper(task) for task in tasks])
    
    @staticmethod
    def run_parallel(tasks: List[Callable], max_workers: int = 10) -> List[Any]:
        """Run tasks in parallel with thread pool"""
        with concurrent.futures.ThreadPoolExecutor(max_workers=max_workers) as executor:
            futures = [executor.submit(task) for task in tasks]
            return [f.result() for f in concurrent.futures.as_completed(futures)]
    
    @staticmethod
    def run_process_pool(tasks: List[Callable], max_workers: int = None) -> List[Any]:
        """Run CPU-intensive tasks with process pool"""
        with concurrent.futures.ProcessPoolExecutor(max_workers=max_workers) as executor:
            return list(executor.map(lambda t: t(), tasks))


# Global instances
monitor = PerformanceMonitor()
cache_manager = CacheManager()
parallel = ParallelExecutor()


# Example usage and utilities
def optimize_workflow(operation: str):
    """Suggest workflow optimization"""
    optimizations = {
        'multi_file_read': """
# Instead of:
for file in files:
    content = read(file)

# Use:
contents = parallel.run_parallel([lambda f=f: read(f) for f in files])
        """,
        'multi_repo_update': """
# Instead of:
for repo in repos:
    git.pull(repo)

# Use:
~/.claude/parallel_executor.sh git repo1 repo2 repo3
        """,
        'batch_edits': """
# Instead of multiple Edit calls:
Edit(file, old1, new1)
Edit(file, old2, new2)

# Use:
MultiEdit(file, [(old1, new1), (old2, new2)])
        """
    }
    
    if operation in optimizations:
        print(f"💡 Optimization for {operation}:")
        print(optimizations[operation])
    else:
        print(f"No specific optimization found for {operation}")


if __name__ == "__main__":
    # Demo performance monitoring
    print("🚀 Claude Performance Optimization System")
    
    # Show current stats
    monitor.print_report()
    cache_manager.print_stats()
    
    # Test parallel execution
    def slow_task(n):
        time.sleep(0.1)
        return n * 2
    
    tasks = [lambda i=i: slow_task(i) for i in range(10)]
    monitor.benchmark_parallel(tasks)
    
    # Show optimization suggestions
    print("\n💡 OPTIMIZATION TIPS:")
    print("1. Use parallel execution for independent tasks")
    print("2. Cache expensive operations")
    print("3. Batch similar operations")
    print("4. Use background processes (&) liberally")
    print("5. Prefer ripgrep over grep for searches")