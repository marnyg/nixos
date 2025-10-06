# Network timeout configuration for Nix
# This addresses the 5-second timeout issues with devenv and flake updates
{ lib, config, ... }:

with lib;

{
  options.modules.my.nixNetworkSettings = {
    enable = mkEnableOption "enhanced network timeout settings for Nix";
  };

  config = mkIf false {
    nix = {
      settings = {
        # Network performance with longer timeouts
        http-connections = lib.mkDefault 100;
        connect-timeout = lib.mkDefault 60;
        download-attempts = lib.mkDefault 10;

        # Increase stalled download timeout
        stalled-download-timeout = lib.mkDefault 300;
      };

      # Additional timeout configuration
      extraOptions = ''
        # DNS resolver timeout workaround
        use-case-hack = true
      '';
    };
  };
}
