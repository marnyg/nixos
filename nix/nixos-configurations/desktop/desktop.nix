{ config, pkgs, ... }: {

  services.udev.packages = [ pkgs.yubikey-personalization ];
  security.pam.yubico = {
    enable = true;
    #debug = true;
    mode = "challenge-response";
  };


  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.kitty.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  #=====
  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "us";
    autoRepeatDelay = 200;
    autoRepeatInterval = 20;
    #.xkbOptions = "caps:swapescape";

    desktopManager.session = [{
      name = "xsession";
      start = ''
        ${pkgs.runtimeShell} $HOME/.xsession &
        waitPID=$!
      '';
    }];
  };

  # Enable the X11 windowing system.
  services.compton.enable = true;
  services.compton.shadow = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;
  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  nixpkgs.config.allowUnfree = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;

  virtualisation = {
    docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
  };

  #VM??????????????????????????//
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;


  users.users.mar = { ... }: {
    isNormalUser = true;
    extraGroups = [
      "docker"
      "networkmanager"
      "wheel"
      "qemu-libvirtd"
      "libvirtd"
    ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
  };
  home-manager.users.mar = import ./mar.nix;
}
