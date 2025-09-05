# Desktop host configuration
{ config, pkgs, ... }:

{
  imports = [
    # Hardware configuration is still local
    ./hardware.nix
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
  # Required for NVIDIA graphics cards - adjust based on your GPU
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Support for 32-bit applications (Steam, Wine)
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true; # Required for Wayland compositors
    powerManagement.enable = false; # Can cause issues with some GPUs
    powerManagement.finegrained = false; # Disable for desktop systems
    open = true; # Use open-source kernel modules where possible
    nvidiaSettings = true; # GUI for NVIDIA settings
    package = config.boot.kernelPackages.nvidiaPackages.stable; # Use stable driver
  };

  # Desktop-specific services
  services = {
    # Display manager - greetd with TUI greeter
    # This provides a minimal, fast login screen that launches directly into Hyprland
    greetd = {
      enable = true;
      settings.default_session.command = ''
        ${pkgs.tuigreet}/bin/tuigreet --time --asterisks --user-menu --cmd Hyprland
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
      profiles = [ "developer" "desktop" ]; # Load both developer tools and desktop apps

      # Fine-tune module selection beyond what profiles provide
      # This allows overriding profile defaults or adding specific modules
      extraHomeModules = [
        {
          programs.ncspot.enable = true; # Terminal Spotify client

          # Core modules
          modules.sharedDefaults.enable = true; # Common defaults for all environments
          modules.nixvim.enable = true; # Neovim distribution
          modules.git.enable = true; # Git configuration

          # Shell and terminal
          modules.fish.enable = true; # Fish shell
          modules.direnv.enable = true; # Auto-load project environments
          modules.zellij.enable = false; # Terminal multiplexer (alternative to tmux)
          modules.tmux.enable = true; # Terminal multiplexer

          # Browsers
          modules.firefox.enable = true; # Primary browser
          modules.qutebrowser.enable = true; # Keyboard-driven browser

          # Window managers and desktop
          modules.autorandr.enable = false; # Auto display configuration (X11)
          modules.bspwm.enable = true; # Tiling WM (X11)
          modules.xmonad.enable = false; # Tiling WM (X11, Haskell)
          modules.hyprland.enable = true; # Wayland compositor

          # Desktop utilities
          modules.dunst.enable = false; # Notification daemon (X11)
          modules.polybar.enable = false; # Status bar (X11)

          # Terminal emulators
          modules.kitty.enable = false; # GPU-accelerated terminal
          modules.ghostty.enable = true; # Modern terminal emulator

          # Other services
          modules.newsboat.enable = false; # RSS reader
          modules.spotifyd.enable = false; # Spotify daemon
          modules.other.enable = false; # Miscellaneous configurations
          modules.myPackages.enable = true; # Custom package collection
          modules.cloneDefaultRepos.enable = true; # Clone standard repos on first login

          programs.yazi.enable = true; # Terminal file manager
        }
      ];
    };
  };
}
