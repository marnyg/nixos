{ pkgs, lib, config, ... }:
with lib;
{
  options.modules.myPackages = {
    enable = mkOption { type = types.bool; default = false; };
  };
  config = mkIf config.modules.myPackages.enable
    {


      home.packages = with pkgs; [
        dmenu
        feh

        # Command-line tools
        ripgrep
        ffmpeg
        discord
        code-cursor
        uv
        nodejs_24


        gnupg
        libnotify
        devenv
        unzip
        lazygit

        mpv
        # GUI pkf readers
        evince

        # Other
        jq
        tldr
      ] ++ (if pkgs.system != "aarch64-darwin"
      then [
        rofi
        coppwr
        playerctl
        sxiv
        xdotool
        xclip
        scrot
        pavucontrol
        bitwarden-cli
        signal-desktop
      ] else [ ]);
    };
}
