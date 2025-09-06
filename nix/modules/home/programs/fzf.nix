{ lib, config, ... }:
with lib;
{
  options.modules.my.fzf = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.my.fzf.enable {
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      defaultOptions = [ "--bind" "'tab:toggle-up,btab:toggle-down'" ];
    };
  };
}
