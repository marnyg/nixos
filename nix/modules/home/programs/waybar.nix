{ lib, config, ... }:
with lib;
{
  options.modules.my.waybar = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.my.waybar.enable {
    programs.waybar.enable = true;
    programs.waybar.systemd.enable = true;

    services.blueman-applet.enable = true;
    services.network-manager-applet.enable = true;
    services.gammastep.enable = true;
    services.gammastep.longitude = 10.25;
    services.gammastep.latitude = 63.25;
    services.gammastep.tray = true;
    programs.waybar.settings = builtins.fromJSON /* JSON */ ''
      {
        "mainBar": {
          "layer": "top",
          "modules-left": [ "hyprland/workspaces" ],
          "modules-center": ["hyprland/window"],
          "modules-right": [ "tray", "cpu", "memory", "pulseaudio", "bluetooth", "clock", "battery"],
          "hyprland/workspaces": {
            "format": "{name}: {icon}",
            "format-icons": {
              "1": "1",
              "2": "2",
              "3": "3",
              "4": "4",
              "5": "5",
              "6": "6",
              "7": "󰇮",
              "8": "",
              "9": "",
              "0": "0",
              "active": "",
              "default": "",
              "urgent": ""
            }
          },
          "backlight": {
            "device": "intel_backlight",
            "format": "<span color='#b4befe'>{icon}</span> {percent}%",
            "format-icons": ["", "", "", "", "", "", "", "", ""]
          },
          "pulseaudio": {
            "format": "<span color='#b4befe'>{icon}</span> {volume}%",
            "format-muted": "",
            "tooltip": false,
            "format-icons": {
              "headphone": "",
              "default": ["", "", "󰕾", "󰕾", "󰕾", "", "", ""]
            },
            "scroll-step": 1,
            "on-click": "pavucontrol"
          },
          "bluetooth": {
            "format": "<span color='#b4befe'></span> {status}",
            "format-disabled": "", 
            "format-connected": "<span color='#b4befe'></span> {num_connections}",
            "tooltip-format": "{device_enumerate}",
            "tooltip-format-enumerate-connected": "{device_alias}   {device_address}"
          },
          "network": {
            "format": "{ifname}",
            "format-wifi": "<span color='#b4befe'> </span>{essid}",
            "format-ethernet": "{ipaddr}/{cidr} ",
            "format-disconnected": "<span color='#b4befe'>󰖪 </span>No Network",
            "tooltip": false,
            "on-click": "nm-connection-editor"
          },
          "battery": {
            "format": "<span color='#b4befe'>{icon}</span> {capacity}%",
            "format-icons": ["🔋"],
            "format-charging": "<span color='#b4befe'>🔋</span> {capacity}%",
            "states": {
                "warning": 30,
                "critical": 15
          },
            "tooltip": false
          },
          "tray": {
            "icon-size": 21,
            "spacing": 10
          },
          "clock": {
            "format": "<span color='#b4befe'>  </span>{:%d:%m:%y  %H:%M}",      
            "tooltip-format": "<tt><small>{calendar}</small></tt>",
            "calendar": {
                        "mode"          : "month",
                        "mode-mon-col"  : 3,
                        "weeks-pos"     : "left",
                        "on-scroll"     : 1,
                        "format": {
                                  "months":     "<span color='#ffead3'><b>{}</b></span>",
                                  "days":       "<span color='#ecc6d9'><b>{}</b></span>",
                                  "weeks":      "<span color='#99ffdd'><b>W{}</b></span>",
                                  "weekdays":   "<span color='#ffcc66'><b>{}</b></span>",
                                  "today":      "<span color='#ff6699'><b><u>{}</u></b></span>"
                                  }
                        },
            "actions":  {
                        "on-click-right": "mode",
                        "on-click": "mode",
                        "on-scroll-up": "shift_up",
                        "on-scroll-down": "shift_down"
                        }
          },
          "cpu": {
              "format": "<span color='#b4befe'>🎞️ </span>{}%",
              "tooltip": false,
              "interval": 3
          },
          "memory": {
              "format": "<span color='#b4befe'>🖥 </span>{used}GiB",
              "interval": 3
          }
    
        }
      }
    '';

    programs.waybar.style = ''
          * {
        border: none;
        font-family: 'Fira Code', 'Symbols Nerd Font Mono';
        font-size: 15px;
        font-feature-settings: '"zero", "ss01", "ss02", "ss03", "ss04", "ss05", "cv31"';
        min-height: 17px;
      }

      window#waybar {
        background: transparent;
      }

      #custom-arch, #workspaces {
        border-radius: 10px;
        background-color: #2e3440;
        color: #d8dee9;
        margin-top: 5px;
      	margin-right: 15px;
        padding-top: 1px;
        padding-left: 10px;
        padding-right: 10px;
      }

      #custom-arch {
        font-size: 20px;
      	margin-left: 15px;
        color: #b4befe;
      }

      #workspaces button {
        background: #2e3440;
        color: #d8dee9;
      }

      #backlight, #pulseaudio, #cpu, #memory, #temperature, #bluetooth, #network, #battery, #clock, #window {
        border-radius: 10px;
        background-color: #2e3440;
        color: #d8dee9;
        margin-top: 5px;
        padding-left: 10px;
        padding-right: 10px;
        margin-right: 15px;
      }

      #pulseaudio, #backlight, #pulseaudio, #cpu, #bluetooth, #clock {
        border-top-right-radius: 0;
        border-bottom-right-radius: 0;
        padding-right: 5px;
        margin-right: 0
      }

      #network, #memory,#bluetooth , #battery {
        border-top-left-radius: 0;
        border-bottom-left-radius: 0;
        padding-left: 5px;
      }
    '';
  };
}
