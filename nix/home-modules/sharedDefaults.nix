{ config, lib, pkgs, ... }:
{
  options.myHmModules.sharedDefaults.enable = lib.mkEnableOption "Create users";

  config = lib.mkIf config.myHmModules.sharedDefaults.enable {
    programs.home-manager.enable = true;
    programs.bash.enable = true;

    #todo: refactor into own module
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
    };

    home = {
      stateVersion = "23.11";
      #username = user;

      sessionVariables = {
        EDITOR = "nvim";
      };


      sessionPath = [
        "$HOME/go/bin"
        "$HOME/.local/bin"
        "$HOME/bin"
      ];
    };
  };
}
