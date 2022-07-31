{ ... }:
{
  # home.file.".config/bspwm/bspwmrc" = {
  #   text = (builtins.readFile ./bspwmrc);
  # };
  # home.file.".config/sxhkd/sxhkdrc" = {
  #   text = (builtins.readFile ./sxhkdrc);
  # };

  xsession.enable = true;
  # xsession.windowManager.command = "…";
  xsession.windowManager.bspwm.enable = true;
  xsession.windowManager.bspwm.extraConfig = (builtins.readFile ./bspwmrc);
  services.sxhkd.enable = true;
  services.sxhkd.extraConfig = (builtins.readFile ./sxhkdrc);

}
