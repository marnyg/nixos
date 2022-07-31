{ ... }:
{
  home.file.".config/bspwm/bspwmrc" = {
    text = (builtins.readFile ./bspwmrc);
  };
  home.file.".config/sxhkd/sxhkdrc" = {
    text = (builtins.readFile ./bspwmrc);
  };
}
