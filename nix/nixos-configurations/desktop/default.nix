{ inputs, config, pkgs, ... }:
let
  #TODO:move this out into own users file
  defaultHMConfig = {
    imports = [ inputs.agenix.homeManagerModules.default ];
    programs.ncspot.enable = true;

    myHmModules.sharedDefaults.enable = true;


    # myServices.s3fs.enable = true;
    # myServices.s3fs.keyId = "tid_hDRNQPQfftgkNfOasaoExtxIaBq_jkLiWvimSMZzaNhtCdtEmF";
    # myServices.s3fs.accessKey = "tsec_PC4Z9WtxGiVwRGPDPBZhlTqfYHW3tbKo38PZ6izsDCKHVH-wAWskx7QkSs_zgXM8BWGVep";

    #modules.zsh.enable = true;
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
    myModules.git.enable = true;
    modules.newsboat.enable = false;
    modules.polybar.enable = false;
    modules.xmonad.enable = false;
    modules.hyperland.enable = true;
    modules.spotifyd.enable = false;
    modules.other.enable = false;
    modules.myPackages.enable = true;
    modules.cloneDefaultRepos.enable = true;
    modules.qutebrowser.enable = true;
    # modules.lf.enable = true;
    programs.yazi.enable = true;
    myModules.secrets.enable = true;
  };
in
{
  imports = [ ./hardware-config.nix ];

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
  # services.xserver.videoDrivers = [ "nvidia" ];

  # This is crucial for modern GPUs and for Wayland support
  # hardware.nvidia.modesetting.enable = true;
  # hardware.nvidia.optimus.enable = true;

  # For power management, recommended for desktops and essential for laptops
  # hardware.nvidia.powerManagement.enable = true;
  # For finer-grained power management on recent GPUs (Turing architecture and newer)
  # You can leave this on for older cards too, it will just be ignored.
  #hardware.nvidia.powerManagement.finegrained = true;

  # Use the proprietary (closed-source) driver.
  # Set to true to use the open-source "open-gpu-kernel-modules"
  # hardware.nvidia.open = false;

  # Enable OpenGL
  # hardware.opengl.enable = true;
  # hardware.opengl.driSupport = true;
  # hardware.opengl.driSupport32Bit = true; # For 32-bit games/apps


  ##
  ## system modules config
  ##
  home-manager.backupFileExtension = "backup";
  myModules.myNixvim.enable = true; # TODO: should be managed by homemanger
  myModules.wsl.enable = false;
  myModules.defaults.enable = true;
  nix.channel.enable = false;
  # Enable nix flakes
  nix = {
    settings.trusted-users = [ "root" "mar" ];
    settings.auto-optimise-store = true;
    settings.experimental-features = [ "nix-command" "flakes" "pipe-operators" ];
  };

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
  #  boot.tmp.cleanOnBoot = true;
  # boot.loader.grub.device = "nodev";
  # boot.loader.grub.enable = true;
  # boot.loader.grub.useOSProber = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  time.timeZone = "Europe/Oslo";
  i18n.defaultLocale = "en_US.UTF-8";
  networking.networkmanager.enable = true;
  users.users.mar.extraGroups = [ "docker" "networkmanager" ];
  #programs.nm-applet.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;


  #programs.hyprland.enable = true;
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


  # Enable sound.
  #sound.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };
  services.pipewire.wireplumber.enable = true;

  #for hyperland
  xdg.portal = { enable = true; extraPortals = [ pkgs.xdg-desktop-portal-gtk ]; };
  security.polkit.enable = true;


  # Enable touchpad support (enabled default in most desktopManager).
  #services.xserver.libinput.enable = true;
  services.xserver.xkb.layout = "us";
  services.xserver.xkb.options = "caps:escare";
  console.useXkbConfig = true;
  services.xserver.autoRepeatDelay = 200;
  services.xserver.autoRepeatInterval = 20;
  environment.systemPackages = with pkgs; [
    inputs.agenix.packages.x86_64-linux.default
    #vim #  The Nano editor is also installed by default.
    hyprland
    git
    tmux
    bottom
    slack
    prusa-slicer
  ];

  # Enable the wayland suport for slack
  environment.sessionVariables.NIXOS_OZONE_WL = "1";


  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    #mplus-outline-fonts
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

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      # dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
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
  #system.autoUpgrade.allowReboot =true;



}
