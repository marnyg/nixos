{
  description = "An example of neovim configuration";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    vim-extra-plugins.url = "github:dearrrfish/nixpkgs-vim-extra-plugins";
    #vim-extra-plugins.url = "github:m15a/nixpkgs-vim-extra-plugins";
  };

  outputs = { self, nixpkgs, vim-extra-plugins, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ vim-extra-plugins.overlays.default ];
        };
      in
      {
        devShells = import ./flakeUtils/shell.nix { inherit pkgs; };
        checks = import ./flakeUtils/checks.nix { inherit pkgs; };
        formatter = pkgs.nixpkgs-fmt;

        # nix build .
        packages.default = import ./nix/newnvim.nix { inherit pkgs; };

        # nix run .
        apps.default = flake-utils.lib.mkApp {
          drv = import ./nix/newnvim.nix { inherit pkgs; };
          name = "nvim";
        };
        #nixosModule = import ./nixosModule.nix;
        nixosModule2 = (import ./nixosModule.nix pkgs);
      }
    );

}
