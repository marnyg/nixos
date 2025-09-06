{ pkgs, lib, config, ... }:
with lib;
{
  options.modules.my.dunst = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.my.dunst.enable {
    # home.file = {
    #   ".config/dunst/dunstrc" = {
    #     source = ./dunstrc;
    #     target = ".config/dunst/dunstrc2";
    #   };
    # };

    services.dunst = {
      # configFile = "${config.xdg.configHome}/dunst/dunstrc2";
      enable = true;
      settings = {
        # global = {
        #   width = 300;
        #   height = 300;
        #   offset = "30x50";
        #   origin = "top-right";
        #   transparency = 10;
        #   frame_color = "#eceff1";
        #   font = "Droid Sans 9";
        # };
        shortcuts = {
          close = "ctrl+q";
          close_all = "ctrl+shift+q";
        };

        urgency_low = {
          background = "#282a36";
          foreground = "#6272a4";
          timeout = 10;
        };
        urgency_normal = {
          background = "#282a36";
          foreground = "#bd93f9";
          timeout = 10;
        };
        urgency_critical = {
          background = "#ff5555";
          foreground = "#f8f8f2";
          frame_color = "#ff5555";
          timeout = 10;
        };
        global = {
          browser = "${config.programs.firefox.package}/bin/firefox -new-tab";
          dmenu = "${pkgs.rofi}/bin/rofi -dmenu";
          follow = "mouse";
          font = "Droid Sans 10";
          format = "<b>%s</b>\\n%b";
          frame_color = "#555555";
          frame_width = 2;
          geometry = "500x5-5+30";
          horizontal_padding = 8;
          icon_position = "off";
          line_height = 0;
          markup = "full";
          padding = 8;
          separator_color = "frame";
          separator_height = 2;
          transparency = 10;
          word_wrap = true;
        };
      };
    };
  };
}
