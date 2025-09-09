#!/usr/bin/env bash
# Wrapper script to run devenv update with better timeout handling

echo "Running nix flake update with extended timeouts..."

# Update the flake directly with better timeout settings
nix flake update \
  --option connect-timeout 30 \
  --option download-attempts 10 \
  --option http-connections 50

# Now update devenv.lock
echo "Updating devenv.lock..."
devenv up --impure

echo "Update complete!"