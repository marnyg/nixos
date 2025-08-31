{ lib, config, ... }:
{
  options.modules.secrets.enable = lib.mkEnableOption ''
    encrypted secrets management via agenix.
    
    Sets up age-encrypted secrets for API keys (Claude, OpenRouter tokens)
    with proper file paths and identity configuration
  '';

  config = lib.mkIf config.modules.secrets.enable
    {
      age.secretsDir = "${config.home.homeDirectory}/.cache/agenix";
      age.identityPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];

      age.secrets.claudeToken.file = ./claudeToken.age;
      age.secrets.openrouterToken.file = ./openrouterToken.age;
    };
}
