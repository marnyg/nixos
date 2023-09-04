{ pkgs, inputs, config, ... }:
let

  # TODO:move this out into own users file
  defaultHMConfig = {
    myHmModules.sharedDefaults.enable = true;

    modules.zsh.enable = true;
    modules.direnv.enable = true;
    modules.zellij.enable = false;
    modules.tmux.enable = true;
    modules.fzf.enable = true;
    modules.firefox.enable = true;
    modules.autorandr.enable = false;
    modules.bspwm.enable = true;
    modules.dunst.enable = false;
    modules.kitty.enable = true;
    myModules.git.enable = true;
    modules.newsboat.enable = false;
    modules.polybar.enable = false;
    modules.xmonad.enable = false;
    modules.hyperland.enable = true;
    modules.spotifyd.enable = false;
    modules.other.enable = false;
    modules.myPackages.enable = true;
    modules.cloneDefaultRepos.enable = false;
  };
in
{
  imports = [ ./hardware-config.nix ];
  ##
  ## system modules config
  ##
  modules.myNvim.enable = true; # TODO: should be managed by homemanger
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
      { name = "test"; homeManager = true; }
      { name = "notHM"; homeManager = false; }
    ];
    personalHomeManagerModules = [{ imports = inputs.my-modules.hmModulesModules.x86_64-linux; }];
  };

  ## 
  ## OTHER STUFF
  ## 
  boot.tmp.cleanOnBoot = true;
  boot.loader.grub.device = "nodev";
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  time.timeZone = "Europe/Oslo";
  i18n.defaultLocale = "en_US.UTF-8";
  networking.useDHCP = false;
  networking.interfaces.enp2s0.useDHCP = true;
  networking.interfaces.wlp3s0.useDHCP = true;
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;
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

  ##Enable the X11 windowing system.
  #services.xserver.enable = true;
  #services.xserver.displayManager.defaultSession = "none+bsp";
  #services.xserver.windowManager = {
  #  # Open configuration for the window manager.
  #  #dwm.enable = true;                  # Enable xmonad.
  #  xmonad.enable = true; # Enable xmonad.
  #  xmonad.enableContribAndExtras = true; # Enable xmonad contrib and extras.
  #  xmonad.extraPackages = hpkgs: [
  #    # Open configuration for additional Haskell packages.
  #    hpkgs.xmonad-contrib # Install xmonad-contrib.
  #    hpkgs.xmonad-extras # Install xmonad-extras.
  #    hpkgs.xmonad # Install xmonad itself.
  #    hpkgs.dbus
  #    hpkgs.monad-logger
  #  ];
  #  #xmonad.config = ./config/xmonad/config.hs;                # Enable xmonad.
  #  #xmonad.config = ./.config/config.hs;                # Enable xmonad.
  #  #xmonad.config = ./config.hs;                # Enable xmonad.
  #};

  # Enable the X11 windowing system.
  #services.compton.enable = true;
  #services.compton.shadow = true;
  #services.compton.inactiveOpacity = 0.8;

  # Enable sound.
  sound.enable = true;
  #hardware.pulseaudio.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };
  services.pipewire.wireplumber.enable= true;

  #for hyperland
  xdg.portal = { enable = true; extraPortals = [ pkgs.xdg-desktop-portal-gtk ]; };
  security.polkit.enable = true;


  # Enable touchpad support (enabled default in most desktopManager).
  #services.xserver.libinput.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "caps:escape";
  console.useXkbConfig = true;
  services.xserver.autoRepeatDelay = 200;
  services.xserver.autoRepeatInterval = 20;
  environment.systemPackages = with pkgs; [
    vim #  The Nano editor is also installed by default.
    hyprland
    git
    tmux
  ];

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
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


  nixpkgs.config.allowUnfree = true;

  virtualisation = {
    docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
  };
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;


}
