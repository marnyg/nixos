{ config, lib, pkgs, ... }:
{
  options.modules.my.sharedDefaults.enable = lib.mkEnableOption ''
    shared default configuration for Home Manager users.
    
    Enables basic programs (home-manager, bash), GitHub CLI with extensions,
    GPG agent with SSH support, and sets up essential environment variables
    and session paths
  '';

  config = lib.mkMerge [
    {
      # Unconditional: skip building the HM manual manpages. Their
      # options.json doc build (nixpkgs make-options-doc) discards store-path
      # context via unsafeDiscardStringContext, which newer Nix flags with
      # "Using 'builtins.derivation' ... without a proper context" on every
      # evaluation. Nobody reads `man home-configuration.nix` here anyway.
      manual.manpages.enable = lib.mkDefault false;
    }

    (lib.mkIf config.modules.my.sharedDefaults.enable {
      programs.home-manager.enable = true;
      programs.bash.enable = true;

      # GitHub CLI with useful extensions
      programs.gh.enable = true;
      programs.gh.extensions = [
        #pkgs.gh-copilot
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
    })
  ];
}
