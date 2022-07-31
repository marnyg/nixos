{ config, pkgs, ... }:

let
  # import zsh config file
  zshsettings = import ../zsh/zsh.nix;
  # firefoxsettings = import ../firefox/firefox.nix;
in
{
  # Enable home-manager
  programs.home-manager.enable = true;

  imports = [
    ../programs/firefox.nix
    ../programs/zsh.nix
    ../programs/newsboat.nix
    ../programs/git.nix
    ../programs/nvim.nix
    ../programs/polybar/polybar.nix
    ../programs/bspwm/bspwm.nix
  ];

  # services.xserver.enable = true;

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

  # Settings for XDG user directory, to declutter home directory
  xdg.userDirs = {
    enable = true;
    documents = "$HOME/stuff/other/";
    download = "$HOME/stuff/other/";
    videos = "$HOME/stuff/other/";
    music = "$HOME/stuff/music/";
    pictures = "$HOME/stuff/pictures/";
    desktop = "$HOME/stuff/other/";
    publicShare = "$HOME/stuff/other/";
    templates = "$HOME/stuff/other/";
  };

  #home.file = {
  #    ".local/share/dwm/autostart.sh" = {
  #        executable = true;
  #        text = "
  #        #!/bin/sh
  #        status () { 
  #            echo -n BAT: \"$(acpi | awk '{print $4}' | sed s/,//) | $(date '+%m/%d %H:%M') \" 
  #        }
  #        feh --no-fehbg --bg-fill $NIXOS_CONFIG_DIR/config/pics/wallpaper.png
  #        rm $HOME/.xsession-errors $HOME/.xsession-errors.old .bash_history
  #        xrandr --rate 144
  #        while true; do
  #            xsetroot -name \"$(status)\"
  #            sleep 30
  #        done";
  #    };
  #};

  # Settings for gpg
  programs.gpg = {
    enable = true;
  };

  # Fix pass
  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "qt";
  };

  # Do not touch
  home.stateVersion = "21.03";

  home.packages = with pkgs; [
    dwm
    rofi
    dmenu
    feh
    dunst

    # Command-line tools
    fzf
    ripgrep
    ffmpeg
    tealdeer
    exa
    duf
    spotify-tui
    playerctl
    pass
    gnupg
    slop
    bat
    endlessh
    libnotify
    sct
    update-nix-fetchgit
    hyperfine
    zellij
    hunspell
    hunspellDicts.en-us
    starship
    tree
    unar

    # GUI applications
    mpv
    nyxt
    arandr
    qutebrowser
    vscode

    # GUI applets
    #nm-applet

    # GUI File readers
    zathura
    mupdf
    sxiv

    # Development
    gcc
    gnumake
    python3


    # Other
    bitwarden
    xdotool
    scrot
    nheko
    pavucontrol
    spotify

    #amazon cli
    #ec2_api_tools
    awscli

    #Bar 
    haskellPackages.xmobar
    polybar

    #haskell
    haskell.compiler.ghc8107 #.ghc865
    haskellPackages.cabal-install
    haskellPackages.stack
    haskellPackages.ghcid
    #unstable.haskellPackages.cabal2nix
    #haskellPackages.stack2nix


    # Language servers for neovim; change these to whatever languages you code in
    # Please note: if you remove any of these, make sure to also remove them from nvim/config/nvim/lua/lsp.lua!!
    rnix-lsp
    sumneko-lua-language-server
  ];

}
