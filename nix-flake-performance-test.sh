#!/usr/bin/env bash
# Flake Input Change Performance Test
# This specifically tests the slowness when inputs change

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_test() {
    echo -e "\n${YELLOW}▶ $1${NC}"
}

# Check if we're in a flake directory
if [[ ! -f flake.nix ]]; then
    echo -e "${RED}Error: Not in a flake directory${NC}"
    exit 1
fi

print_header "Flake Input Change Performance Analysis"

# Test 1: Input fetching performance
print_test "Testing input fetching performance"
echo "Clearing eval cache first..."
rm -rf ~/.cache/nix/eval-cache-v5 2>/dev/null || true

echo "Testing with cold cache (first run):"
time_cold_start=$(date +%s.%N)
nix flake metadata --json . 2>&1 | grep -E "url|lastModified" | head -10
time_cold_end=$(date +%s.%N)
time_cold=$(echo "$time_cold_end - $time_cold_start" | bc)
echo -e "${GREEN}Cold cache time: ${time_cold}s${NC}"

echo -e "\nTesting with warm cache (second run):"
time_warm_start=$(date +%s.%N)
nix flake metadata --json . 2>&1 | grep -E "url|lastModified" | head -10
time_warm_end=$(date +%s.%N)
time_warm=$(echo "$time_warm_end - $time_warm_start" | bc)
echo -e "${GREEN}Warm cache time: ${time_warm}s${NC}"

speedup=$(echo "scale=2; $time_cold / $time_warm" | bc)
echo -e "${BLUE}Cache speedup: ${speedup}x${NC}"

# Test 2: Lock file operations
print_test "Testing lock file operations"

# Backup current lock file
cp flake.lock flake.lock.backup 2>/dev/null || true

echo "Testing flake update performance:"
time_update_start=$(date +%s.%N)
nix flake update --override-input nixpkgs nixpkgs 2>&1 | head -5
time_update_end=$(date +%s.%N)
time_update=$(echo "$time_update_end - $time_update_start" | bc)
echo -e "${GREEN}Update time: ${time_update}s${NC}"

# Restore lock file
mv flake.lock.backup flake.lock 2>/dev/null || true

# Test 3: Evaluation with different cache states
print_test "Testing evaluation performance with cache states"

# Get the default package or configuration
if nix flake show --json . 2>/dev/null | jq -e '.packages."aarch64-darwin"' > /dev/null; then
    EVAL_TARGET=".#packages.aarch64-darwin.default"
elif nix flake show --json . 2>/dev/null | jq -e '.packages."x86_64-darwin"' > /dev/null; then
    EVAL_TARGET=".#packages.x86_64-darwin.default"
elif nix flake show --json . 2>/dev/null | jq -e '.darwinConfigurations.mac' > /dev/null; then
    EVAL_TARGET=".#darwinConfigurations.mac.system"
else
    EVAL_TARGET=".#default"
fi

echo "Using evaluation target: $EVAL_TARGET"

# Test with eval cache
echo -e "\nWith eval cache:"
time_eval_cached_start=$(date +%s.%N)
nix eval "$EVAL_TARGET" --raw 2>/dev/null || nix eval "$EVAL_TARGET" 2>&1 | head -1
time_eval_cached_end=$(date +%s.%N)
time_eval_cached=$(echo "$time_eval_cached_end - $time_eval_cached_start" | bc)
echo -e "${GREEN}Cached eval time: ${time_eval_cached}s${NC}"

# Test without eval cache
echo -e "\nWithout eval cache (--no-eval-cache):"
time_eval_uncached_start=$(date +%s.%N)
nix eval "$EVAL_TARGET" --no-eval-cache --raw 2>/dev/null || nix eval "$EVAL_TARGET" --no-eval-cache 2>&1 | head -1
time_eval_uncached_end=$(date +%s.%N)
time_eval_uncached=$(echo "$time_eval_uncached_end - $time_eval_uncached_start" | bc)
echo -e "${GREEN}Uncached eval time: ${time_eval_uncached}s${NC}"

# Test 4: Network dependency analysis
print_test "Analyzing network dependencies"

