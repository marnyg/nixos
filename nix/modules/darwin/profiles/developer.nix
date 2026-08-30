# Developer Darwin profile
# Development tools and configuration for macOS
{ lib, pkgs, ... }:
{
  imports = [ ./base.nix ];

  # Developer-focused modules
  modules.darwin = {
    # Optimize Nix for development
    nixSettings = {
      experimentalFeatures = [ "nix-command" "flakes" ];
      performance = {
        httpConnections = lib.mkDefault 256; # More parallel downloads
        downloadBufferSize = lib.mkDefault 536870912; # 512MB buffer
      };
    };
  };

  # Development packages
  environment.systemPackages = with pkgs; [
    # Version control
    git
    git-lfs
    gh

    # Build tools
    gnumake
    cmake
    pkg-config

    # Language servers and tools
    nil # Nix LSP
    nixpkgs-fmt
    statix

    # Debugging and analysis
    lldb
    htop
    lsof

    # Networking tools
    curl
    wget
    nmap
    mtr

    # File tools
    ripgrep
    fd
    bat
    eza
    tree
    jq
    yq

    # Development utilities
    direnv
    tmux
    neovim
    #claude-code
    devenv
    uv
    natscli
  ];

  # Enable developer shells
  programs.fish.enable = lib.mkDefault true;

  # Environment variables for development
  environment.variables = {
    EDITOR = lib.mkForce "nvim";
    VISUAL = lib.mkForce "nvim";
    PAGER = lib.mkForce "less -R";
  };
}
