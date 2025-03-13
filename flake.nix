{
  description = "NixOS configuration";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";


    home-manager.url = "github:nix-community/home-manager";
    # home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nur.url = "github:nix-community/NUR";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";


    treefmt-nix.url = "github:numtide/treefmt-nix";
    devenv.url = "github:cachix/devenv";
    agenix-shell.url = "github:aciceri/agenix-shell";

    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs = { nixpkgs.follows = "nixpkgs"; };

    nixvim.url = "github:nix-community/nixvim";
    # nixvim.url = "github:nix-community/nixvim/nixos-23.11";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    microvm.url = "github:astro/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin";
    mac-app-util.url = "github:hraban/mac-app-util";




    # tmp fix for broken neorg, see: 
    #  https://github.com/NixOS/nixpkgs/pull/302442
    #  https://github.com/nix-community/nixvim/issues/1395
    # nixpkgs-stabil.url = "github:NixOS/nixpkgs/nixos-23.11";
    neorg-overlay.url = "github:nvim-neorg/nixpkgs-neorg-overlay";
    ghostty-darwin-overlay.url = "github:kbwhodat/ghostty-nix-darwin";

  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; }
      {
        systems = [ "x86_64-linux" "aarch64-darwin" ];
        imports = [
          inputs.treefmt-nix.flakeModule
          inputs.devenv.flakeModule
          ./pkgs
          ./nix
          # ./darwin.nix
        ];

      };

}
