# Netbird service module for Darwin
{ lib, config, ... }:
with lib;
let
  cfg = config.modules.darwin.services.netbird;
in
{
  options.modules.darwin.services.netbird = {
    enable = mkEnableOption "Netbird VPN daemon";
  };

  config = mkIf cfg.enable {
    services.netbird.enable = true;
  };
}
