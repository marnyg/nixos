# Home-manager profile for macOS systems
{ pkgs, lib, ... }:
{
  # macOS-specific module configurations
  modules.my = {
    # Disable Linux-specific modules
    sharedDefaults.enable = false;
    cloneDefaultRepos.enable = lib.mkDefault false;

    # Enable macOS-compatible programs
    firefox.enable = lib.mkDefault true;
    kitty.enable = lib.mkDefault false; # Disabled - build fails on Darwin, using Ghostty instead
    ghostty.enable = lib.mkDefault true;
    ghostty.fontsize = lib.mkDefault 14;
    spotifyd.enable = lib.mkDefault true;

    # Development tools (with performance optimizations)
    direnv.enable = lib.mkDefault true; # nix-direnv caches flake evaluations
    git.enable = lib.mkDefault true;
    tmux.enable = lib.mkDefault true;
    fish.enable = lib.mkDefault true;
    fzf.enable = lib.mkDefault true;
  };

  # macOS-specific programs
  programs = {
    ncspot.enable = lib.mkDefault true;
    htop.enable = lib.mkDefault true;
    htop.settings.show_program_path = lib.mkDefault true;
    yazi.enable = lib.mkDefault true;

    direnv = {
      enable = lib.mkDefault true;
      nix-direnv.enable = lib.mkDefault true;
    };
  };

  # macOS-specific packages
  home.packages = with pkgs; [
    # Core utilities
    coreutils
    curl
    wget
    jq
    ripgrep
    fd
    bat
    eza

    # Communication tools (if available on Darwin)
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    # Darwin-only packages
    mas # Mac App Store CLI
  ] ++ lib.optionals (pkgs.stdenv.isLinux) [
    # Linux-only packages (won't be included on Darwin)
    slack
    teams-for-linux
  ];

  # Environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
