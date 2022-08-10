{ config, pkgs, ... }:
{
  users.users.mar = { system, ... }: {
    isNormalUser = true;
    extraGroups = [ "docker" "networkmanager" "wheel" "qemu-libvirtd" "libvirtd" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
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
      ../programs/dunst.nix
      # ../programs/nvim.nix
      ../programs/polybar/polybar.nix
      ../programs/bspwm/bspwm.nix
      ../programs/autorandr/desktop.nix
    ];

    services.network-manager-applet.enable = true;
    services.blueman-applet.enable = true;
    services.redshift.tray = true;

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



    # Do not touch
    home.stateVersion = "21.03";

    home.packages = with pkgs; [
      dwm
      rofi
      dmenu
      feh
      firefox

      # Command-line tools
      fzf
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
      update-nix-fetchgit
      hyperfine
      zellij
      hunspell
      hunspellDicts.en-us
      starship
      tree
      unrar

      # GUI applications
      mpv
      nyxt
      arandr
      qutebrowser
      vscode


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
      # haskellPackages.xmobar
      # polybar

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

  };
}
