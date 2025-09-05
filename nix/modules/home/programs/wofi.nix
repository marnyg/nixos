{ lib, config, ... }:
with lib;
{
  options.modules.wofi = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.wofi.enable {
    programs.wofi.enable = true;

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
