{ lib, config, ... }:
with lib;
{
  options.modules.my.nvim = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.my.nvim.enable {
    # This module is not currently implemented
    # Consider using the nixvim package from pkgs/nixvim/ instead
  };
}
