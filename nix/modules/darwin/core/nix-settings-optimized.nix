# Optimized Nix configuration for Darwin systems
# Addresses performance issues specific to macOS
{ pkgs, lib, ... }:
{
  nix = {
    enable = true;

    settings = {
      # Binary caches - add more to reduce building from source
      substituters = lib.mkDefault [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
        # Add more Darwin-specific caches if available
      ];

      trusted-public-keys = lib.mkDefault [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      # Trust settings
      trusted-users = [ "@admin" ];

      # Performance tuning for macOS
      max-jobs = lib.mkDefault "auto";
      cores = lib.mkDefault 0; # Use all cores

      # Network performance
      http-connections = lib.mkDefault 128;
      connect-timeout = lib.mkDefault 30;

      # Don't auto-optimise on APFS (slow)
      auto-optimise-store = lib.mkDefault false;

      # Enable flakes
      experimental-features = [ "nix-command" "flakes" ];

      # Fallback automatically when binaries aren't available
      fallback = lib.mkDefault true;

      # Keep build logs for debugging
      keep-build-log = lib.mkDefault true;

      # Sandbox settings (macOS specific)
      sandbox = lib.mkDefault true;

      # Build in parallel
      max-silent-time = lib.mkDefault 7200;
      timeout = lib.mkDefault 0;
    };

    # Extra options for performance
    extraOptions = ''
      # Increase download buffer size (256MB)
      download-buffer-size = 268435456
      
      # Keep fewer things to reduce I/O
      keep-outputs = false
      keep-derivations = false
      
      # Cache narinfo lookups longer
      narinfo-cache-negative-ttl = 3600
      narinfo-cache-positive-ttl = 14400
      
      # Reduce filesystem pressure
      min-free = ${toString (1024 * 1024 * 1024)}
      max-free = ${toString (5 * 1024 * 1024 * 1024)}
      
      # Platform settings for Apple Silicon
      ${lib.optionalString (pkgs.system == "aarch64-darwin") ''
        # Prefer native builds, add x86_64 as secondary
        extra-platforms = x86_64-darwin aarch64-darwin
        # But prefer aarch64 when possible
        system-features = [ "big-parallel" "benchmark" "nixos-test" "apple-silicon" ]
      ''}
      
      # Evaluation cache
      eval-cache = true
      
      # Flake settings
      accept-flake-config = true
      
      # GC settings
      gc-keep-outputs = false
      gc-keep-derivations = false
      
      # Warn about dirty git trees but don't fail
      warn-dirty = true
      
      # Use xz compression for better cache efficiency
      compress-build-log = true
      
      # Binary cache settings
      narinfo-cache-positive-ttl = 14400
      narinfo-cache-negative-ttl = 3600
    '';

    # Garbage collection - less aggressive to reduce I/O
    gc = {
      automatic = lib.mkDefault true;
      interval = lib.mkDefault { Hour = 3; Minute = 15; Weekday = 7; };
      options = lib.mkDefault "--delete-older-than 30d";
    };

    # Configure nix-daemon settings
    daemonProcessType = lib.mkDefault "Adaptive";
  };

  # Additional launchd tuning for nix-daemon
  launchd.daemons.nix-daemon.serviceConfig = {
    ProcessType = "Adaptive";
    Nice = -5; # Higher priority
  };
}
