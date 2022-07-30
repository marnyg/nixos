#!/usr/bin/env bash

set -e


PROFILE=/nix/var/nix/profiles/system

# Build the VM system
nixos-rebuild build --flake ".#mardesk"
outPath=$(readlink ./result)
echo $outPath  
# outPath=$(nix-build -A vmSystem --arg configuration ./configuration.nix)
# Upload to the VM
NIX_SSHOPTS="-p 2222" nix-copy-closure --to "vm@localhost" --from $outPath
# Activate the new system
ssh -p 2221 root@localhost nix-env --profile "$PROFILE" --set "$outPath"
ssh -p 2221 root@localhost $outPath/bin/switch-to-configuration test