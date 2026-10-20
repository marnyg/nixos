# Shared Nix configuration settings
{ lib, config, ... }:

with lib;

{
  options.modules.my.nixSettings = {
    enable = mkEnableOption "shared Nix settings";

    flakes = mkOption {
      type = types.bool;
      default = true;
      description = "Enable flakes and modern Nix features";
    };

    trustedUsers = mkOption {
      type = types.listOf types.str;
      default = [ "root" "mar" ];
      description = "List of trusted users";
    };
  };

  config = mkIf config.modules.my.nixSettings.enable {
    nix = {
      settings = {
        trusted-users = config.modules.my.nixSettings.trustedUsers;
        auto-optimise-store = true;

        # Home binary cache: LAN first, then mesh, then upstream. Short
        # connect-timeout + fallback so being off the home network only
        # costs a few seconds instead of failing builds. cache.nixos.org
        # (URL + key) is appended by the NixOS nix module via mkAfter.
        substituters = [
          "http://cache.lan:5000"
          "http://cache.gw.mesh.internal/main"
        ];
        trusted-public-keys = [
          "main:XkJGH65OA/NHub3CozVJL7mIt7uTfqLAVgNoQbUIcHw="
        ];
        connect-timeout = mkDefault 5;
        fallback = mkDefault true;
        experimental-features = mkIf config.modules.my.nixSettings.flakes [
          "nix-command"
          "flakes"
          "pipe-operators"
        ];
      };
      channel.enable = false;
    };
  };
}
