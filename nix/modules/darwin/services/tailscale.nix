# Tailscale service module for Darwin
{ lib, config, ... }:
with lib;
let
  cfg = config.modules.darwin.services.tailscale;
in
{
  options.modules.darwin.services.tailscale = {
    enable = mkEnableOption "Tailscale VPN";
  };

  config = mkIf cfg.enable {
    services.tailscale.enable = true;
  };
}
