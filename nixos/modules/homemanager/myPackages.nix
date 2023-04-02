{ pkgs, lib, config, ... }:
with lib;
{
  options.modules.myPackages = {
    enable = mkOption { type = types.bool; default = false; };
  };
  config = mkIf config.modules.myPackages.enable
    {


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
        #exa
        #duf
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
        vscode

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
