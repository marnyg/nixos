#!/usr/bin/env bash

set -e

CREDS="$HOME/.config/nats/context/NGS-Default-CLI.creds"
HOST="connect.ngs.global"

echo "=== NATS Network Traffic Capture Tool ==="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "This script requires root privileges for tcpdump."
  echo "Please run with sudo: sudo $0"
  exit 1
fi

# Create capture directory
CAPTURE_DIR="./nats-captures-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$CAPTURE_DIR"
echo "Captures will be saved to: $CAPTURE_DIR"
echo ""

# Function to capture traffic
capture_traffic() {
  local name=$1
  local command=$2
  local pcap_file="$CAPTURE_DIR/${name}.pcap"
  local txt_file="$CAPTURE_DIR/${name}.txt"

  echo "=== Capturing: $name ==="
  echo "Command: $command"

  # Start tcpdump in background
  tcpdump -i any -s 0 -w "$pcap_file" "host $HOST" 2>/dev/null &
  TCPDUMP_PID=$!

  # Wait for tcpdump to start
  sleep 1

  # Run the command
  eval "$command" > "$txt_file" 2>&1 || true

  # Wait a bit for all packets
  sleep 2

  # Stop tcpdump
  kill $TCPDUMP_PID 2>/dev/null || true
  wait $TCPDUMP_PID 2>/dev/null || true

  echo "Saved: $pcap_file"
  echo ""
}

# Capture official NATS CLI
capture_traffic "official-nats-cli" \
  "nats pub --creds '$CREDS' test.capture 'hello from official CLI'"

# Capture Lua client
capture_traffic "lua-nats-client" \
  "nix run .#nixvim -- -l nats-example.lua"

echo "=== Extracting CONNECT messages ==="

# Extract and display CONNECT messages from pcaps
for pcap in "$CAPTURE_DIR"/*.pcap; do
  name=$(basename "$pcap" .pcap)
  echo ""
  echo "--- $name ---"

  # Extract ASCII strings that contain CONNECT
  tcpdump -r "$pcap" -A 2>/dev/null | grep -A 20 "CONNECT {" | head -30 > "$CAPTURE_DIR/${name}-connect.txt" || true

  if [ -s "$CAPTURE_DIR/${name}-connect.txt" ]; then
    cat "$CAPTURE_DIR/${name}-connect.txt"
  else
    echo "No CONNECT message found in capture"
  fi
done

echo ""
echo "=== Analysis ==="
echo ""
echo "Capture files saved in: $CAPTURE_DIR"
echo ""
echo "To compare CONNECT messages:"
echo "  diff -u $CAPTURE_DIR/official-nats-cli-connect.txt $CAPTURE_DIR/lua-nats-client-connect.txt"
echo ""
echo "To view in Wireshark:"
echo "  wireshark $CAPTURE_DIR/official-nats-cli.pcap &"
echo "  wireshark $CAPTURE_DIR/lua-nats-client.pcap &"
echo ""
echo "Filter in Wireshark: tcp.stream eq 0 && tcp.flags.push == 1"
