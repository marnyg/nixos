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
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 443 80 ];
  networking.firewall.allowedUDPPorts = [ 22 443 80 ];
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
    ];
  #  xmonad.config = ./.config/config.hs;                # Enable xmonad.
  };


  # Enable CUPS to print documents.
  #services.printing.enable = true;

  # Enable sound.
  #sound.enable = true;
  #hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "caps:swapescape";
  services.xserver.autoRepeatDelay = 200;
  services.xserver.autoRepeatInterval = 20;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mar = {
    isNormalUser = true;
    extraGroups = [ "docker" "networkmanager" "wheel" ]; # Enable ‘sudo’ for the user.
  };
  users.users.vm= {
    isNormalUser = true;
    extraGroups = [ "docker" "networkmanager" "wheel" ]; # Enable ‘sudo’ for the user.
    initialHashedPassword="test";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #vim #  The Nano editor is also installed by default.
    neovim
    wget
    firefox
    lf
    htop
    git
    kitty
    tmux
  ];
  
  fonts.fonts = with pkgs; [
    #noto-fonts
    #noto-fonts-cjk
    #noto-fonts-emoji
    #liberation_ttf
    #fira-code
    #fira-code-symbols
    #mplus-outline-fonts
    #dina-font
    #proggyfonts
  ];

  programs.gnupg.agent = {
    enable           = true;
    enableSSHSupport = true;
  };
 

  nixpkgs.config.allowUnfree = true; 

 # virtualisation = {
 #   docker = {
 #     enable = true;
 #     autoPrune = {
 #       enable = true;
 #       dates = "weekly";
 #     };
 #   };

 #   virtualbox.host = {
 #     enable = true;
 #     enableExtensionPack = true;
 #   };
 # };

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

