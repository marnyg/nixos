{ lib, config, pkgs, ... }:
with lib;
{
  options.modules.my.rofi = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable rofi launcher with custom Nord theme";
    };
  };

  config = mkIf config.modules.my.rofi.enable {
    programs.rofi = {
      enable = true;
      terminal = "${pkgs.kitty}/bin/kitty";
      theme = "nord";
      font = "FiraCode Nerd Font 12";

      extraConfig = {
        modi = "run,drun,window,ssh";
        show-icons = true;
        icon-theme = "Papirus";
        display-drun = " Apps";
        display-run = " Run";
        display-window = " Window";
        display-ssh = " SSH";
        drun-display-format = "{icon} {name}";
        hide-scrollbar = true;
        sidebar-mode = true;

        # Nord color scheme
        kb-row-up = "Up,Control+k,ISO_Left_Tab";
        kb-row-down = "Down,Control+j";
        kb-accept-entry = "Control+m,Return,KP_Enter";
        kb-remove-to-eol = "Control+Shift+e";
        kb-mode-next = "Shift+Right,Control+Tab";
        kb-mode-previous = "Shift+Left,Control+Shift+Tab";
        kb-remove-char-back = "BackSpace";
      };
    };

    # Create a custom Nord theme
    home.file.".config/rofi/nord.rasi".text = ''
      * {
          nord0: #2e3440;
          nord1: #3b4252;
          nord2: #434c5e;
          nord3: #4c566a;
          nord4: #d8dee9;
          nord5: #e5e9f0;
          nord6: #eceff4;
          nord7: #8fbcbb;
          nord8: #88c0d0;
          nord9: #81a1c1;
          nord10: #5e81ac;
          nord11: #bf616a;
          nord12: #d08770;
          nord13: #ebcb8b;
          nord14: #a3be8c;
          nord15: #b48ead;

          background-color: @nord0;
          text-color: @nord4;
          selbg: @nord10;
          actbg: @nord2;
          urgbg: @nord11;
          winbg: @nord0;

          selected-normal-foreground: @nord6;
          normal-foreground: @text-color;
          selected-normal-background: @selbg;
          normal-background: @background-color;

          selected-urgent-foreground: @nord6;
          urgent-foreground: @text-color;
          selected-urgent-background: @urgbg;
          urgent-background: @background-color;

          selected-active-foreground: @nord6;
          active-foreground: @text-color;
          selected-active-background: @actbg;
          active-background: @selbg;

          line-margin: 2;
          line-padding: 2;
          separator-style: "none";
          hide-scrollbar: "true";
          margin: 0;
          padding: 10;
          font: "FiraCode Nerd Font 12";
      }

      window {
          location: center;
          anchor: center;
          transparency: "real";
          width: 600px;
          border-radius: 8px;
          border: 2px solid @nord10;
          background-color: @nord0;
      }

      mainbox {
          spacing: 0;
          children: [inputbar, message, listview];
      }

      inputbar {
          color: @nord4;
          padding: 11px;
          background-color: @nord1;
          border-radius: 8px 8px 0 0;
      }

      entry, prompt, case-indicator {
          text-font: inherit;
          text-color: inherit;
      }

      prompt {
          margin: 0 1em 0 0;
      }

      listview {
          padding: 8px;
          border-radius: 0 0 8px 8px;
          background-color: @nord0;
          columns: 1;
          lines: 10;
      }

      element {
          padding: 8px;
          vertical-align: 0.5;
          border-radius: 4px;
          background-color: transparent;
          color: @foreground;
          text-color: @nord4;
      }

      element.normal.active {
          background-color: @nord2;
      }

      element.normal.urgent {
          background-color: @nord11;
      }

      element.selected.normal {
          background-color: @nord10;
          text-color: @nord6;
      }

      element.selected.active {
          background-color: @nord8;
          text-color: @nord0;
      }

      element.selected.urgent {
          background-color: @nord11;
          text-color: @nord6;
      }

      element-icon {
          size: 2.5ch;
          margin: 0 10px 0 0;
      }

      button {
          padding: 5px 2px;
      }

      button selected {
          background-color: @active-background;
          text-color: @nord6;
      }
    '';
  };
}
