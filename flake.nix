{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nur.url = "github:nix-community/NUR";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";

    my-nvim.url = "path:./nvim";
    my-modules.url = "path:./modules";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    {
      nixosConfigurations = import ./nixos/systems inputs;
    } //
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system:
      let pkgs = (import nixpkgs { inherit system; }); in
      {
        devShells = import ./flakeUtils/shell.nix pkgs;
        checks = import ./flakeUtils/checks.nix { inherit inputs pkgs; };
        formatter = pkgs.nixpkgs-fmt;
        test = pkgs.nixosTest (import ./nixos/tests/mini2.nix pkgs);
      });
}
