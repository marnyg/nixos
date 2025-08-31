{ lib, config, ... }:
with lib;
{
  options.modules.nvim = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.nvim.enable {
    # This module is not currently implemented
    # Consider using the nixvim package from pkgs/nixvim/ instead
  };
}
