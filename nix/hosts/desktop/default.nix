# Desktop host configuration
{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/nixos/profiles/desktop.nix
  ];

  system.stateVersion = "23.11";

  # Desktop-specific: Enable NVIDIA GPU
  hardware.profiles.nvidia = {
    enable = true;
    driver = "stable";
    powerManagement = {
      enable = false; # Can cause issues with desktop GPUs
      finegrained = false; # Not needed for desktop
    };
  };

  # Desktop-specific packages
  environment.systemPackages = with pkgs; [
    slack
    prusa-slicer
  ];

  # Auto-upgrade configuration specific to this host
  system.autoUpgrade = {
    enable = true;
    flake = "github:marnyg/nixos#desktop";
  };

  # Gaming support (desktop-specific)
  programs.steam.enable = true;

  # User configuration
  my.users.mar = {
    enable = true;
    enableHome = true;
    profiles = [ "developer" "desktop" ];

    extraHomeModules = [
      {
        programs.ncspot.enable = true;

        # Module overrides specific to this host
        modules.my.sharedDefaults.enable = true;
        modules.my.nixvim.enable = true;
        modules.my.git.enable = true;
        modules.my.fish.enable = true;
        modules.my.direnv.enable = true;
        modules.my.zellij.enable = false;
        modules.my.tmux.enable = true;
        modules.my.firefox.enable = true;
        modules.my.qutebrowser.enable = true;
        modules.my.autorandr.enable = false;
        modules.my.bspwm.enable = true;
        modules.my.xmonad.enable = false;
        modules.my.hyprland.enable = true;
        modules.my.dunst.enable = false;
        modules.my.polybar.enable = false;
        modules.my.kitty.enable = false;
        modules.my.ghostty.enable = true;
        modules.my.newsboat.enable = false;
        modules.my.spotifyd.enable = false;
        modules.my.other.enable = false;
        modules.my.myPackages.enable = true;
        modules.my.cloneDefaultRepos.enable = true;

        programs.yazi.enable = true;
      }
    ];
  };
}
