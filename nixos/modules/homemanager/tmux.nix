{ pkgs, lib, config, ... }:
with lib;
{
  options.modules.tmux = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.tmux.enable {
    programs.tmux = {
      enable = true;
      keyMode = "vi";
      escapeTime = 0;
    };
  };
}