echo "Checking input sources:"
nix flake metadata --json . 2>/dev/null | jq -r '
    .locks.nodes | to_entries[] | 
    select(.key != "root") | 
    "\(.key): \(.value.locked.type // "unknown")"
' | while read -r line; do
    input_name=$(echo "$line" | cut -d: -f1)
    input_type=$(echo "$line" | cut -d: -f2 | xargs)
    
    if [[ "$input_type" == "github" ]]; then
        echo "  $input_name: GitHub (network fetch required)"
    elif [[ "$input_type" == "git" ]]; then
        echo "  $input_name: Git (network fetch required)"
    elif [[ "$input_type" == "path" ]]; then
        echo "  $input_name: Local path (no network)"
    else
        echo "  $input_name: $input_type"
    fi
done

# Test 5: Git operations performance
print_test "Testing git operations (if applicable)"

if [[ -d .git ]]; then
    echo "Repository status:"
    if git diff --quiet 2>/dev/null; then
        echo -e "${GREEN}  ✓ Clean working tree${NC}"
    else
        echo -e "${YELLOW}  ⚠ Dirty working tree (affects flake evaluation)${NC}"
        
        # Test impact of dirty tree
        echo -e "\nTesting dirty tree impact:"
        time_dirty_start=$(date +%s.%N)
        nix flake metadata . 2>&1 | grep -q "Git tree"
        time_dirty_end=$(date +%s.%N)
        time_dirty=$(echo "$time_dirty_end - $time_dirty_start" | bc)
        echo "  Dirty tree check time: ${time_dirty}s"
    fi
    
    # Check git repo size
    git_size=$(du -sh .git | cut -f1)
    echo "  Git repository size: $git_size"
    
    if [[ $(du -s .git | cut -f1) -gt 1048576 ]]; then  # > 1GB
        echo -e "${YELLOW}  ⚠ Large git repository may slow operations${NC}"
    fi
fi

# Test 6: Platform-specific binary availability
print_test "Checking platform-specific binary availability"

platform=$(nix eval --impure --expr 'builtins.currentSystem' --raw)
echo "Current platform: $platform"

if [[ "$platform" == "aarch64-darwin" ]]; then
    echo -e "${YELLOW}Apple Silicon detected - checking binary cache coverage:${NC}"
    
    # Check a few common packages
    for pkg in hello git curl neovim firefox; do
        if nix build --dry-run "nixpkgs#$pkg" 2>&1 | grep -q "will be built"; then
            echo "  ✗ $pkg: needs building (no cache)"
        else
            echo "  ✓ $pkg: available from cache"
        fi
    done
elif [[ "$platform" == "x86_64-darwin" ]]; then
    echo "Intel Mac detected - better cache coverage expected"
fi

# Generate summary
print_header "Performance Summary"

echo "Key findings:"

# Check if cold start is significantly slower
if (( $(echo "$time_cold > $time_warm * 2" | bc -l) )); then
    echo -e "${YELLOW}• Input fetching is slow on cold cache (${time_cold}s vs ${time_warm}s)${NC}"
    echo "  → This explains slowness when inputs change"
fi

# Check evaluation cache impact
if (( $(echo "$time_eval_uncached > $time_eval_cached * 2" | bc -l) )); then
    echo -e "${YELLOW}• Evaluation is much slower without cache${NC}"
    echo "  → The eval cache is critical for performance"
fi

# Platform-specific advice
if [[ "$platform" == "aarch64-darwin" ]]; then
    echo -e "${YELLOW}• Running on Apple Silicon with limited binary cache${NC}"
    echo "  → Use --fallback flag and expect more builds from source"
fi

echo -e "\n${BLUE}Optimization suggestions:${NC}"
echo "1. Keep flake inputs updated regularly (smaller delta updates)"
echo "2. Use 'nix develop --profile /tmp/dev-profile' to cache dev shells"
echo "3. Set up a local binary cache with 'nix-serve' if you have multiple Macs"
echo "4. Consider using 'nix-direnv' for automatic caching of dev environments"
echo "5. Pin specific commits in flake inputs instead of branches for stability"

# Restore any backups
rm -f flake.lock.backup 2>/dev/null || true