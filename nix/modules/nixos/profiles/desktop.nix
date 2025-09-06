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

  # Core modules
  modules.my = {
    defaults.enable = true;
    secrets.enable = true;
    nixSettings.enable = true;
  };

  # Hardware profiles for desktop
  hardware.profiles = {
    audio = {
      enable = lib.mkDefault true;
      backend = lib.mkDefault "pipewire";
      support32Bit = lib.mkDefault true;
    };

    bluetooth = {
      enable = lib.mkDefault true;
      powerOnBoot = lib.mkDefault true;
    };
  };

  # Boot configuration (common for desktops)
  boot.loader = {
    systemd-boot.enable = lib.mkDefault true;
    efi.canTouchEfiVariables = lib.mkDefault true;
  };

  # Graphics drivers (base configuration, NVIDIA is optional)
  hardware.graphics = {
    enable = lib.mkDefault true;
    enable32Bit = lib.mkDefault true;
  };

  # X server configuration
  services.xserver = {
    enable = lib.mkDefault true;
    xkb = {
      layout = lib.mkDefault "us";
      options = lib.mkDefault "caps:escape";
    };
    autoRepeatDelay = lib.mkDefault 200;
    autoRepeatInterval = lib.mkDefault 20;
  };

  # Console configuration
  console.useXkbConfig = lib.mkDefault true;

  # Display manager - greetd with TUI greeter
  services.greetd = {
    enable = lib.mkDefault true;
    settings.default_session.command = lib.mkDefault ''
      ${pkgs.tuigreet}/bin/tuigreet --time --asterisks --user-menu --cmd Hyprland
    '';
  };

  environment.etc."greetd/environments".text = lib.mkDefault ''
    Hyprland
    sway
  '';

  # Window managers (can be overridden by hosts)
  programs.hyprland.enable = lib.mkDefault true;
  programs.sway.enable = lib.mkDefault true;

  # XDG portals for Wayland
  xdg.portal = {
    enable = lib.mkDefault true;
    extraPortals = lib.mkDefault [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Security
  security.polkit.enable = lib.mkDefault true;

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

  # Network manager for GUI
  networking.networkmanager.enable = lib.mkDefault true;

  # Common services
  services.openssh.enable = lib.mkDefault true;
  services.tailscale.enable = lib.mkDefault true;

  # Time zone and locale (can be overridden)
  time.timeZone = lib.mkDefault "Europe/Oslo";
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

  # Virtualization support
  virtualisation = {
    docker.enable = lib.mkDefault true;
    libvirtd.enable = lib.mkDefault true;
    containerd.enable = lib.mkDefault true;
    podman = {
      enable = lib.mkDefault true;
      defaultNetwork.settings.dns_enabled = lib.mkDefault true;
    };
  };

  # Common programs
  programs = {
    gnupg.agent = {
      enable = lib.mkDefault true;
      enableSSHSupport = lib.mkDefault true;
    };
    dconf.enable = lib.mkDefault true;
    nix-ld = {
      enable = lib.mkDefault true;
      libraries = lib.mkDefault (with pkgs; [ ]);
    };
  };

  # Fonts
  fonts.packages = lib.mkDefault (with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    dina-font
    proggyfonts
  ]);

  # Common desktop packages
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
  environment.sessionVariables.NIXOS_OZONE_WL = lib.mkDefault "1";

  # Home Manager backup extension
  home-manager.backupFileExtension = lib.mkDefault "backup";

  # Printing support
  services.printing.enable = lib.mkDefault true;
  services.avahi = {
    enable = lib.mkDefault true;
    nssmdns4 = lib.mkDefault true;
  };

  # Power management
  services.upower.enable = lib.mkDefault true;
}
