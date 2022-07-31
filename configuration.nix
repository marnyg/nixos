# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  environment.variables = {
    NIXOS_CONFIG = "$HOME/.config/nixos/configuration.nix";
    NIXOS_CONFIG_DIR = "$HOME/.config/nixos/";
  };

  # Nix settings, auto cleanup and enable flakes
  nix = {
    autoOptimiseStore = true;
    gc = {
      automatic = true;
      dates = "weekly";
    };
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Use the systemd-boot EFI boot loader.
  boot.cleanTmpDir = true;
  boot.loader.grub.device = "/dev/sda";


  # Set your time zone.
  time.timeZone = "Europe/Oslo";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  networking.hostName = "nixos"; # Define your hostname.
  networking.useDHCP = false;
  networking.interfaces.enp2s0.useDHCP = false;
  networking.interfaces.wlp3s0.useDHCP = false;


  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22
    443
    80
    8989 #sonar
    6789 #nztbget
    32400
    32469 #plex
  ];
  networking.firewall.allowedUDPPorts = [
    22
    443
    80
    8989
    6789
    1900
    5353
    32469
    32410
    32412
    32413
    32414 #plex
  ];

  networking.networkmanager.enable = true;

  #=====
  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    #autorun = false;
    layout = "us";
    displayManager.defaultSession = "none+bspwm";
    #  windowManager.default = "bspwm";

    windowManager.bspwm = {
      enable = true;



      # configFile = "/etc/nixos/config/homemanager/programs/bspwm/bspwmrc";
      # sxhkd.configFile = "/etc/nixos/config/homemanager/programs/bspwm/sxhkdrc";

      #  configFile =  "~/.config/bspwm/bspwmrc";
      #  configFile = "${pkgs.bspwm}/share/doc/bspwm/examples/bspwmrc" #example
      #  sxhkd.configFile =  "~/.config/bspwm/sxhkdrc";
      #  configFile =  "/home/vm/nixos/config/bspwm/bspwmrc";
      #  sxhkd.configFile =  "/home/vm/nixos/config/sxhkd/sxhkdrc";
    };

    #=====

    #  windowManager.dwm.enable = true;                  # Enable xmonad.

    # windowManager.xmonad = {
    #   enable = true;                  # Enable xmonad.
    #   enableContribAndExtras = true;  # Enable xmonad contrib and extras.
    #   extraPackages = hpkgs: [        # Open configuration for additional Haskell packages.
    # hpkgs.xmonad-contrib                 # Install xmonad-contrib.
    #     hpkgs.xmonad-extras                  # Install xmonad-extras.
    #     hpkgs.xmonad                         # Install xmonad itself.
    #     hpkgs.dbus
    #     hpkgs.monad-logger
    #   ];
    #   config = ./config/xmonad/config.hs;                # Enable xmonad.
    # };
  };
  #services.xserver.windowManager = {       # Open configuration for the window manager.
  #  #dwm.enable = true;                  # Enable xmonad.
  #  xmonad.enable = true;                  # Enable xmonad.
  #  xmonad.enableContribAndExtras = true;  # Enable xmonad contrib and extras.
  #  xmonad.extraPackages = hpkgs: [        # Open configuration for additional Haskell packages.
  #    hpkgs.xmonad-contrib                 # Install xmonad-contrib.
  #    hpkgs.xmonad-extras                  # Install xmonad-extras.
  #    hpkgs.xmonad                         # Install xmonad itself.
  #    hpkgs.dbus
  #    hpkgs.monad-logger
  #  ];
  #  xmonad.config = ./config/xmonad/config.hs;                # Enable xmonad.
  #  #xmonad.config = ./.config/config.hs;                # Enable xmonad.
  #  #xmonad.config = ./config.hs;                # Enable xmonad.
  #};

  # Enable the X11 windowing system.
  services.compton.enable = true;
  services.compton.shadow = true;
  services.compton.inactiveOpacity = 0.8;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;
  #services.xserver.xkbOptions = "caps:swapescape";
  services.xserver.autoRepeatDelay = 200;
  services.xserver.autoRepeatInterval = 20;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.mar = {
  #   isNormalUser = true;
  #   extraGroups = [ "docker" "networkmanager" "wheel" "qemu-libvirtd" "libvirtd" ]; # Enable ‘sudo’ for the user.
  #   shell = pkgs.zsh;
  # };
  users.users.vm = {
    isNormalUser = true;
    extraGroups = [ "docker" "networkmanager" "wheel" ]; # Enable ‘sudo’ for the user.
    initialHashedPassword = "HNTH57eGshHyQ"; #test 8
    # initialPassword="test";
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
    sxhkd
    vagrant
    packer
    (
      writers.writeDashBin "vboxmanage" ''
        ${pkgs.virtualbox}/bin/VBoxManage "$@"
      ''
    )
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
    enable = true;
    enableSSHSupport = true;
  };


  nixpkgs.config.allowUnfree = true;

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
  # virtualisation.qemu.options = [
  #         "-virtfs local,path=,security_model=none,mount_tag=${mount_tag}"
  #     ];
  programs.dconf.enable = true;

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
