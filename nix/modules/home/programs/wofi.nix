{ lib, config, ... }:
with lib;
{
  options.modules.my.wofi = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.my.wofi.enable {
    programs.wofi = {
      enable = true;

      settings = {
        width = 600;
        height = 400;
        location = "center";
        show = "drun";
        prompt = "Search...";
        filter_rate = 100;
        allow_markup = true;
        no_actions = false;
        halign = "fill";
        orientation = "vertical";
        content_halign = "fill";
        insensitive = true;
        allow_images = true;
        image_size = 32;
        gtk_dark = true;
        dynamic_lines = true;
        hide_scroll = true;
      };

      style = ''
        * {
          font-family: "FiraCode Nerd Font", monospace;
          font-size: 14px;
        }
        
        window {
          margin: 0px;
          padding: 10px;
          border: 2px solid #5e81ac;
          border-radius: 8px;
          background-color: #2e3440;
          animation: slideIn 0.3s ease-in-out;
        }
        
        #input {
          margin: 5px;
          padding: 10px;
          border: none;
          border-radius: 5px;
          color: #eceff4;
          background-color: #3b4252;
        }
        
        #input:focus {
          border: 2px solid #88c0d0;
        }
        
        #inner-box {
          margin: 5px;
          padding: 10px;
          border: none;
          background-color: #2e3440;
          border-radius: 5px;
        }
        
        #outer-box {
          margin: 5px;
          padding: 10px;
          border: none;
          background-color: #2e3440;
        }
        
        #scroll {
          margin: 0px;
          padding: 0px;
          border: none;
        }
        
        #text {
          margin: 5px;
          padding: 5px;
          color: #eceff4;
        }
        
        #text:selected {
          color: #2e3440;
          background-color: #88c0d0;
        }
        
        #entry {
          padding: 10px;
          margin: 2px;
          background-color: #3b4252;
          border-radius: 5px;
        }
        
        #entry:selected {
          background-color: #5e81ac;
          border-radius: 5px;
        }
        
        @keyframes slideIn {
          from {
            opacity: 0;
            transform: translateY(-30px);
          }
          to {
            opacity: 1;
            transform: translateY(0);
          }
        }
      '';
    };

    # For Hyprland
    wayland.windowManager.hyprland.extraConfig = mkIf config.wayland.windowManager.hyprland.enable (mkOrder 200 ''
      bindr = $mainMod, P, exec, pkill wofi || wofi --show drun -i -I
    '');

    # For Sway (by gpt, IE: not real config)
    #programs.sway.extraConfig = mkIf config.programs.sway.enable (mkOrder 200 ''
    #  bindsym $mod+o exec pkill wofi || wofi --show drun -i -I
    #'');
  };
}
