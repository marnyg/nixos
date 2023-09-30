{
  description = "NixOS configuration";

  inputs = {
    #nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.05";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nur.url = "github:nix-community/NUR";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    my-nvim.url = "path:./nvim";
    my-nvim.inputs.nixpkgs.follows = "nixpkgs";

    my-modules.url = "path:./nixos/modules";
    my-modules.inputs.my-nvim.url = "path:./nvim";
    my-modules.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:

    let pkgs = (import nixpkgs { system = "x86_64-linux"; }); in
    {
      nixosConfigurations = import ./nixos/systems inputs;
      test = builtins.fromJSON ''{"asd":"sd"}'';
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

        #use by running `nix develop`
        devShells.default = import ./flakeUtils/shell.nix { inherit pkgs self; };
        checks = import ./flakeUtils/checks.nix { inherit inputs pkgs self; };
        formatter = pkgs.nixpkgs-fmt;
      });
}
