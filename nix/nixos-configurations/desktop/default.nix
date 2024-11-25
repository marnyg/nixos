{ inputs, pkgs, ... }:
let
  #TODO:move this out into own users file
  defaultHMConfig = {
    imports = [ inputs.agenix.homeManagerModules.age ];
    myHmModules.sharedDefaults.enable = true;

    modules.zsh.enable = true;
    modules.direnv.enable = true;
    modules.zellij.enable = false;
    modules.tmux.enable = true;
    modules.firefox.enable = true;
    modules.autorandr.enable = false;
    modules.bspwm.enable = true;
    modules.dunst.enable = false;
    modules.kitty.enable = true;
    modules.kitty.fontsize = 11;
    myModules.git.enable = true;
    modules.newsboat.enable = false;
    modules.polybar.enable = false;
    modules.xmonad.enable = false;
    modules.hyperland.enable = true;
    modules.spotifyd.enable = false;
    modules.other.enable = false;
    modules.myPackages.enable = true;
    modules.cloneDefaultRepos.enable = true;
    modules.lf.enable = true;
    myModules.secrets.enable = true;
  };
in
{
  imports = [ ./hardware-config.nix inputs.agenix.nixosModules.age ];
  age.secrets.claudeToken.file = ../../home-modules/secrets/claudeToken.age;
  age.secrets.claudeToken.owner = "mar";
  age.identityPaths = [ "/home/mar/.ssh/id_ed25519" ];
  ##
  ## system modules config
  ##
  myModules.myNixvim.enable = true; # TODO: should be managed by homemanger
  myModules.wsl.enable = false;
  myModules.defaults.enable = true;

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
  programs.nm-applet.enable = true;

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
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "caps:escare";
  console.useXkbConfig = true;
  services.xserver.autoRepeatDelay = 200;
  services.xserver.autoRepeatInterval = 20;
  environment.systemPackages = with pkgs; [
    inputs.agenix.packages.x86_64-linux.default
    vim #  The Nano editor is also installed by default.
    hyprland
    git
    tmux
    bottom
    slack
  ];

  # Enable the wayland suport for slack
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  nixpkgs.config.allowUnfree = true;
  programs.steam.enable = true;

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
  system.autoUpgrade.flake = "github:marnyg/nixos#laptop";
  #system.autoUpgrade.allowReboot =true;



}
