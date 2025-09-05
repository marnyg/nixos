{ config, lib, pkgs, ... }:
{
  options.modules.sharedDefaults.enable = lib.mkEnableOption ''
    shared default configuration for Home Manager users.
    
    Enables basic programs (home-manager, bash), GitHub CLI with extensions,
    GPG agent with SSH support, and sets up essential environment variables
    and session paths
  '';

  config = lib.mkIf config.modules.sharedDefaults.enable {
    programs.home-manager.enable = true;
    programs.bash.enable = true;

    # GitHub CLI with useful extensions
    programs.gh.enable = true;
    programs.gh.extensions = [
      pkgs.gh-copilot
      pkgs.gh-poi
      pkgs.gh-cal
      pkgs.gh-dash
    ];

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };

    home = {
      stateVersion = "23.11";

      sessionVariables = {
        EDITOR = "nvim";
      };
      file.".config/nixpkgs/config.nix".text = ''
        {
          allowUnfree = true;
        }
      '';


      sessionPath = [
        "$HOME/go/bin"
        "$HOME/.local/bin"
        "$HOME/bin"
      ];
    };
  };
}
