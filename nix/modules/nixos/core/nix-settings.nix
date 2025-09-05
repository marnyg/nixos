# Shared Nix configuration settings
{ lib, config, ... }:

with lib;

{
  options.myModules.nixSettings = {
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

  config = mkIf config.myModules.nixSettings.enable {
    nix = {
      settings = {
        trusted-users = config.myModules.nixSettings.trustedUsers;
        auto-optimise-store = true;
        experimental-features = mkIf config.myModules.nixSettings.flakes [
          "nix-command"
          "flakes"
          "pipe-operators"
        ];
      };
      channel.enable = false;
    };
  };
}
