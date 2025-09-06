# Desktop system profile
# Contains common settings for desktop systems
{ lib, pkgs, inputs, ... }:

{
  imports = [
    # Import hardware profiles
    ../hardware/audio.nix
    ../hardware/bluetooth.nix
    ../hardware/nvidia.nix
  ];

  # Core modules - these define what a desktop system IS
  modules.my = {
    defaults.enable = true;
    secrets.enable = true;
    nixSettings.enable = true;
  };

  # Hardware profiles for desktop
  hardware.profiles = {
    # Audio is essential for desktop
    audio = {
      enable = true;
      backend = lib.mkDefault "pipewire"; # Pipewire is sensible default but can be changed
      support32Bit = lib.mkDefault true; # Gaming support, but can be disabled
    };

    # Bluetooth is expected on modern desktops but can be disabled
    bluetooth = {
      enable = lib.mkDefault true;
      powerOnBoot = lib.mkDefault true;
    };
  };

  # CORE: Essential desktop configuration

  # Boot configuration (UEFI is standard for modern desktops)
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Graphics are essential for desktop
  hardware.graphics = {
    enable = true;
    enable32Bit = lib.mkDefault true; # For compatibility, but can be disabled
  };

  # X server is essential for desktop (even for Wayland compatibility)
  services.xserver = {
    enable = true;
    xkb = {
      layout = lib.mkDefault "us";
      options = lib.mkDefault "caps:escape";
    };
    autoRepeatDelay = lib.mkDefault 200;
    autoRepeatInterval = lib.mkDefault 20;
  };

  # Console should use X keyboard config
  console.useXkbConfig = true;

  # Display manager - essential for desktop
  services.greetd = {
    enable = true;
    settings.default_session.command = lib.mkDefault ''
      ${pkgs.tuigreet}/bin/tuigreet --time --asterisks --user-menu --cmd Hyprland
    '';
  };

  environment.etc."greetd/environments".text = lib.mkDefault ''
    Hyprland
    sway
  '';

  # Window managers - at least one needed, but choice is flexible
  programs.hyprland.enable = lib.mkDefault true;
  programs.sway.enable = lib.mkDefault true;

  # XDG portals for Wayland - essential for modern desktop
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Security - essential for desktop
  security.polkit.enable = true;

  # Systemd service for polkit authentication
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
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

  # Network manager - essential for desktop GUI network management
  networking.networkmanager.enable = true;

  # OPTIONAL: Common services that are helpful but not essential
  services.openssh.enable = lib.mkDefault true;
  services.tailscale.enable = lib.mkDefault true;

  # Locale settings - sensible defaults
  time.timeZone = lib.mkDefault "Europe/Oslo";
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

  # Virtualization - helpful for developers but not essential
  virtualisation = {
    docker.enable = lib.mkDefault true;
    libvirtd.enable = lib.mkDefault true;
    containerd.enable = lib.mkDefault true;
    podman = {
      enable = lib.mkDefault true;
      defaultNetwork.settings.dns_enabled = lib.mkDefault true;
    };
  };

  # Common programs - mix of essential and optional
  programs = {
    gnupg.agent = {
      enable = true; # Security is essential
      enableSSHSupport = lib.mkDefault true;
    };
    dconf.enable = true; # Essential for GTK apps
    nix-ld = {
      enable = lib.mkDefault true;
      libraries = lib.mkDefault (with pkgs; [ ]);
    };
  };

  # Fonts - essential for desktop
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

  # Common desktop packages - essential GUI tools
  environment.systemPackages = with pkgs; [
    git
    tmux
    bottom
    hyprland
    firefox
    pavucontrol
    networkmanagerapplet
  ] ++ lib.optionals (inputs ? agenix) [
    inputs.agenix.packages.x86_64-linux.default
  ];

  # Enable Wayland support for Electron apps
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Home Manager settings
  home-manager.backupFileExtension = lib.mkDefault "backup";

  # Printing support - optional but commonly needed
  services.printing.enable = lib.mkDefault true;
  services.avahi = {
    enable = lib.mkDefault true;
    nssmdns4 = lib.mkDefault true;
  };

  # Power management - essential for desktop
  services.upower.enable = true;
}
