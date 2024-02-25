#inputs:
#let
#  system = "x86_64-linux";
#  myModules = (builtins.attrValues inputs.my-modules.nixosModules.x86_64-linux);
#  homeManagerModule = inputs.home-manager.nixosModules.home-manager;
#  wslModule = inputs.nixos-wsl.nixosModules.wsl;
#
#  additionalModules = myModules ++ [ homeManagerModule wslModule ];
#in
#{
#  #desktop = mkSystem (import ./desktop/mar.nix);
#  #laptop= mkSystem (import ./laptop/default.nix);
#
#  laptop = inputs.nixpkgs.lib.nixosSystem {
#    inherit system;
#    specialArgs = { inherit inputs; };
#    modules = [ (import ./laptop/default.nix) ] ++ additionalModules;
#  };
#
#  #mkSystem (import ./laptop/default.nix);
#  #wsl = mkSystem (import ./wsl.nix);
#  #la = myModules;
#
#  wsl = inputs.nixpkgs.lib.nixosSystem {
#    inherit system;
#    specialArgs = { inherit inputs; };
#    modules = [ (import ./wslRefac.nix) ] ++ additionalModules;
#  };
#  #wsl2 = inputs.nixpkgs.lib.nixosSystem {
#  #  inherit system;
#  #  specialArgs = { inherit inputs; };
#  #  modules = [ (import ./wsl.nix) ];
#  #};
#
#  #pi= mkSystem (import ./wsl.nix);
#}

{ self, lib, withSystem, ... }:
let
  nixosSystemFor = system: module:
    let
      pkgs = withSystem system ({ pkgs, ... }: pkgs);
      #examples = withSystem system ({ examples, ... }: examples);
      #k8sResources = withSystem system ({ k8sResources, ... }: k8sResources);

    in
    lib.nixosSystem {
      inherit system;
      specialArgs = { inherit lib; inputs = self.inputs; };
      modules = [
        { _module.args = { pkgs = lib.mkForce pkgs; }; }
        self.nixosModules.default
        module
      ];
    };

  vmApp = name: {
    type = "app";
    program = "${self.nixosConfigurations.${name}.config.system.build.vm}/bin/run-nixos-vm";
  };

in
{

  /* NixOS config for a VM to quickly try out nix-snapshotter.

     ```sh
     nixos-rebuild build-vm --flake .#vm
     ```
  */
  flake.nixosConfigurations = {
    wsl = nixosSystemFor "x86_64-linux" ./wslRefac.nix;
    laptop = nixosSystemFor "x86_64-linux" ./laptop;
  };

  perSystem = { ... }: {
    /* A convenient `apps` target to run a NixOS VM to quickly try out
      nix-snaphotter without having `nixos-rebuild`.

      ```sh
      nix run .#vm
      ```
    */
    apps = {
      wsl = vmApp "wsl";
      laptop = vmApp "laptop";
    };

    # NixOS tests for nix-snapshotter.
    # nixosTests.snapshotter = import ./tests/snapshotter.nix;
    # nixosTests.kubernetes = import ./tests/kubernetes.nix;
    # nixosTests.k3s = import ./tests/k3s.nix;
    # nixosTests.k3s-external = import ./tests/k3s-external.nix;
    # nixosTests.k3s-rootless = import ./tests/k3s-rootless.nix;
  };
}
