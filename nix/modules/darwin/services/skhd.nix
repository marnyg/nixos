# skhd hotkey daemon service module
{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.modules.darwin.services.skhd;
in
{
  options.modules.darwin.services.skhd = {
    enable = mkEnableOption "skhd hotkey daemon";

    keybindings = mkOption {
      type = types.attrsOf types.str;
      default = { };
      example = literalExpression ''
        {
          "alt - return" = "open -a Terminal";
          "alt - h" = "yabai -m window --focus west";
        }
      '';
      description = "Keybindings configuration";
    };

    defaultKeybindings = mkOption {
      type = types.bool;
      default = true;
      description = "Enable default keybindings for window management";
    };
  };

  config = mkIf cfg.enable {
    services.skhd = {
      enable = true;
      skhdConfig =
        let
          defaultBindings = optionalString cfg.defaultKeybindings ''
            # Reload config
            alt - r : yabai -m rule --apply; launchctl stop org.nixos.skhd; launchctl start org.nixos.skhd; launchctl stop org.nixos.yabai; launchctl start org.nixos.yabai
          
            # Open apps
            alt - return : sh -c 'open ~/Applications/Home\ Manager\ Trampolines/Ghostty.app/'
            alt - f : sh -c 'open ~/Applications/Home\ Manager\ Trampolines/Firefox.app/'
          
            # Window focus navigation (wrapped in sh -c for shell compatibility)
            alt - h : sh -c "yabai -m window --focus west || yabai -m display --focus west"
            alt - j : sh -c "yabai -m window --focus south || yabai -m display --focus south"
            alt - k : sh -c "yabai -m window --focus north || yabai -m display --focus north"
            alt - l : sh -c "yabai -m window --focus east || yabai -m display --focus east"
          
            # Stack navigation
            alt - p : yabai -m window --focus stack.prev || yabai -m window --focus stack.last
            alt - n : yabai -m window --focus stack.next || yabai -m window --focus stack.first
          
            # Window movement
            shift + alt - h : yabai -m window --move rel:-40:0
            shift + alt - j : yabai -m window --move rel:0:40
            shift + alt - k : yabai -m window --move rel:0:-40
            shift + alt - l : yabai -m window --move rel:40:0
          
            # Window resizing
            shift + cmd - h : yabai -m window --resize left:-40:0
            shift + cmd - j : yabai -m window --resize bottom:0:40
            shift + cmd - k : yabai -m window --resize top:0:-40
            shift + cmd - l : yabai -m window --resize right:40:0
          
            # Layout management - using explicit bash to handle command substitution
            alt - d : /bin/bash -c 'yabai -m space --layout $(yabai -m query --spaces --space | ${pkgs.jq}/bin/jq -r "if .type == \"bsp\" then \"stack\" else \"bsp\" end")'
            alt - t : yabai -m window --toggle float
            alt - m : yabai -m window --toggle zoom-fullscreen
          
            # Disable cmd-h hide
            cmd - h : echo "no hide window"
          '';

          customBindings = lib.concatStringsSep "\n"
            (lib.mapAttrsToList (key: cmd: "${key} : ${cmd}") cfg.keybindings);
        in
        ''
          ${defaultBindings}
          ${customBindings}
        '';
    };
  };
}
