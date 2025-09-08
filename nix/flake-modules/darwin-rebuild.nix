# Convenient darwin-rebuild shortcuts
{ self, ... }:
{
  perSystem = { system, ... }: {
    packages =
      if system == "aarch64-darwin" && self ? darwinConfigurations.mac then {
        # Shortcut to rebuild Mac configuration
        rebuild-mac = self.darwinConfigurations.mac.config.system.build.darwin-rebuild;

        # Alternative name
        darwin-rebuild = self.darwinConfigurations.mac.config.system.build.darwin-rebuild;
      } else { };
  };
}
