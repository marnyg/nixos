#!/usr/bin/env bash
# Nix Performance Diagnostic Suite for macOS
# This script identifies performance bottlenecks in your Nix setup

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results storage
declare -A TEST_RESULTS
declare -A TEST_TIMES

# Helper functions
print_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_test() {
    echo -e "\n${YELLOW}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

measure_time() {
    local start=$(date +%s.%N)
    "$@"
    local end=$(date +%s.%N)
    echo "$end - $start" | bc
}

# System Information
system_info() {
    print_header "System Information"
    
    echo "Date: $(date)"
    echo "Hostname: $(hostname)"
    echo "macOS Version: $(sw_vers -productVersion)"
    echo "Architecture: $(uname -m)"
    echo "CPU: $(sysctl -n machdep.cpu.brand_string)"
    echo "CPU Cores: $(sysctl -n hw.ncpu)"
    echo "Memory: $(echo "$(sysctl -n hw.memsize) / 1073741824" | bc) GB"
    echo "Disk Type: $(diskutil info / | grep 'Solid State' | awk '{print $3}')"
    echo "File System: $(diskutil info / | grep 'File System' | cut -d: -f2 | xargs)"
    
    # Nix version
    echo -e "\nNix Version:"
    nix --version
    
    # Check if we're on Apple Silicon
    if [[ $(uname -m) == "arm64" ]]; then
        echo "Apple Silicon: Yes (M1/M2/M3)"
        TEST_RESULTS["apple_silicon"]="true"
    else
        echo "Apple Silicon: No (Intel)"
        TEST_RESULTS["apple_silicon"]="false"
    fi
}

# Test 1: Cache Connectivity
test_cache_connectivity() {
    print_header "Test 1: Cache Connectivity & Speed"
    
    local caches=(
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
    )
    
    for cache in "${caches[@]}"; do
        print_test "Testing $cache"
        
        # Test connectivity
        local start=$(date +%s.%N)
        if curl -s --connect-timeout 5 -o /dev/null -w "%{http_code}" "$cache/nix-cache-info" | grep -q "200"; then
            local end=$(date +%s.%N)
            local time=$(echo "$end - $start" | bc)
            print_success "Connected in ${time}s"
            TEST_RESULTS["cache_${cache//[^a-zA-Z0-9]/_}"]="connected"
            TEST_TIMES["cache_${cache//[^a-zA-Z0-9]/_}"]="$time"
            
            # Test download speed with a small NAR
            print_test "Testing download speed..."
            local speed=$(curl -s -w "%{speed_download}" -o /dev/null "${cache}/nar/0000000000000000000000000000000000000000000000000000000000000000.nar" 2>/dev/null || echo "0")
            local speed_mb=$(echo "scale=2; $speed / 1048576" | bc)
            echo "  Download speed: ${speed_mb} MB/s"
            TEST_RESULTS["cache_speed_${cache//[^a-zA-Z0-9]/_}"]="$speed_mb"
        else
            print_error "Failed to connect"
            TEST_RESULTS["cache_${cache//[^a-zA-Z0-9]/_}"]="failed"
        fi
    done
    
    # Check configured substituters
    print_test "Checking configured substituters"
    nix show-config | grep -A 5 "substituters"
}

# Test 2: Filesystem Performance
test_filesystem_performance() {
    print_header "Test 2: Filesystem Performance"
    
    local test_dir="/tmp/nix-perf-test-$$"
    mkdir -p "$test_dir"
    
    # Test small file creation (Nix creates many small files)
    print_test "Testing small file creation (1000 files)"
    local start=$(date +%s.%N)
    for i in {1..1000}; do
        echo "test" > "$test_dir/file$i"
    done
    local end=$(date +%s.%N)
    local create_time=$(echo "$end - $start" | bc)
    print_success "Created 1000 files in ${create_time}s"
    TEST_TIMES["fs_create_small"]="$create_time"
    
    # Test symlink creation (Nix uses many symlinks)
    print_test "Testing symlink creation (1000 symlinks)"
    start=$(date +%s.%N)
    for i in {1..1000}; do
        ln -s "$test_dir/file$i" "$test_dir/link$i"
    done
    end=$(date +%s.%N)
    local link_time=$(echo "$end - $start" | bc)
    print_success "Created 1000 symlinks in ${link_time}s"
    TEST_TIMES["fs_create_symlinks"]="$link_time"
    
    # Test file stat operations
    print_test "Testing stat operations (1000 files)"
    start=$(date +%s.%N)
    for i in {1..1000}; do
        stat "$test_dir/file$i" > /dev/null 2>&1
    done
    end=$(date +%s.%N)
    local stat_time=$(echo "$end - $start" | bc)
    print_success "Performed 1000 stat operations in ${stat_time}s"
    TEST_TIMES["fs_stat"]="$stat_time"
    
    # Cleanup
    rm -rf "$test_dir"
    
    # Check if APFS
    if diskutil info / | grep -q "APFS"; then
        print_warning "Using APFS filesystem (known to be slower for Nix operations)"
        TEST_RESULTS["filesystem"]="APFS"
    fi
}

# Test 3: Nix Store Analysis
test_nix_store() {
    print_header "Test 3: Nix Store Analysis"
    
    print_test "Analyzing Nix store size"
    local store_size=$(du -sh /nix/store 2>/dev/null | cut -f1)
    echo "  Store size: $store_size"
    TEST_RESULTS["store_size"]="$store_size"
    
    print_test "Counting store paths"
    local store_paths=$(find /nix/store -maxdepth 1 -type d | wc -l)
    echo "  Number of store paths: $store_paths"
    TEST_RESULTS["store_paths"]="$store_paths"
    
    if [[ $store_paths -gt 50000 ]]; then
        print_warning "Large store detected (>50k paths). Consider garbage collection."
    fi
    
    print_test "Checking store optimization"
    if nix-store --optimise --dry-run 2>&1 | grep -q "would save"; then
        local savings=$(nix-store --optimise --dry-run 2>&1 | grep "would save" | awk '{print $3, $4}')
        print_warning "Store could be optimized to save: $savings"
        TEST_RESULTS["store_optimizable"]="yes"
    else
        print_success "Store is optimized"
        TEST_RESULTS["store_optimizable"]="no"
    fi
}

# Test 4: Evaluation Performance
test_evaluation_performance() {
    print_header "Test 4: Evaluation Performance"
    
    # Test simple evaluation
    print_test "Testing simple expression evaluation"
    local start=$(date +%s.%N)
    nix eval --expr '1 + 1' > /dev/null 2>&1
    local end=$(date +%s.%N)
    local simple_time=$(echo "$end - $start" | bc)
    print_success "Simple evaluation took ${simple_time}s"
    TEST_TIMES["eval_simple"]="$simple_time"
    
    # Test nixpkgs evaluation
    print_test "Testing nixpkgs hello package evaluation"
    start=$(date +%s.%N)
    nix eval --impure --expr 'let pkgs = import <nixpkgs> {}; in pkgs.hello.version' > /dev/null 2>&1
    end=$(date +%s.%N)
    local nixpkgs_time=$(echo "$end - $start" | bc)
    print_success "Nixpkgs evaluation took ${nixpkgs_time}s"
    TEST_TIMES["eval_nixpkgs"]="$nixpkgs_time"
    
    # Test with stats
    print_test "Collecting evaluation statistics"
    NIX_SHOW_STATS=1 NIX_SHOW_STATS_PATH=/tmp/nix-stats-$$.json nix eval --impure --expr 'let pkgs = import <nixpkgs> {}; in pkgs.hello' > /dev/null 2>&1
    
    if [[ -f /tmp/nix-stats-$$.json ]]; then
        local heap_size=$(jq -r '.gc.heapSize' /tmp/nix-stats-$$.json 2>/dev/null || echo "N/A")
        local total_allocs=$(jq -r '.gc.totalBytes' /tmp/nix-stats-$$.json 2>/dev/null || echo "N/A")
        echo "  Heap size: $heap_size bytes"
        echo "  Total allocations: $total_allocs bytes"
        rm -f /tmp/nix-stats-$$.json
    fi
}

# Test 5: Binary Cache Availability
test_binary_cache_availability() {
    print_header "Test 5: Binary Cache Availability"
    
    print_test "Checking platform binary availability"
    
    # Test a common package
    local test_pkg="hello"
    echo "  Testing package: $test_pkg"
    
    # Check if binary is available
    if nix build --dry-run "nixpkgs#$test_pkg" 2>&1 | grep -q "will be built"; then
        print_warning "$test_pkg will be built from source (no binary cache)"
        TEST_RESULTS["binary_cache_hit"]="miss"
        
        # Check why
        if [[ "${TEST_RESULTS["apple_silicon"]}" == "true" ]]; then
            print_warning "Apple Silicon has fewer cached binaries"
        fi
    else
        print_success "$test_pkg is available from binary cache"
        TEST_RESULTS["binary_cache_hit"]="hit"
    fi
    
    # Check cache info
    print_test "Checking cache statistics"
    nix store ping --json | jq -r '
        "  Cache: " + .url + "\n" +
        "  Status: " + (if .reachable then "Reachable" else "Unreachable" end) + "\n" +
        "  Trusted: " + (if .trusted then "Yes" else "No" end)
    ' 2>/dev/null || echo "  Could not get cache statistics"
}

# Test 6: Flake Performance (if in a flake directory)
test_flake_performance() {
    if [[ -f flake.nix ]]; then
        print_header "Test 6: Flake Performance"
        
        print_test "Testing flake metadata"
        local start=$(date +%s.%N)
        nix flake metadata --json . > /dev/null 2>&1
        local end=$(date +%s.%N)
        local metadata_time=$(echo "$end - $start" | bc)
        print_success "Flake metadata took ${metadata_time}s"
        TEST_TIMES["flake_metadata"]="$metadata_time"
        
        print_test "Testing flake show (may take a while)"
        start=$(date +%s.%N)
        timeout 30 nix flake show --json . > /dev/null 2>&1
        if [[ $? -eq 124 ]]; then
            print_warning "Flake show timed out after 30s"
            TEST_TIMES["flake_show"]="timeout"
        else
            end=$(date +%s.%N)
            local show_time=$(echo "$end - $start" | bc)
            print_success "Flake show took ${show_time}s"
            TEST_TIMES["flake_show"]="$show_time"
        fi
    else
        print_header "Test 6: Flake Performance"
        print_warning "Not in a flake directory, skipping flake tests"
    fi
}

# Test 7: Daemon Performance
test_daemon_performance() {
    print_header "Test 7: Nix Daemon Analysis"
    
    print_test "Checking nix-daemon status"
    if launchctl list | grep -q org.nixos.nix-daemon; then
        print_success "nix-daemon is running"
        TEST_RESULTS["daemon_running"]="yes"
        
        # Check daemon load
        local daemon_pid=$(launchctl list | grep org.nixos.nix-daemon | awk '{print $1}')
        if [[ "$daemon_pid" != "-" ]]; then
            local cpu_usage=$(ps aux | grep -E "^[^ ]+[ ]+$daemon_pid" | awk '{print $3}')
            echo "  Daemon CPU usage: ${cpu_usage}%"
            TEST_RESULTS["daemon_cpu"]="$cpu_usage"
        fi
    else
        print_error "nix-daemon is not running"
        TEST_RESULTS["daemon_running"]="no"
    fi
    
    # Check for daemon socket
    print_test "Checking daemon socket"
    if [[ -S /nix/var/nix/daemon-socket/socket ]]; then
        print_success "Daemon socket exists"
    else
        print_error "Daemon socket not found"
    fi
}

# Generate Report
generate_report() {
    print_header "Performance Analysis Report"
    
    echo -e "\n${YELLOW}Key Findings:${NC}"
    
    # Analyze filesystem performance
    if [[ -n "${TEST_TIMES[fs_create_small]}" ]]; then
        local fs_time="${TEST_TIMES[fs_create_small]}"
        if (( $(echo "$fs_time > 2" | bc -l) )); then
            print_warning "Slow filesystem operations detected (${fs_time}s for 1000 files)"
            echo "  → Consider using a case-sensitive APFS volume for /nix"
        fi
    fi
    
    # Analyze cache connectivity
    local slow_cache=false
    for key in "${!TEST_TIMES[@]}"; do
        if [[ $key == cache_* ]] && [[ "${TEST_TIMES[$key]}" != "" ]]; then
            if (( $(echo "${TEST_TIMES[$key]} > 1" | bc -l) )); then
                slow_cache=true
            fi
        fi
    done
    
    if [[ "$slow_cache" == "true" ]]; then
        print_warning "Slow cache connectivity detected"
        echo "  → Consider adding closer/faster binary caches"
    fi
    
    # Analyze binary availability
    if [[ "${TEST_RESULTS[binary_cache_hit]}" == "miss" ]]; then
        print_warning "Binary packages not available for your platform"
        echo "  → Expect longer build times, consider using --fallback"
        if [[ "${TEST_RESULTS[apple_silicon]}" == "true" ]]; then
            echo "  → Apple Silicon has limited binary cache coverage"
        fi
    fi
    
    # Store optimization
    if [[ "${TEST_RESULTS[store_optimizable]}" == "yes" ]]; then
        print_warning "Nix store can be optimized"
        echo "  → Run: nix-store --optimise"
    fi
    
    echo -e "\n${YELLOW}Performance Metrics:${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    for key in "${!TEST_TIMES[@]}"; do
        printf "%-30s %s seconds\n" "$key:" "${TEST_TIMES[$key]}"
    done | sort
    
    echo -e "\n${YELLOW}Recommendations:${NC}"
    
    # Platform-specific recommendations
    if [[ "${TEST_RESULTS[apple_silicon]}" == "true" ]]; then
        echo "1. For Apple Silicon Macs:"
        echo "   - Always use --fallback flag"
        echo "   - Consider setting up a local binary cache"
        echo "   - Use rosetta for x86_64 packages when needed"
    fi
    
    if [[ "${TEST_RESULTS[filesystem]}" == "APFS" ]]; then
        echo "2. For APFS filesystem:"
        echo "   - Consider creating a case-sensitive volume for /nix"
        echo "   - Disable auto-optimise-store in nix.conf"
    fi
    
    echo "3. General optimizations:"
    echo "   - Increase download-buffer-size in nix.conf"
    echo "   - Enable parallel downloads"
    echo "   - Use nix-direnv for development shells"
    echo "   - Regular garbage collection (nix-collect-garbage -d)"
}

# Main execution
main() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║           Nix Performance Diagnostic Suite for macOS          ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    
    system_info
    test_cache_connectivity
    test_filesystem_performance
    test_nix_store
    test_evaluation_performance
    test_binary_cache_availability
    test_flake_performance
    test_daemon_performance
    generate_report
    
    echo -e "\n${GREEN}Diagnostics complete!${NC}"
}

# Run the diagnostic suite
main "$@"