{ lib, config, ... }:
with lib;
{
  options.modules.ghostty = {
    enable = mkOption { type = types.bool; default = false; };
    fontsize = mkOption { type = types.number; default = 14; };
  };

  config = mkIf config.modules.ghostty.enable {
    #modules.nushell.enable = true;
    modules.fish.enable = true;


    programs.ghostty = {
      enable = true;
      installBatSyntax = false;
      clearDefaultKeybinds = true;



      settings = {
        theme = "catppuccin-mocha";
        font-size = config.modules.ghostty.fontsize;
        font-family = "FiraCode Nerd Font Mono";
        #shell-integration = "none";
        shell-integration = "fish";
        window-decoration = false;
        confirm-close-surface = false;
        # config-file = "~/.config/ghostty/conf";
        command = "/run/current-system/sw/bin/fish";

        #command = "fish";
        keybind = [
          "cmd+shift+c=copy_to_clipboard"
          "cmd+shift+v=paste_from_clipboard"
          "ctrl+shift+c=copy_to_clipboard"
          "ctrl+shift+v=paste_from_clipboard"
          "ctrl+shift+a=select_all"
          "ctrl+shift+comma=reload_config"
          "ctrl+comma=open_config"
        ];
      };
      themes = {
        catppuccin-mocha = {
          background = "24273a";
          cursor-color = "f4dbd6";
          foreground = "cad3f5";
          palette = [
            "0=#494d64" # Black
            "1=#ed8796" # Red
            "2=#a6da95" # Green
            #"3=#eed49f" # Yellow
            "4=#5b7fcf" # Blue (darker for better contrast)
            "4=#8aadf4"
            "5=#f5bde6" # Magenta
            "6=#8bd5ca" # Cyan
            "7=#f0f0f0" # White (brighter for better contrast)
            "8=#5b6078" # Bright Black
            "9=#ed8796"
            "10=#a6da95"
            "11=#eed49f"
            "12=#8aadf4"
            "13=#f5bde6"
            "14=#8bd5ca"
            "15=#b8c0e0"
          ];
          selection-background = "3a3e53";
          selection-foreground = "cad3f5";
        };

      };
    };
  };
}
