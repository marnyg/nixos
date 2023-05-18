{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nur.url = "github:nix-community/NUR";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    #nixt.url = "github:nix-community/nixt";
    #nixt.flake = true;

    my-nvim.url = "path:./nvim";
    my-modules.url = "path:./nixos/modules";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:

    let pkgs = (import nixpkgs { system = "x86_64-linux"; }); in
    {
      nixosConfigurations = import ./nixos/systems inputs;
      #mytest = (import ./nixos/tests/unit/firstUnitTest.nix { self = (self); pkgs = pkgs; }); 
    } //
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system:
      let pkgs = (import nixpkgs { inherit system; }); in
      {
        apps.default = {
          type = "app";
          program = "${pkgs.coreutils}/bin/echo";
        };

        #use with `nix run .#testrun my echo command`
        apps.testrun = {
          type = "app";
          program = "${pkgs.coreutils}/bin/echo";
        };

        #apps.runUnitTests = {
        #  type = "app";
        #  program = "${inputs.nixt.x86_64-linux.app.packages.default}/bin/nixt";
        #};

        #use by running `nix develop`
        devShells.default = import ./flakeUtils/shell.nix { inherit pkgs self; };
        checks = import ./flakeUtils/checks.nix { inherit inputs pkgs self; };
        formatter = pkgs.nixpkgs-fmt;
      });
}
