# Nix performance improvements for macOS users
{ lib, pkgs, ... }:
{
  # Shell aliases for common Nix operations with performance flags
  programs.fish.shellAliases = lib.mkIf pkgs.stdenv.isDarwin {
    # Always use fallback on Darwin
    nix-build = "nix-build --fallback";
    nix-shell = "nix-shell --fallback";

    # Flake commands with optimizations
    nix-develop = "nix develop --fallback";
    nix-build-flake = "nix build --fallback --log-format bar-with-logs";

    # Faster evaluation
    nix-eval = "nix eval --show-trace";

    # Update with better output
    nix-update = "nix flake update --log-format bar-with-logs";

    # Check with fallback
    nix-check = "nix flake check --fallback --log-format bar-with-logs";
  };

  # Environment variables for better Nix performance
  home.sessionVariables = lib.mkIf pkgs.stdenv.isDarwin {
    # Use parallel downloads
    NIX_CURL_FLAGS = "-C - --parallel --parallel-max 10";

    # Increase build verbosity for debugging slow builds
    NIX_BUILD_HOOK_VERBOSITY = "1";
  };

  # Direnv optimization for Nix
  programs.direnv = lib.mkIf pkgs.stdenv.isDarwin {
    enable = lib.mkDefault true;
    nix-direnv.enable = lib.mkDefault true;

    # Cache direnv evaluations longer
    config = {
      global = {
        warn_timeout = "30s";
        hide_env_diff = true;
      };
    };
  };
}
