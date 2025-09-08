# Darwin/macOS modules registry
{ ... }:
{
  flake.darwinModules = {
    # Core modules
    core-defaults = ./core/defaults.nix;
    core-nix-settings = ./core/nix-settings.nix;
    core-fonts = ./core/fonts.nix;
    core-brew = ./core/brew.nix;

    # Profile modules - composable configurations
    profile-base = ./profiles/base.nix;
    profile-minimal = ./profiles/minimal.nix;
    profile-developer = ./profiles/developer.nix;
    profile-workstation = ./profiles/workstation.nix;

    # Service modules
    service-yabai = ./services/yabai.nix;
    service-skhd = ./services/skhd.nix;
    service-tailscale = ./services/tailscale.nix;
    service-window-management = ./services/window-management.nix;

    # Legacy compatibility (to be deprecated)
    profile-workstation-simple = ./profiles/workstation-simple.nix;

    # Default module bundle
    default = {
      imports = [
        ./core/defaults.nix
        ./core/nix-settings.nix
        ./core/fonts.nix
        ./core/brew.nix
        ./services/yabai.nix
        ./services/skhd.nix
        ./services/tailscale.nix
        ./services/window-management.nix
      ];
    };
  };
}
