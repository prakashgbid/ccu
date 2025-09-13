#\!/bin/bash

echo "🏃 PERFORMANCE TEST SUITE"
echo "========================"

# Test 1: Parallel file creation
echo -n "1. Creating 1000 files in parallel: "
start=$(date +%s%N)
for i in {1..1000}; do echo "test" > /tmp/test_$i 2>/dev/null & done; wait
end=$(date +%s%N)
echo "$((($end - $start) / 1000000))ms"
rm -f /tmp/test_* 2>/dev/null

# Test 2: Parallel network requests
echo -n "2. Parallel network verification (7 URLs): "
start=$(date +%s%N)
(
    curl -s https://github.com -o /dev/null &
    curl -s https://google.com -o /dev/null &
    curl -s https://stackoverflow.com -o /dev/null &
    curl -s https://pypi.org -o /dev/null &
    curl -s https://npmjs.com -o /dev/null &
    curl -s https://docker.com -o /dev/null &
    curl -s https://kubernetes.io -o /dev/null &
    wait
) 2>/dev/null
end=$(date +%s%N)
echo "$((($end - $start) / 1000000))ms"

# Test 3: Process spawning
echo -n "3. Spawning 500 processes: "
start=$(date +%s%N)
for i in {1..500}; do (exit 0) & done; wait
end=$(date +%s%N)
echo "$((($end - $start) / 1000000))ms"

# Test 4: Memory operations
echo -n "4. Memory operations (100MB): "
start=$(date +%s%N)
dd if=/dev/zero of=/dev/null bs=1M count=100 2>/dev/null
end=$(date +%s%N)
echo "$((($end - $start) / 1000000))ms"

echo "========================"
echo "✅ Performance test complete\!"
