{
  description = "NixOS configuration";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs";
    # nixpkgs-old for this issue on darwin:
    # https://github.com/nixos/nixpkgs/issues/450861
    nixpkgs-old.url = "github:NixOS/nixpkgs/c9bd50a653957ee895ff8b6936864b7ece0a7fb6";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nur.url = "github:nix-community/NUR";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    agenix-shell.url = "github:aciceri/agenix-shell";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";

    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs = { nixpkgs.follows = "nixpkgs"; };

    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    microvm.url = "github:astro/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util";

    mcphub-nvim.url = "github:ravitemer/mcphub.nvim"; # is broken, using pin until fixed
    mcphub.url = "github:ravitemer/mcp-hub";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        # Import the reorganized configuration structure
        ./nix
      ];
    };
}
