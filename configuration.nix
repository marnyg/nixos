# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
#  imports =
#   [ # Include the results of the hardware scan.
#      ./hardware-configuration.nix
#    ];

  # Neovim configuration
  #imports = [ ./config/nvim/nvim.nix ];
 


  # Set environment variables
  environment.variables = {
      NIXOS_CONFIG="$HOME/.config/nixos/configuration.nix";
      NIXOS_CONFIG_DIR="$HOME/.config/nixos/";
  }; 

  # Nix settings, auto cleanup and enable flakes
  nix = {
      autoOptimiseStore = true;
      gc = {
          automatic = true;
          dates = "daily";
      };
      package = pkgs.nixUnstable;
      extraOptions = ''
          experimental-features = nix-command flakes
      '';
  };

  # Use the systemd-boot EFI boot loader.
  boot.cleanTmpDir = true;
  #boot.loader.systemd-boot.enable = true;
  boot.loader.grub.device = "/dev/sda";
  #boot.loader.efi.canTouchEfiVariables = true;

  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "Europe/Oslo";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
      font = "Lat2-Terminus16";
      keyMap = "us";
  };

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp2s0.useDHCP = true;
  networking.interfaces.wlp3s0.useDHCP = true;

#tailscale
  services.tailscale.enable = true;
  services.tailscale.port = 12345;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 443 80 
    8989 #sonar
    6789 #nztbget
    32400 32469 #plex
    8384 #syncthing
 ];
  networking.firewall.allowedUDPPorts = [ 22 443 80
     8989 
     6789  
     1900 5353 32469 32410 32412 32413 32414 #plex
     12345
     8384 #syncthing
  ];
  # Or disable the firewall altogether.
  #networking.firewall.enable = false;
  networking.networkmanager.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.displayManager.defaultSession = "none+xmonad";
  services.xserver.windowManager = {       # Open configuration for the window manager.
    #dwm.enable = true;                  # Enable xmonad.
    xmonad.enable = true;                  # Enable xmonad.
    xmonad.enableContribAndExtras = true;  # Enable xmonad contrib and extras.
    xmonad.extraPackages = hpkgs: [        # Open configuration for additional Haskell packages.
      hpkgs.xmonad-contrib                 # Install xmonad-contrib.
      hpkgs.xmonad-extras                  # Install xmonad-extras.
      hpkgs.xmonad                         # Install xmonad itself.
      hpkgs.dbus
      hpkgs.monad-logger
    ];
    xmonad.config = ./config/xmonad/config.hs;                # Enable xmonad.
    #xmonad.config = ./.config/config.hs;                # Enable xmonad.
    #xmonad.config = ./config.hs;                # Enable xmonad.
  };

  # Enable the X11 windowing system.
  services.compton.enable = true;
  services.compton.shadow = true;
  services.compton.inactiveOpacity = 0.8;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;
  services.xserver.layout = "us";
  #services.xserver.xkbOptions = "caps:swapescape";
  services.xserver.autoRepeatDelay = 200;
  services.xserver.autoRepeatInterval = 20;


  services.syncthing = {
    enable = true;
    overrideDevices = true;     # overrides any devices added or deleted through the WebUI
    overrideFolders = true;     # overrides any folders added or deleted through the WebUI
    user = "mar";
    #group   = "wheel";
    dataDir = "/home/mar/";
    devices = {
      "aws" = { id = "GQDUKFK-HQRZYTR-WUDIIAE-MVQOOSY-DALLCEE-DTJMVTZ-DGPKS7P-VVQVKAE";
 };
      "workPc" = { id = "IKII2EG-O2YCQ64-6RI2ADV-VHXWB7P-XKNN4HH-5H3PJG5-B7AV44K-LTWGCQG";
 };
    };
    folders = {
      "nextcloud" = {        # Name of folder in Syncthing, also the folder ID
        path = "/home/mar/mnt/nextcloud";    # Which folder to add to Syncthing
        devices = [ "aws" "workPc" ];      # Which devices to share the folder with
      };
    #  "Example" = {
    #    path = "/home/myusername/Example";
    #    devices = [ "device1" ];
    #    ignorePerms = false;     # By default, Syncthing doesn't sync file permissions. This line enables it for this folder.
    #  };
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mar = {
    isNormalUser = true;
    extraGroups = [ "docker" "networkmanager" "wheel" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
  };
  users.users.vm= {
    isNormalUser = true;
    extraGroups = [ "docker" "networkmanager" "wheel" ]; # Enable ‘sudo’ for the user.
    initialHashedPassword="test";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim #  The Nano editor is also installed by default.
    neovim
    wget
    firefox
    lf
    htop
    git
    kitty
    tmux
    virt-manager
    docker-compose
    tailscale
  ];
  
  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts
    dina-font
    proggyfonts
  ];

  programs.gnupg.agent = {
    enable           = true;
    enableSSHSupport = true;
  };
 

  #nixpkgs.config.allowUnfree = true; 

  virtualisation = {
    docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };

    #virtualbox.host = {
    #  enable = true;
    #  enableExtensionPack = true;
    #};
  };

 #VM??????????????????????????//
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}

