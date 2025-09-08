# Darwin/macOS modules registry
{ ... }:
{
  flake.darwinModules = {
    # Core modules
    core-defaults = ./core/defaults.nix;
    core-nix-settings = ./core/nix-settings.nix;
    core-fonts = ./core/fonts.nix;

    # Profile modules
    profile-workstation = ./profiles/workstation.nix;
    profile-minimal = ./profiles/minimal.nix;

    # Service modules
    service-yabai = ./services/yabai.nix;
    service-skhd = ./services/skhd.nix;
    service-tailscale = ./services/tailscale.nix;
  };
}
