{ pkgs, lib, config, ... }:
with lib;
{
  options.modules.direnv = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.direnv.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
    };
  };
}
