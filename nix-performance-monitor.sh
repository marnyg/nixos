#!/usr/bin/env bash
# Real-time Nix Performance Monitor
# Monitors Nix operations in real-time to identify bottlenecks

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
SAMPLE_INTERVAL=1  # seconds
LOG_FILE="/tmp/nix-performance-monitor-$$.log"

# Cleanup on exit
trap cleanup EXIT
cleanup() {
    echo -e "\n${YELLOW}Cleaning up...${NC}"
    rm -f "$LOG_FILE"
    exit 0
}

print_header() {
    clear
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║            Nix Performance Monitor - Real-time               ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${CYAN}Press Ctrl+C to stop monitoring${NC}\n"
}

# Function to get nix-daemon stats
get_daemon_stats() {
    local daemon_pid=$(pgrep -x nix-daemon | head -1)
    if [[ -n "$daemon_pid" ]]; then
        ps aux | grep -E "^[^ ]+[ ]+$daemon_pid" | awk '{print $3 " " $4}'
    else
        echo "0 0"
    fi
}

# Function to monitor network activity
get_network_stats() {
    # Get bytes received for all network interfaces
    netstat -ibn | grep -E '^en|^lo' | awk '{sum+=$7} END {print sum}'
}

# Function to count active Nix processes
count_nix_processes() {
    pgrep -f "nix" | wc -l | xargs
}

# Function to check store operations
check_store_operations() {
    # Check if any nix operations are accessing the store
    lsof /nix/store 2>/dev/null | wc -l | xargs
}

# Function to monitor disk I/O (macOS specific)
get_disk_io() {
    iostat -d 1 1 | tail -1 | awk '{print $3}'
}

# Main monitoring loop
monitor() {
    local prev_network=0
    local iteration=0
    
    while true; do
        print_header
        
        # Timestamp
        echo -e "${GREEN}$(date '+%H:%M:%S')${NC}"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        # Nix daemon stats
        daemon_stats=($(get_daemon_stats))
        cpu_usage="${daemon_stats[0]:-0}"
        mem_usage="${daemon_stats[1]:-0}"
        
        echo -e "${YELLOW}Nix Daemon:${NC}"
        printf "  CPU Usage: %6s%%\n" "$cpu_usage"
        printf "  Memory:    %6s%%\n" "$mem_usage"
        
        # Active Nix processes
        nix_procs=$(count_nix_processes)
        echo -e "\n${YELLOW}Active Nix Processes:${NC} $nix_procs"
        
        # Show what Nix is doing
        if [[ $nix_procs -gt 0 ]]; then
            echo -e "${CYAN}  Current operations:${NC}"
            ps aux | grep -E "[n]ix" | grep -v "nix-daemon" | head -3 | while read -r line; do
                cmd=$(echo "$line" | awk '{for(i=11;i<=NF;i++) printf "%s ", $i; print ""}' | cut -c1-60)
                echo "    • $cmd..."
            done
        fi
        
        # Store activity
        store_ops=$(check_store_operations)
        echo -e "\n${YELLOW}Store File Operations:${NC} $store_ops"
        
        # Network activity
        current_network=$(get_network_stats)
        if [[ $iteration -gt 0 ]]; then
            network_delta=$((current_network - prev_network))
            network_mb=$(echo "scale=2; $network_delta / 1048576" | bc)
            echo -e "${YELLOW}Network Activity:${NC} ${network_mb} MB/s"
            
            # Detect downloads
            if (( $(echo "$network_mb > 1" | bc -l) )); then
                echo -e "  ${GREEN}➤ Active download detected${NC}"
            fi
        fi
        prev_network=$current_network
        
        # Disk I/O
        disk_io=$(get_disk_io)
        echo -e "${YELLOW}Disk I/O:${NC} ${disk_io} MB/s"
        
        # Check for common bottlenecks
        echo -e "\n${YELLOW}Status Indicators:${NC}"
        
        # Check if waiting on network
        if netstat -an | grep -q "ESTABLISHED.*:443"; then
            echo -e "  ${CYAN}◉ Network: Active HTTPS connections${NC}"
        fi
        
        # Check if building
        if ps aux | grep -q "[n]ix-build"; then
            echo -e "  ${YELLOW}◉ Building: Compilation in progress${NC}"
        fi
        
        # Check if evaluating
        if ps aux | grep -q "[n]ix eval"; then
            echo -e "  ${BLUE}◉ Evaluating: Nix expression evaluation${NC}"
        fi
        
        # Check if downloading
        if ps aux | grep -q "curl.*nar"; then
            echo -e "  ${GREEN}◉ Downloading: Fetching from binary cache${NC}"
        fi
        
        # Check cache directory size changes
        if [[ -d ~/.cache/nix ]]; then
            cache_size=$(du -sh ~/.cache/nix 2>/dev/null | cut -f1)
            echo -e "\n${YELLOW}Cache Size:${NC} $cache_size"
        fi
        
        # Log data for analysis
        echo "$(date +%s),$cpu_usage,$mem_usage,$nix_procs,$store_ops,$network_mb,$disk_io" >> "$LOG_FILE"
        
        iteration=$((iteration + 1))
        sleep $SAMPLE_INTERVAL
    done
}

# Start monitoring
echo -e "${GREEN}Starting Nix Performance Monitor...${NC}"
echo -e "${YELLOW}Tip: Run a Nix command in another terminal to see real-time metrics${NC}\n"
sleep 2

monitor