{ inputs, config, pkgs, ... }:
let
  # Define a more modular home-manager configuration
  defaultHMConfig = {
    # Import all home modules to ensure dependencies are available
    imports = [
      inputs.agenix.homeManagerModules.default
      ../../home-modules/mcphub.nix
      ../../home-modules/fish.nix
      ../../home-modules/git.nix
      ../../home-modules/hyperland.nix
      ../../home-modules/waybar.nix
      ../../home-modules/direnv.nix
      ../../home-modules/sharedShellConfig.nix
      ../../home-modules/wofi.nix
      ../../home-modules/ghostty.nix
      ../../home-modules/lf.nix
      ../../home-modules/myPackages.nix
      ../../home-modules/nvim.nix
      ../../home-modules/nixvim.nix
      ../../home-modules/tmux.nix
      ../../home-modules/fzf.nix
      ../../home-modules/zsh.nix
      ../../home-modules/secrets/secretsModule.nix
    ];

    # Enable the imported modules
    modules = {
      mcpServer.enable = true;
      fish.enable = true;
      git.enable = true;
      hyperland.enable = true;
      waybar.enable = true;
      direnv.enable = true;
      sharedShellConfig.enable = true;
      wofi.enable = true;
      ghostty.enable = true;
      secrets.enable = true;
    };

    # Add any desktop-specific packages
    home.packages = with pkgs; [
      firefox
      neovim
    ];

    # Required state version
    home.stateVersion = "22.11";
  };
in
{
  imports = [
    ./hardware-config.nix
    ../common.nix
  ];

  ##
  ## NVIDIA gpu config
  ##
  # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    open = true;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  ##
  ## system modules config
  ##
  home-manager.backupFileExtension = "hm-backup";
  # Nixvim is now managed per-user via Home Manager
  myModules.wsl.enable = false;
  myModules.defaults.enable = true;
  nix.channel.enable = false;
  # Additional nix settings (common.nix provides base settings)
  nix.settings.trusted-users = [ "root" "mar" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" "pipe-operators" ];

  ## 
  ## users and homemanager modules config
  ## 
  myModules.createUsers = {
    enable = true;
    users = [
      # TODO: move this out into own users file
      { name = "mar"; homeManager = true; homeManagerConf = defaultHMConfig; }
      { name = "test"; homeManager = true; homeManagerConf = defaultHMConfig; }
      { name = "notHM"; homeManager = false; }
    ];
  };

  ## 
  ## OTHER STUFF
  ## 
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Time zone and locale are set in common.nix
  networking.networkmanager.enable = true;
  users.users.mar.extraGroups = [ "docker" "networkmanager" ];

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;

  programs.hyprland.enable = true;
  programs.sway.enable = true;
  services.greetd = {
    enable = true;
    settings.default_session.command = ''
      ${pkgs.greetd.tuigreet}/bin/tuigreet --time --asterisks --user-menu --cmd Hyprland
    '';
  };
  environment.etc."greetd/environments".text = ''
    Hyprland
    sway
  '';

  # Audio configuration
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  services.pipewire.wireplumber.enable = true;

  # For Hyprland
  xdg.portal = { enable = true; extraPortals = [ pkgs.xdg-desktop-portal-gtk ]; };
  security.polkit.enable = true;

  # X11 configuration
  services.xserver.xkb.layout = "us";
  services.xserver.xkb.options = "caps:escare";
  console.useXkbConfig = true;
  services.xserver.autoRepeatDelay = 200;
  services.xserver.autoRepeatInterval = 20;
  environment.systemPackages = with pkgs; [
    inputs.agenix.packages.x86_64-linux.default
    hyprland
    waybar
    git
    tmux
    bottom
    slack
    prusa-slicer
    starship
    atuin
  ];

  # Enable Wayland support for Slack
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

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

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  virtualisation = {
    containerd.enable = true;
    podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enable = true;
  services.tailscale.enable = true;

  programs.dconf.enable = true;
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

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
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [ ];
  system.autoUpgrade.enable = true;
  system.autoUpgrade.flake = "github:marnyg/nixos#desktop";
}
