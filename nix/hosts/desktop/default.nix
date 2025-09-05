# Desktop host configuration
{ inputs, config, pkgs, ... }:

{
  imports = [
    # Hardware configuration
    ./hardware.nix

    # System profiles
    ../../modules/nixos/profiles/desktop.nix

    # Core modules
    ../../modules/nixos/core/defaults.nix
    ../../modules/nixos/core/users.nix
    ../../modules/nixos/core/secrets.nix
    ../../modules/nixos/core/nix-settings.nix

    # Services
    ../../modules/nixos/services/tailscale.nix
    ../../modules/nixos/services/syncthing.nix

    # Input modules
    inputs.agenix.nixosModules.age
  ];

  # Boot configuration
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # System configuration
  system.stateVersion = "23.11";

  # Enable modules
  myModules = {
    defaults.enable = true;
    secrets.enable = true;
    nixSettings.enable = true;
  };

  # NVIDIA GPU configuration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Desktop-specific services
  services = {
    # Display manager - using greetd like before
    greetd = {
      enable = true;
      settings.default_session.command = ''
        ${pkgs.greetd.tuigreet}/bin/tuigreet --time --asterisks --user-menu --cmd Hyprland
      '';
    };

    # X server configuration
    xserver = {
      enable = true;
      xkb = {
        layout = "us";
        options = "caps:escape";
      };
      autoRepeatDelay = 200;
      autoRepeatInterval = 20;
    };

    # Audio
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    # Bluetooth
    blueman.enable = true;

    # SSH
    openssh.enable = true;

    # Tailscale
    tailscale.enable = true;
  };

  # Window managers and desktop environment
  programs.hyprland.enable = true;
  programs.sway.enable = true;

  environment.etc."greetd/environments".text = ''
    Hyprland
    sway
  '';

  # Console configuration
  console.useXkbConfig = true;

  # XDG portals for Wayland
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Security
  security.rtkit.enable = true;
  security.polkit.enable = true;

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Networking
  networking.networkmanager.enable = true;

  # Time zone
  time.timeZone = "Europe/Oslo";
  i18n.defaultLocale = "en_US.UTF-8";

  # Virtualization
  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
    containerd.enable = true;
    podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Programs
  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    dconf.enable = true;
    nix-ld = {
      enable = true;
      libraries = with pkgs; [ ];
    };
  };

  # System packages
  environment.systemPackages = with pkgs; [
    inputs.agenix.packages.x86_64-linux.default
    hyprland
    git
    tmux
    bottom
    slack
    prusa-slicer
  ];

  # Enable Wayland support for Slack
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    dina-font
    proggyfonts
  ];

  # Systemd service for polkit authentication
  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  # Auto-upgrade
  system.autoUpgrade = {
    enable = true;
    flake = "github:marnyg/nixos#desktop";
  };

  # Gaming support
  programs.steam.enable = true;

  # User configuration
  home-manager.backupFileExtension = "backup";

  # User configurations using the new my.users system
  my.users = {
    mar = {
      enable = true;
      enableHome = true;
      profiles = [ "developer" "desktop" ];
      extraHomeModules = [
        {
          programs.ncspot.enable = true;

          modules.sharedDefaults.enable = true;
          modules.nixvim.enable = true;
          modules.git.enable = true;

          modules.fish.enable = true;
          modules.direnv.enable = true;
          modules.zellij.enable = false;
          modules.tmux.enable = true;
          modules.firefox.enable = true;
          modules.autorandr.enable = false;
          modules.bspwm.enable = true;
          modules.dunst.enable = false;
          modules.kitty.enable = false;
          modules.ghostty.enable = true;
          modules.newsboat.enable = false;
          modules.polybar.enable = false;
          modules.xmonad.enable = false;
          modules.hyperland.enable = true;
          modules.spotifyd.enable = false;
          modules.other.enable = false;
          modules.myPackages.enable = true;
          modules.cloneDefaultRepos.enable = true;
          modules.qutebrowser.enable = true;
          programs.yazi.enable = true;
        }
      ];
    };
  };
}
