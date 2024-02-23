{ ... }: {
  perSystem = { config, pkgs, ... }: {
    config = {
      mission-control.scripts = {
        r = {
          description = "reload direnv";
          exec = "direnv reload";
        };
        test = {
          description = "check";
          exec = "nix flake check";
        };
        fmt = {
          description = "Format the source tree";
          exec = config.treefmt.build.wrapper;
          category = "Dev Tools";
        };
      };

      devShells.default = pkgs.mkShell
        {
          buildInputs = [ pkgs.nixd pkgs.nil ];
          LSP_SERVERS = "nixd, nil_ls";
          shellHook = config.pre-commit.installationScript;
          inputsFrom = [ config.mission-control.devShell ];
        };

      pre-commit = {
        settings.hooks.nixpkgs-fmt.enable = true;
        settings.hooks.deadnix.enable = true;
        settings.hooks.nil.enable = true;
        settings.hooks.statix.enable = true;
        settings.hooks.typos.enable = true;
        settings.hooks.commitizen.enable = true;
        settings.hooks.yamllint.enable = true;
        settings.settings.statix.format = "stderr";
      };


      treefmt.config = {
        inherit (config.flake-root) projectRootFile;
        package = pkgs.treefmt;

        programs.nixpkgs-fmt.enable = true;
        programs.yamlfmt.enable = true;
      };
    };
  };
}
