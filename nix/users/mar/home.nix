# Home-manager configuration for user 'mar'
{ lib, inputs, ... }:

{
  # Import user-specific modules based on environment
  imports = [
    inputs.agenix.homeManagerModules.default
  ];

  # Basic home configuration
  home.stateVersion = "23.11";

  # Enable secrets management
  modules.secrets.enable = true;

  # Default module selections
  # These can be overridden by profiles
  modules = {
    sharedDefaults.enable = lib.mkDefault true;
    nixvim.enable = lib.mkDefault true;
    fish.enable = lib.mkDefault true;
    git.enable = lib.mkDefault true;
    direnv.enable = lib.mkDefault true;
    tmux.enable = lib.mkDefault true;
    fzf.enable = lib.mkDefault true;
    myPackages.enable = lib.mkDefault true;
    cloneDefaultRepos.enable = lib.mkDefault true;
  };

  # Programs that should be enabled by default
  programs = {
    yazi.enable = true;
    ncspot.enable = lib.mkDefault false;
  };

  # Home-specific environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
