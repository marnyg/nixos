# Shared secrets configuration module
{ lib, config, ... }:

with lib;

{
  options.myModules.secrets = {
    enable = mkEnableOption "shared secrets configuration";

    claudeTokens = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Claude/OpenRouter tokens";
    };
  };

  config = mkIf config.myModules.secrets.enable {
    # Age secrets configuration
    age = {
      secrets = mkIf config.myModules.secrets.claudeTokens {
        openrouterToken = {
          file = ../../home/secrets/claudeToken.age;
          owner = "mar";
        };
        claudeToken = {
          file = ../../home/secrets/claudeToken.age;
          owner = "mar";
        };
      };
      identityPaths = [ "/home/mar/.ssh/id_ed25519" ];
    };
  };
}
