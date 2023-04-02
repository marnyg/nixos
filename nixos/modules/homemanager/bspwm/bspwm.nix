{ pkgs, lib, config, ... }:
with lib;
{
  options.modules.bspwm = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.bspwm.enable {
    # home.file.".config/bspwm/bspwmrc" = {
    #   text = (builtins.readFile ./bspwmrc);
    # };
    # home.file.".config/sxhkd/sxhkdrc" = {
    #   text = (builtins.readFile ./sxhkdrc);
    # };

    #############################################
    # xsession.windowManager.command
    #   Command to use to start the window manager.
    #   The default value allows integration with NixOS' generated xserver configuration.
    #   Extra actions and commands can be specified in xsession.initExtra.
    #   Type: string
    #   Default: ''test -n "$1" && eval "$@"''
    #   Example:
    #   let
    #     xmonad = pkgs.xmonad-with-packages.override {
    #       packages = self: [ self.xmonad-contrib self.taffybar ];
    #     };
    #   in
    #     "${xmonad}/bin/xmonad";
    #   Declared by:
    #   <home-manager/modules/xsession.nix> 
    #############################################

    xsession.enable = true;
    xsession.initExtra = ''
      ${pkgs.autorandr}/bin/autorandr --change
      ${pkgs.feh}/bin/feh --bg-fill ${./.}/bg.jpg
    '';
    # xsession.windowManager.command = "…";
    xsession.windowManager.bspwm.enable = true;
    xsession.windowManager.bspwm.monitors = {
      DVI-D-1 = [ "I" "II" "III" "IV" ];
      HDMI-1 = [ "V" "VI" "VII" ];
      DVI-I-1 = [ "VIII" "IX" "X" ];
    };
    xsession.windowManager.bspwm.extraConfig = (builtins.readFile ./bspwmrc);
    services.sxhkd.enable = true;
    services.sxhkd.extraConfig = (builtins.readFile ./sxhkdrc);

  };
}
