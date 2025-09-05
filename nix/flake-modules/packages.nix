# Packages and overlays flake module
{ inputs, ... }:

{
  imports = [
    inputs.treefmt-nix.flakeModule
    # Import the pkgs directory directly as a flake-parts module
    ../../pkgs
  ];

  perSystem = { config, pkgs, ... }: {
    # Add home-manager modules export package
    packages.homemanagerModules = pkgs.runCommand "homemanager-modules" { } ''
      mkdir -p $out
      cp -r ${../../modules/home}/* $out/
    '';

    # Formatter configuration
    treefmt.config = {
      projectRootFile = "flake.nix";
      programs = {
        nixpkgs-fmt.enable = true;
        prettier.enable = true;
        shellcheck.enable = true;
        shfmt.enable = true;
      };
    };

    # Formatter shortcut
    formatter = config.treefmt.build.wrapper;
  };
}
