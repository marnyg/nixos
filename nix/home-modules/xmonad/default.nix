{ lib, config, ... }:
with lib;

{
  options.modules.xmonad = {
    enable = mkOption { type = types.bool; default = false; };
  };
  config = mkIf config.modules.xmonad.enable
    {
      #let
      #  #extra = ''
      #  #  ${pkgs.util-linux}/bin/setterm -blank 0 -powersave off -powerdown 0
      #  #  ${pkgs.xorg.xset}/bin/xset s off
      #  #  ${pkgs.xcape}/bin/xcape -e "Hyper_L=Tab;Hyper_R=backslash"
      #  #  ${pkgs.xorg.xrandr}/bin/xrandr --output HDMI-A-0 --mode 3840x2160 --rate 30.00
      #  #'';
      #
      #  #polybarOpts = ''
      #  #  ${pkgs.nitrogen}/bin/nitrogen --restore &
      #  #  ${pkgs.pasystray}/bin/pasystray &
      #  #  ${pkgs.blueman}/bin/blueman-applet &
      #  #  ${pkgs.gnome3.networkmanagerapplet}/bin/nm-applet --sm-disable --indicator &
      #  #'';
      #  polybarOpts = ''
      #    ${pkgs.nm-applet}/bin/nm-applet --sm-disable --indicator &
      #  '';
      #in
      #{
      xresources.properties = {
        "Xft.dpi" = 100;
        "Xft.autohint" = 0;
        "Xft.hintstyle" = "hintfull";
        "Xft.hinting" = 1;
        "Xft.antialias" = 1;
        "Xft.rgba" = "rgb";
        "Xcursor*theme" = "Vanilla-DMZ-AA";
        "Xcursor*size" = 24;
      };

      xsession = {

        #initExtra = extra + polybarOpts;
        #initExtra = polybarOpts;
        # initExtra = "${pkgs.nm-applet}/bin/nm-applet --sm-disable --indicator &";

        windowManager.xmonad = {
          enable = true;
          enableContribAndExtras = true;
          extraPackages = hp: [ hp.dbus hp.monad-logger ];
          #config = ./config.hs;
        };
      };
    };
}
