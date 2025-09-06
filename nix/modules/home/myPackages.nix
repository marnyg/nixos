# DEPRECATED: This module is being phased out
# Packages have been moved to appropriate profiles:
# - Developer tools -> profiles/developer.nix
# - Desktop applications -> profiles/desktop.nix
# - Minimal utilities -> profiles/minimal.nix
{ lib, config, ... }:
with lib;
{
  options.modules.my.myPackages = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "DEPRECATED: Use profiles instead for package management";
    };
  };

  config = mkIf config.modules.my.myPackages.enable {
    # Empty - all packages moved to profiles
    # This module is kept for backward compatibility only
  };
}
