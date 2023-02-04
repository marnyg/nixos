{
  description = "NixOS configuration";

  # All inputs for the system
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs";
    #my-nvim.url = "git+file:///home/nixos/git/nvim-conf";
    my-nvim.url = "github:marnyg/nvim-conf";
    #my-modules.url = "github:marnyg/nixos-modules";
    my-modules.url = "git+file:///home/nixos/git/nixos-modules";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    {
      nixosConfigurations = import ./systems inputs;
    } //
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = (import nixpkgs { inherit system; }); in
      {
        devShells = import ./flakeUtils/shell.nix pkgs;
        checks = import ./flakeUtils/checks.nix pkgs;
        formatter = pkgs.nixpkgs-fmt;
      });
}
