{ self, lib, withSystem, inputs, ... }:
let
  nixosSystemFor = system: module:
    let
      pkgs = withSystem system ({ ... }: import inputs.nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
        overlays = [ inputs.nur.overlay ];
      });
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
    desktop = nixosSystemFor "x86_64-linux" ./desktop;
    miniVm = nixosSystemFor "x86_64-linux"
      ({ pkgs, ... }: {


        programs.zsh.enable = true; #TODO: needed if i set default user shell to zsh
        users.users.mar = {
          isNormalUser = true;
          shell = pkgs.bash;
          extraGroups = [ "wheel" ];
          password = "123";
        };

        imports = [ self.nixosModules.nixvim ];
        myModules.myNixvim.enable = true;

        # programs.git.enable = true; #TODO: needed if i set default user shell to zsh
        system.stateVersion = "23.11";

      });
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
      miniVm = vmApp "miniVm";
    };

    # NixOS tests for nix-snapshotter.
    # nixosTests.snapshotter = import ./tests/snapshotter.nix;
    # nixosTests.kubernetes = import ./tests/kubernetes.nix;
    # nixosTests.k3s = import ./tests/k3s.nix;
    # nixosTests.k3s-external = import ./tests/k3s-external.nix;
    # nixosTests.k3s-rootless = import ./tests/k3s-rootless.nix;
  };
}
