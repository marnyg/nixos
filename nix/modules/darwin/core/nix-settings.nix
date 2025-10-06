# Optimized Nix configuration for Darwin systems
# Provides configurable performance settings for macOS
{ pkgs, lib, config, ... }:

let
  cfg = config.modules.darwin.nixSettings;
in
{
  options.modules.darwin.nixSettings = {
    enable = lib.mkEnableOption "optimized Nix settings for Darwin";

    experimentalFeatures = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "nix-command" "flakes" ];
      description = "Experimental Nix features to enable";
    };

    trustedUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "@admin" ];
      description = "Users allowed to use Nix";
    };

    maxJobs = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
      description = "Maximum number of parallel build jobs (null for auto)";
    };

    buildCores = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
      description = "Number of CPU cores to use per build job (null for all)";
    };

    substituters = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
      ];
      description = "Binary cache substituters";
    };

    optimizations = {
      autoOptimiseStore = lib.mkOption {
        type = lib.types.bool;
        default = false; # Disabled by default on APFS
        description = "Automatically optimize the Nix store (slow on APFS)";
      };

      gcAutomatic = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable automatic garbage collection";
      };

      gcInterval = lib.mkOption {
        type = lib.types.str;
        default = "weekly";
        description = "When to run automatic garbage collection";
      };

      gcDeleteOlderThan = lib.mkOption {
        type = lib.types.str;
        default = "30d";
        description = "Delete generations older than this";
      };
    };

    performance = {
      httpConnections = lib.mkOption {
        type = lib.types.int;
        default = 128;
        description = "Maximum parallel HTTP connections";
      };

      downloadBufferSize = lib.mkOption {
        type = lib.types.int;
        default = 268435456; # 256MB
        description = "Download buffer size in bytes";
      };

      daemonNiceness = lib.mkOption {
        type = lib.types.int;
        default = -5;
        description = "Nix daemon process priority (-20 to 19)";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    nix = {

      settings = {
        # Binary caches
        substituters = cfg.substituters;
        trusted-public-keys = lib.mkDefault [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];

        # Trust settings
        trusted-users = cfg.trustedUsers;

        # Performance tuning
        max-jobs = if cfg.maxJobs != null then cfg.maxJobs else "auto";
        #cores = if cfg.buildCores != null then cfg.buildCores else 0;

        # Network performance
        http-connections = cfg.performance.httpConnections;
        connect-timeout = lib.mkDefault 5;

        # Store optimization
        auto-optimise-store = cfg.optimizations.autoOptimiseStore;

        # Enable experimental features
        experimental-features = cfg.experimentalFeatures;

        # Don't fallback automatically
        fallback = lib.mkDefault false;

        # Keep build logs for debugging
        keep-build-log = lib.mkDefault true;

        # Sandbox settings
        sandbox = lib.mkDefault true;

        # Build timeouts
        max-silent-time = lib.mkDefault 7200;
        timeout = lib.mkDefault 0;
      };

      # Extra options for performance
      extraOptions = ''
        # Download buffer size
        download-buffer-size = ${toString cfg.performance.downloadBufferSize}
        
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
        
        # Flake settings
        accept-flake-config = true
        
        # GC settings
        gc-keep-outputs = false
        gc-keep-derivations = false
        
        # Warn about dirty git trees but don't fail
        warn-dirty = true
        
        # Use xz compression for better cache efficiency
        compress-build-log = true
      '';

      # Garbage collection
      gc = lib.mkIf (cfg.optimizations.gcAutomatic && config.nix.enable) {
        automatic = true;
        interval = lib.mkDefault {
          Hour = 3;
          Minute = 15;
          Weekday = if cfg.optimizations.gcInterval == "weekly" then 7 else 0;
        };
        options = "--delete-older-than ${cfg.optimizations.gcDeleteOlderThan}";
      };

      # Configure nix-daemon settings
      daemonProcessType = lib.mkDefault "Adaptive";
    };

    # Additional launchd tuning for nix-daemon
    launchd.daemons.nix-daemon.serviceConfig = {
      ProcessType = "Adaptive";
      Nice = cfg.performance.daemonNiceness;
    };
  };
}
