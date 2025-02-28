# to install on mac run:
# nix run nix-darwin/nix-darwin-24.11#darwin-rebuild -- switch --flake .#mac
{ inputs, self, withSystem, ... }:
let
  system = "aarch64-darwin";
  pkgs = withSystem system ({ ... }: import inputs.nixpkgs {
    inherit system;
    config = { allowUnfree = true; };
    overlays = [ inputs.nixpkgs-firefox-darwin.overlay inputs.nur.overlay ];
  });
in
{

  flake.darwinConfigurations = {
    mac = inputs.darwin.lib.darwinSystem {
      system = system;
      pkgs = pkgs;
      modules = [
        # Main `nix-darwin` config
        ./mac-configuration.nix
        { environment.systemPackages = [ self.packages.${system}.nixvim ]; }
        # `home-manager` module
        inputs.home-manager.darwinModules.home-manager
        {

          users.users.mariusnygard.shell = pkgs.nushell;
          users.users.mariusnygard.home = "/Users/mariusnygard";
          #nixpkgs = inputs.nixpkgs;
          # `home-manager` config
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.mariusnygard = import ./home.nix;
          home-manager.sharedModules = pkgs.lib.attrValues self.homemanagerModules ++ [ inputs.mac-app-util.homeManagerModules.default ];
        }
      ];
    };
  };
}
