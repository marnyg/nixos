{ lib, config, ... }:
with lib;
{
  options.modules.fzf = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.fzf.enable {
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultOptions = [ "--bind" "'tab:toggle-up,btab:toggle-down'" ];
    };
  };
}
