{ lib, config, ... }:
with lib;
{
  options.modules.my.other = {
    enable = mkOption { type = types.bool; default = false; };
  };
  config = mkIf config.modules.my.other.enable {
    #services.network-manager-applet.enable = true;
    #services.blueman-applet.enable = true;
    #services.redshift.tray = true;
    programs.home-manager.enable = true;
  };
}
