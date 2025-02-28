{ lib, config, ... }:
{
  options.myModules.secrets.enable = lib.mkEnableOption "secrets";

  config = lib.mkIf config.myModules.secrets.enable
    {
      age.secrets.claudeToken.file = ./claudeToken.age;
      age.secrets.openrouterToken.file = ./openrouterToken.age;
      age.identityPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519.pub" ];
    };
}
