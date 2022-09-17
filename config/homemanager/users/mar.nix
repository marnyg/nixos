{ config, pkgs, ... }: {
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

  services.udev.packages = [ pkgs.yubikey-personalization ];
  security.pam.yubico = {
    enable = true;
    #debug = true;
    mode = "challenge-response";
  };

  home-manager.users.mar = {
    # Enable home-manager
    programs.home-manager.enable = true;

    imports = [
      ./common.nix
      ../programs/firefox.nix
      ../programs/zsh.nix
      ../programs/newsboat.nix
      ../programs/git.nix
      ../programs/zellij.nix
      ../programs/kitty.nix
      ../programs/dunst.nix
      ../programs/nvim.nix
      ../programs/polybar/polybar.nix
      ../programs/bspwm/bspwm.nix
      ../programs/autorandr/desktop.nix
    ];

    #services.network-manager-applet.enable = true;
    #services.blueman-applet.enable = true;
    services.redshift.tray = true;


    # Settings for spotifyd
    services.spotifyd = {
      enable = true;
      package = pkgs.spotifyd.override {
        withMpris = true;
        withPulseAudio = true;
      };
      settings = {
        global = {
          username = "pkj258alfons";
          backend = "alsa";
          device = "default";
          mixer = "PCM";
          volume-controller = "alsa";
          device_name = "spotifyd";
          device_type = "speaker";
          bitrate = 96;
          cache_path = ".cache/spotifyd";
          volume-normalisation = true;
          normalisation-pregain = -10;
          initial_volume = "50";
        };
      };
    };

    # Do not touch
    home.stateVersion = "21.03";

    home.packages = with pkgs; [
      dwm
      rofi
      dmenu
      feh
      firefox

      # Command-line tools
      #fzf
      ripgrep
      ffmpeg
      tealdeer
      exa
      duf
      spotify-tui
      playerctl
      gnupg
      slop
      bat
      libnotify
      sct
      hyperfine
      tree
      unrar
      unzip

      # GUI applications
      mpv
      nyxt
      arandr
      #qutebrowser
      #vscode

      # GUI File readers
      mupdf
      sxiv

      # Development
      gcc
      gnumake
      python3

      # Other
      bitwarden
      xdotool
      xclip
      scrot
      #nheko #matrix client
      pavucontrol
      spotify
    ];

  };
}
