{ pkgs, lib, config, ... }:
with lib;
{
  options.modules.fish.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
      Enable Fish shell with custom configuration.
      
      Automatically enables shared shell configuration, sets up Vi keybindings,
      configures API keys from secrets, and includes the bang-bang plugin
      for command history expansion.
    '';
  };

  config = mkIf config.modules.fish.enable {
    # Enable shared shell configuration
    modules.sharedShellConfig.enable = true;



    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        fish_vi_key_bindings
        ${lib.optionalString (config.age.secrets ? claudeToken) ''
          set -gx ANTHROPIC_API_KEY $(cat ${config.age.secrets.claudeToken.path})
        ''}
        ${lib.optionalString (config.age.secrets ? openrouterToken) ''
          set -gx OPENROUTER_API_KEY $(cat ${config.age.secrets.openrouterToken.path})
          set -gx OPENAI_API_KEY $(cat ${config.age.secrets.openrouterToken.path})
        ''}
        set -gx EDITOR nvim
      '';
      functions = {
        gcm = ''
          git commit -m "$argv"
        '';
      };
      # Fish-specific aliases (shared ones are in sharedShellConfig)
      shellAliases = {
        gi = "gitui";
      };

      plugins = [
        {
          name = "bang-bang";
          src = pkgs.fetchFromGitHub {
            owner = "oh-my-fish";
            repo = "plugin-bang-bang";
            rev = "master";
            sha256 = "sha256-oPPCtFN2DPuM//c48SXb4TrFRjJtccg0YPXcAo0Lxq0=";
          };
        }
      ];
    };
  };
}
