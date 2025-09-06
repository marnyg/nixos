# Minimal profile - Just the essentials
{ lib, pkgs, ... }:

{
  # Minimal profile modules
  modules.my = {
    # CORE: Absolute minimum configuration
    sharedDefaults.enable = true; # Basic home-manager settings

    # Everything else is optional and disabled by default
    # These can be enabled by hosts that need them
    git.enable = lib.mkDefault false;
    direnv.enable = lib.mkDefault false;
    tmux.enable = lib.mkDefault false;
    fzf.enable = lib.mkDefault false;
    myPackages.enable = lib.mkDefault false;
    cloneDefaultRepos.enable = lib.mkDefault false;
  };

  # Basic programs
  programs = {
    bash.enable = true;
    vim.enable = true;
  };

  # Minimal packages
  home.packages = with pkgs; [
    # Core utilities
    coreutils
    findutils
    gnugrep
    gnused
    gawk

    # Basic tools
    curl
    wget
    less
    tree
    htop
  ];

  # Basic aliases
  home.shellAliases = {
    ll = "ls -l";
    la = "ls -la";
    ".." = "cd ..";
  };
}
