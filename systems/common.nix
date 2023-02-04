# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  #  environment.variables = {
  #    NIXOS_CONFIG = "$HOME/.config/nixos/configuration.nix";
  #    NIXOS_CONFIG_DIR = "$HOME/.config/nixos/";
  #  };

  # Nix settings, auto cleanup and enable flakes
  nix = {
    settings.auto-optimise-store = true;
    gc.automatic = true;
    gc.dates = "weekly";
    package = pkgs.nixUnstable;
    #extraOptions = "experimental-features = nix-command flakes ";
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  # Use the systemd-boot EFI boot loader.
  boot.cleanTmpDir = true;
  boot.loader.grub.device = "/dev/sda";

  # Set your time zone.
  time.timeZone = "Europe/Oslo";
  i18n.defaultLocale = "en_US.UTF-8";
  #console.font = "Lat2-Terminus16";
  console.keyMap = "us";

  #networking.hostName = "nixos"; # Define your hostname.
  #networking.useDHCP = true;
  #  networking.networkmanager.enable = true;

  #  # Open ports in the firewall.
  #  networking.firewall.checkReversePath = "loose";
  #  networking.firewall.allowedTCPPorts = [
  #    8989 # sonar
  #    6789 # nztbget
  #    32400
  #    32469 # plex
  #  ];
  #  networking.firewall.allowedUDPPorts = [
  #    8989
  #    6789
  #    1900
  #    5353
  #    32469
  #    32410
  #    32412
  #    32413
  #    32414 # plex
  #  ];


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    curl
    lf
    htop
    git
    zellij
  ];

  #  programs.gnupg.agent = {
  #    enable = true;
  #    enableSSHSupport = true;
  #  };
  #  programs.steam = {
  #    enable = true;
  #    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  #    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  #  };



  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}
