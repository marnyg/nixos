{ pkgs, lib, config, ... }:
with lib;
{
  options.modules.other = {
    enable = mkOption { type = types.bool; default = false; };
  };
  config = mkIf config.modules.other.enable {
    #services.network-manager-applet.enable = true;
    #services.blueman-applet.enable = true;
    #services.redshift.tray = true;
    programs.home-manager.enable = true;
  };
}
