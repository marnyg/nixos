# Nix Performance Benchmark
# Run this on both Mac and Linux to compare performance
{ pkgs ? import <nixpkgs> { } }:

pkgs.writeScriptBin "nix-performance-benchmark" ''
  #!${pkgs.bash}/bin/bash
  set -euo pipefail
  
  # Colors
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  NC='\033[0m'
  
  echo -e "''${BLUE}Nix Performance Benchmark''${NC}"
  echo "Platform: $(uname -s) $(uname -m)"
  echo "Nix version: $(nix --version)"
  echo "Date: $(date)"
  echo "════════════════════════════════════════════════════════"
  
  # Results file
  RESULTS_FILE="nix-benchmark-$(uname -s)-$(date +%Y%m%d-%H%M%S).json"
  
  # Initialize JSON results
  echo '{' > "$RESULTS_FILE"
  echo '  "platform": "'$(uname -s) $(uname -m)'",' >> "$RESULTS_FILE"
  echo '  "nix_version": "'$(nix --version)'",' >> "$RESULTS_FILE"
  echo '  "timestamp": "'$(date -Iseconds)'",' >> "$RESULTS_FILE"
  echo '  "tests": {' >> "$RESULTS_FILE"
  
  benchmark() {
    local name="$1"
    local cmd="$2"
    
    echo -e "\n''${YELLOW}▶ Test: $name''${NC}"
    
    # Warm up
    $cmd > /dev/null 2>&1 || true
    
    # Measure
    local times=()
    for i in {1..5}; do
      local start=$(date +%s.%N)
      $cmd > /dev/null 2>&1 || true
      local end=$(date +%s.%N)
      local duration=$(echo "$end - $start" | bc)
      times+=($duration)
      echo -n "."
    done
    echo
    
    # Calculate average
    local sum=0
    for t in "''${times[@]}"; do
      sum=$(echo "$sum + $t" | bc)
    done
    local avg=$(echo "scale=3; $sum / 5" | bc)
    
    echo -e "''${GREEN}Average: ''${avg}s''${NC}"
    
    # Add to JSON
    echo '    "'$name'": {' >> "$RESULTS_FILE"
    echo '      "average": '$avg',' >> "$RESULTS_FILE"
    echo '      "samples": ['$(IFS=,; echo "''${times[*]}")']' >> "$RESULTS_FILE"
    echo '    },' >> "$RESULTS_FILE"
  }
  
  # Test 1: Simple evaluation
  benchmark "simple_eval" "nix eval --expr '1 + 1'"
  
  # Test 2: List evaluation
  benchmark "list_eval" "nix eval --expr 'builtins.length (builtins.genList (x: x) 10000)'"
  
  # Test 3: Attribute set evaluation
  benchmark "attrset_eval" "nix eval --expr 'builtins.length (builtins.attrNames (builtins.listToAttrs (builtins.genList (x: { name = toString x; value = x; }) 1000)))'"
  
  # Test 4: String operations
  benchmark "string_ops" "nix eval --expr 'builtins.stringLength (builtins.concatStringsSep \"\" (builtins.genList (x: toString x) 10000))'"
  
  # Test 5: Nixpkgs import
  benchmark "nixpkgs_import" "nix eval --impure --expr '(import <nixpkgs> {}).lib.version'"
  
  # Test 6: Package evaluation
  benchmark "package_eval" "nix eval --impure --expr '(import <nixpkgs> {}).hello.version'"
  
  # Test 7: Derivation instantiation
  benchmark "derivation_instantiate" "nix-instantiate --eval -E 'with import <nixpkgs> {}; hello.outPath'"
  
  # Test 8: Path operations
  benchmark "path_ops" "nix eval --expr 'builtins.pathExists \"/nix/store\"'"
  
  # Test 9: JSON parsing
  benchmark "json_parse" "nix eval --expr 'builtins.fromJSON \"{ \\\"a\\\": 1, \\\"b\\\": 2 }\"'"
  
  # Test 10: Hash computation
  benchmark "hash_compute" "nix eval --expr 'builtins.hashString \"sha256\" \"test string\"'"
  
  # Close JSON
  sed -i "" '$ s/,$//' "$RESULTS_FILE" 2>/dev/null || sed -i '$ s/,$//' "$RESULTS_FILE"
  echo '  }' >> "$RESULTS_FILE"
  echo '}' >> "$RESULTS_FILE"

  echo -e "\n''${GREEN}Benchmark complete! Results saved to: $RESULTS_FILE''${NC}"

  # Print summary
  echo -e "\n''${BLUE}Summary:''${NC}"
  cat "$RESULTS_FILE" | ${pkgs.jq}/bin/jq -r '
  .tests | to_entries | map({
  test: .key,
  time: .value.average
  }) | sort_by(.time) | .[] |
  "  \(.test): \(.time)s"
  '

  # Platform-specific analysis
  if [[ "$(uname -s)" == "Darwin" ]]; then
    echo -e "\n''${YELLOW}macOS-specific notes:''${NC}"
    echo "• File system operations may be slower on APFS"
    echo "• Binary cache coverage is limited for aarch64-darwin"
    echo "• Consider comparing with Linux results"
  fi
''

