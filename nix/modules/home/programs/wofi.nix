{ lib, config, pkgs, ... }:
with lib;
{
  options.modules.my.wofi = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.my.wofi.enable {
    programs.wofi = {
      enable = true;

      settings = {
        width = 650;
        height = 450;
        location = "center";
        show = "drun";
        prompt = "⚡ Apps";
        filter_rate = 100;
        allow_markup = true;
        no_actions = false;
        halign = "fill";
        orientation = "vertical";
        content_halign = "fill";
        insensitive = true;
        allow_images = true;
        image_size = 38;
        gtk_dark = true;
        dynamic_lines = true;
        hide_scroll = false;
        matching = "fuzzy";
        sort_order = "alphabetical";
        normal_window = false;
        layer = "overlay";
        margin = "5";
        padding = "5";
      };

      style = ''
        * {
          font-family: "JetBrainsMono Nerd Font", "FiraCode Nerd Font", monospace;
          font-size: 13px;
        }
        
        /* Window styling with gradient and shadow */
        window {
          margin: 0px;
          padding: 0px;
          border: 2px solid rgba(136, 192, 208, 0.8);
          border-radius: 12px;
          background: linear-gradient(135deg, rgba(46, 52, 64, 0.95) 0%, rgba(59, 66, 82, 0.95) 100%);
          box-shadow: 0 10px 40px rgba(0, 0, 0, 0.4),
                      0 2px 10px rgba(0, 0, 0, 0.2),
                      inset 0 1px 0 rgba(255, 255, 255, 0.05);
          animation: slideInScale 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
        }
        
        /* Input field with better styling */
        #input {
          margin: 15px;
          padding: 12px 16px;
          border: 2px solid rgba(76, 86, 106, 0.5);
          border-radius: 8px;
          color: #eceff4;
          background: linear-gradient(135deg, rgba(59, 66, 82, 0.8) 0%, rgba(67, 76, 94, 0.8) 100%);
          font-size: 14px;
          font-weight: 500;
          transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
          box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.2),
                      0 1px 0 rgba(255, 255, 255, 0.05);
        }
        
        #input:focus {
          border-color: #88c0d0;
          background: linear-gradient(135deg, rgba(67, 76, 94, 0.9) 0%, rgba(76, 86, 106, 0.9) 100%);
          box-shadow: 0 0 0 3px rgba(136, 192, 208, 0.2),
                      inset 0 2px 4px rgba(0, 0, 0, 0.2),
                      0 1px 0 rgba(255, 255, 255, 0.05);
          transform: translateY(-1px);
        }
        
        #input image {
          margin-right: 8px;
          opacity: 0.7;
        }
        
        /* Inner box for content area */
        #inner-box {
          margin: 0 10px 10px 10px;
          padding: 5px;
          border: none;
          background-color: transparent;
          border-radius: 8px;
        }
        
        /* Outer box container */
        #outer-box {
          margin: 0px;
          padding: 0px;
          border: none;
          background-color: transparent;
        }
        
        /* Scrollbar styling */
        #scroll {
          margin: 0px;
          padding: 0px;
          border: none;
          background-color: transparent;
        }
        
        #scroll scrollbar {
          width: 4px;
          border: none;
          background-color: rgba(76, 86, 106, 0.3);
          border-radius: 2px;
        }
        
        #scroll scrollbar:hover {
          background-color: rgba(76, 86, 106, 0.5);
        }
        
        #scroll scrollbar slider {
          background-color: rgba(136, 192, 208, 0.5);
          border-radius: 2px;
          min-height: 20px;
        }
        
        #scroll scrollbar slider:hover {
          background-color: rgba(136, 192, 208, 0.7);
        }
        
        /* Text styling */
        #text {
          margin: 0px 8px;
          padding: 0px;
          color: #d8dee9;
          font-weight: 400;
        }
        
        #text:selected {
          color: #ffffff;
          font-weight: 500;
        }
        
        /* Entry items with enhanced styling */
        #entry {
          padding: 10px 12px;
          margin: 3px 5px;
          background: linear-gradient(135deg, rgba(59, 66, 82, 0.3) 0%, rgba(67, 76, 94, 0.3) 100%);
          border: 1px solid transparent;
          border-radius: 8px;
          transition: all 0.2s cubic-bezier(0.25, 0.8, 0.25, 1);
        }
        
        #entry:selected {
          background: linear-gradient(135deg, rgba(94, 129, 172, 0.9) 0%, rgba(136, 192, 208, 0.9) 100%);
          border: 1px solid rgba(136, 192, 208, 0.5);
          box-shadow: 0 4px 12px rgba(94, 129, 172, 0.3),
                      0 2px 4px rgba(0, 0, 0, 0.2),
                      inset 0 1px 0 rgba(255, 255, 255, 0.1);
          transform: scale(1.02) translateX(2px);
        }
        
        #entry:hover:not(:selected) {
          background: linear-gradient(135deg, rgba(67, 76, 94, 0.5) 0%, rgba(76, 86, 106, 0.5) 100%);
          border: 1px solid rgba(136, 192, 208, 0.2);
        }
        
        /* Icon styling */
        #entry image {
          margin-right: 10px;
          opacity: 0.9;
          transition: all 0.2s ease;
        }
        
        #entry:selected image {
          opacity: 1;
          transform: scale(1.1);
        }
        
        /* Mode switcher styling */
        #mode {
          margin: 10px;
          padding: 8px;
          background-color: rgba(59, 66, 82, 0.5);
          border-radius: 6px;
          border: 1px solid rgba(76, 86, 106, 0.3);
        }
        
        #mode-switcher {
          margin: 5px;
        }
        
        /* Animations */
        @keyframes slideInScale {
          from {
            opacity: 0;
            transform: translateY(-30px) scale(0.95);
          }
          to {
            opacity: 1;
            transform: translateY(0) scale(1);
          }
        }
        
        @keyframes pulse {
          0% {
            box-shadow: 0 0 0 0 rgba(136, 192, 208, 0.4);
          }
          70% {
            box-shadow: 0 0 0 10px rgba(136, 192, 208, 0);
          }
          100% {
            box-shadow: 0 0 0 0 rgba(136, 192, 208, 0);
          }
        }
        
        /* Add subtle glow to selected items */
        #entry:selected::after {
          animation: pulse 2s infinite;
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

    # Install additional dependencies for better appearance
    home.packages = with pkgs; [
      papirus-icon-theme # Better icons
      nerd-fonts.jetbrains-mono # Better font
    ];
  };
}
