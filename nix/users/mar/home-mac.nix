# Home-manager configuration for user 'mar' on macOS
{ pkgs, inputs, ... }:
{
  # Import base configuration and Mac profile
  imports = [
    inputs.agenix.homeManagerModules.default
    ../../modules/home/profiles/mac.nix
  ];

  # macOS-specific home directory
  home.homeDirectory = "/Users/mariusnygard";
  home.stateVersion = "23.11";
  home.packages = [ pkgs.taskwarrior3 pkgs.taskwarrior-tui pkgs.uv ];

  # Enable secrets management
  modules.my.secrets.enable = true;

  # Host-specific overrides (if any)
  # These override the profile defaults
  modules.my = {
    # Ovis over the mesh without a pairing code: mesh membership (admins, via
    # this Mac's services.talos-mesh forward.tcp = "127.0.0.1:*") is the
    # sign-in. Opened as http://marius-mac.mesh.internal:7318 from another
    # admin device; 7317 stays the token-gated server itself. macOS uses a
    # launchd agent where the desktop uses a systemd user service.
    herdr.ovisMeshProxy = {
      enable = true;
      hostNames = [ "marius-mac.mesh.internal" ];
    };
  };
}
