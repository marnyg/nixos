# Minimal Darwin profile
# Bare essentials for a Darwin system
{ lib, pkgs, ... }:
{
  imports = [ ./base.nix ];

  # Minimal configuration - just the essentials
  modules.darwin = {
    # Use conservative Nix settings for minimal systems
    nixSettings = {
      performance = {
        httpConnections = lib.mkDefault 32; # Fewer connections
        downloadBufferSize = lib.mkDefault 67108864; # 64MB buffer
      };
      optimizations = {
        gcAutomatic = lib.mkDefault false; # Manual GC only
      };
    };
  };

  # Only the most essential packages
  environment.systemPackages = lib.mkForce (with pkgs; [
    git
    vim
    curl
  ]);
}
