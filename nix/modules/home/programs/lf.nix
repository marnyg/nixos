{ pkgs, lib, config, ... }:
with lib;
{
  options.modules.my.lf = {
    enable = mkOption { type = types.bool; default = false; };
  };
  config = mkIf config.modules.my.lf.enable
    {
      programs.lf.enable = true;
      programs.lf.settings = {
        sixel = true;
      };
      programs.lf.keybindings = {
        #D = "trash";
        U = "!du -sh";
        #gg = null;
        gh = "cd ~";
        i = "$less $f";
      };

      programs.lf.previewer.source = pkgs.writeShellScript "pv.sh" ''
        #!/bin/sh

        case "$(${pkgs.file}/bin/file -Lb --mime-type -- "$1")" in
            image/*)
                ${pkgs.chafa}/bin/chafa -f sixel -s "$2x$3" --animate false "$1"
                exit 1
                ;;
        esac

        case "$1" in
            *.tar*) tar tf "$1";;
            *.zip) unzip -l "$1";;
            *.rar) unrar l "$1";;
            *.7z) 7z l "$1";;
            *.pdf) pdftotext "$1" -;;
            *) highlight -O ansi "$1" || cat "$1";;
        esac
      '';


    };
}
