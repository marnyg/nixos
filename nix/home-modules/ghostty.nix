{ lib, config, ... }:
with lib;
{
  options.modules.ghostty = {
    enable = mkOption { type = types.bool; default = false; };
    fontsize = mkOption { type = types.number; default = 12; };
  };

  config = mkIf config.modules.ghostty.enable {
    modules.nushell.enable = true;


    programs.ghostty = {
      enable = true;

      settings = {
        theme = "catppuccin-mocha";
        font-size = 10;
        # shell-integration = "none";
        # title = " ";
        window-decoration = false;
        confirm-close-surface = false;
      };
      themes = {
        catppuccin-mocha = {
          background = "1e1e2e";
          cursor-color = "f5e0dc";
          foreground = "cdd6f4";
          palette = [
            "0=#45475a"
            "1=#f38ba8"
            "2=#a6e3a1"
            "3=#f9e2af"
            "4=#89b4fa"
            "5=#f5c2e7"
            "6=#94e2d5"
            "7=#bac2de"
            "8=#585b70"
            "9=#f38ba8"
            "10=#a6e3a1"
            "11=#f9e2af"
            "12=#89b4fa"
            "13=#f5c2e7"
            "14=#94e2d5"
            "15=#a6adc8"
          ];
          selection-background = "353749";
          selection-foreground = "cdd6f4";
        };

      };

      # font = {
      #   name = "Fira Code Nerd Font";
      #   size = config.modules.ghostty.fontsize;
      #   #size = "6";
      #   #name= "Fira Mono Nerd Font";
      #   #name ="JetBrains Mono";
      #   #name= "Droid Sans Mono Nerd Font";
      #   #name= "Noto Nerd Font";
      # };
    };
  };
}
