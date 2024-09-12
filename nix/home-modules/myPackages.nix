{ pkgs, lib, config, ... }:
with lib;
{
  options.modules.myPackages = {
    enable = mkOption { type = types.bool; default = false; };
  };
  config = mkIf config.modules.myPackages.enable
    {


      home.packages = with pkgs; [
        #dwm
        rofi
        dmenu
        feh
        firefox

        # Command-line tools
        #fzf
        ripgrep
        ffmpeg
        #tealdeer
        #exa
        #duf
        # spotify-tui
        playerctl
        gnupg
        #slop
        #bat
        #lf
        libnotify
        #sct
        #hyperfine
        #unrar
        unzip
        sqlite
        lazygit

        # GUI applications
        mpv
        #        nyxt
        #luakit
        arandr
        #vscode

        # GUI File readers
        mupdf
        sxiv

        # Development
        #gcc
        #gnumake
        #python3

        # Other
        # bitwarden
        bitwarden-cli
        jq
        xdotool
        xclip
        scrot
        #nheko #matrix client
        pavucontrol
        tldr
        #spotify
        # awscli2
        # aws-azure-login
      ];
    };
}
