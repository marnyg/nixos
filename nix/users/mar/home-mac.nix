# Home-manager configuration for user 'mar' on macOS
{ lib, inputs, ... }:
{
  # Import base configuration and Mac profile
  imports = [
    inputs.agenix.homeManagerModules.default
    ../../modules/home/profiles/mac.nix
  ];

  # macOS-specific home directory
  home.homeDirectory = "/Users/mariusnygard";
  home.stateVersion = "23.11";

  # Enable secrets management
  modules.my.secrets.enable = true;

  # Host-specific overrides (if any)
  # These override the profile defaults
  modules.my = {
    # Example: Enable work repos on this specific machine
    # cloneWorkRepos.enable = true;
  };
}
