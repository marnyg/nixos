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




  users.users.mar = { system, ... }: {
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
  home-manager.users.mar = import ./mar.nix
    #home-manager.users.mar = 
    #{
    #  # Enable home-manager
    #  programs.home-manager.enable = true;
    #  imports = [
    #  #  ./common.nix
    #  #  ../programs/firefox.nix
    #  #  ../programs/zsh.nix
    #  #  ../programs/newsboat.nix
    #  #  ../programs/git.nix
    #  #  ../programs/zellij.nix
    #  #  ../programs/kitty.nix
    #  #  ../programs/dunst.nix
    #  #  ../programs/nvim.nix
    #  #  ../programs/polybar/polybar.nix
    #  #  ../programs/bspwm/bspwm.nix
    #  #  ../programs/autorandr/desktop.nix
    #  ];

    #  #services.network-manager-applet.enable = true;
    #  #services.blueman-applet.enable = true;
    #  services.redshift.tray = true;


    #  # Settings for spotifyd
    #  services.spotifyd = {
    #    enable = true;
    #    package = pkgs.spotifyd.override {
    #      withMpris = true;
    #      withPulseAudio = true;
    #    };
    #    settings = {
    #      global = {
    #        username = "pkj258alfons";
    #        backend = "alsa";
    #        device = "default";
    #        mixer = "PCM";
    #        volume-controller = "alsa";
    #        device_name = "spotifyd";
    #        device_type = "speaker";
    #        bitrate = 96;
    #        cache_path = ".cache/spotifyd";
    #        volume-normalisation = true;
    #        normalisation-pregain = -10;
    #        initial_volume = "50";
    #      };
    #    };
    #  };

    #  # Do not touch
    #  home.stateVersion = "21.03";

    #  home.packages = with pkgs; [
    #    dwm
    #    rofi
    #    dmenu
    #    feh
    #    firefox

    #    # Command-line tools
    #    #fzf
    #    ripgrep
    #    ffmpeg
    #    tealdeer
    #    exa
    #    duf
    #    spotify-tui
    #    playerctl
    #    gnupg
    #    slop
    #    bat
    #    libnotify
    #    sct
    #    hyperfine
    #    tree
    #    unrar
    #    unzip

    #    # GUI applications
    #    mpv
    #    nyxt
    #    arandr
    #    #qutebrowser
    #    #vscode

    #    # GUI File readers
    #    mupdf
    #    sxiv

    #    # Development
    #    gcc
    #    gnumake
    #    python3

    #    # Other
    #    bitwarden
    #    xdotool
    #    xclip
    #    scrot
    #    #nheko #matrix client
    #    pavucontrol
    #    spotify
    #  ];

    #};
    }
