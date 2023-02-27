{ pkgs, inputs, my-homemanager-modules, ... }:
{
  networking.hostName = "nixos-desktop"; # Define your hostname.
  nixpkgs.config.allowUnfree = true;
  modules.myNvim.enable=true;

  #imports = my-homemanager-modules;

  nixpkgs.overlays = [ inputs.nur.overlay ];
  imports = [
    ../common.nix
    ./hardware-configuration.nix
  ];

  users.users.mar = { system, ... }: {
    isNormalUser = true;
    extraGroups = [
      "docker"
      "networkmanager"
      "wheel" # Enable ‘sudo’ for the user.
      "qemu-libvirtd"
      "libvirtd"
    ];
    shell = pkgs.zsh;
  };

  # Enable home-manager
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.sharedModules = my-homemanager-modules;
  home-manager.users.mar = {
    imports = [{
      modules.zsh.enable = true;
      modules.zellij.enable = true;
      modules.firefox.enable = true;
      modules.autorandr.enable = true;
      modules.bspwm.enable = true;
      modules.dunst.enable = true;
      modules.kitty.enable = true;
      modules.newsboat.enable = true;
      modules.polybar.enable = true;
      modules.xmonad.enable = false;
      modules.spotifyd.enable = false;
      modules.other.enable = true;
      modules.myPackages.enable = true;
      modules.cloneDefaultRepos.enable = true;

      # Do not touch
      home.stateVersion = "21.03";
    }];
  };
}
