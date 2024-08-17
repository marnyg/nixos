{ ... }: {

  perSystem = { config, pkgs, ... }: {
    config = {

      devShells.default = pkgs.mkShell
        {
          shellHook = config.pre-commit.installationScript;
          inputsFrom = [ config.just-flake.outputs.devShell ];
        };

      just-flake.features = {
        treefmt.enable = true;
        rust.enable = true;
        convco.enable = true;
        scripts = {
          enable = true;
          justfile = ''
            reload:
              direnv reload
            check:
              nix flake check
            buildWslImage:
              nix build .#wslImage
          '';
        };
      };

      pre-commit = {
        settings.hooks.nixpkgs-fmt.enable = true;
        settings.hooks.deadnix.enable = true;
        settings.hooks.nil.enable = true;
        settings.hooks.statix.enable = true;
        settings.hooks.statix.args = [ "--config" "${pkgs.writeText "conf.toml" "disabled = [ repeated_keys ]"}" ];
        settings.hooks.typos.enable = true;
        settings.hooks.commitizen.enable = true;
        settings.hooks.yamllint.enable = true;
        settings.hooks.yamllint.settings.preset = "relaxed";
        settings.hooks.statix.settings.format = "stderr";
        settings.hooks.typos.settings.ignored-words = [ "noice" ];
        settings.hooks.typos.stages = [ "manual" ];
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
