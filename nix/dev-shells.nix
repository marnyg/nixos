{ inputs, ... }:
{
  perSystem = { config, pkgs, system, ... }: {
    config = {

      devenv.shells.default = {
        packages = [
          config.treefmt.build.wrapper
          inputs.agenix.packages.${system}.default
        ];

        enterShell = ''
          echo "Welcome to the repository!"
          echo "Available commands:"
          echo "  rebuild-switch <system> # To rebuild and switch a nixos system
          #echo "  nix run .#changelog     - Generate CHANGELOG.md using recent commits"
          #echo "  nix run .#check"
          #echo "  nix run .#fmt           - Auto-format the source tree using treefmt"
          #echo "  nix run .#reload"
          #echo "  nix run .#test          - Run and watch 'cargo test'"
          #echo "  nix run .#w             - Compile and watch the project"
        '';

        processes = {
          argocd = {
            exec = ''

            '';
          };
        };

        git-hooks = {
          hooks.nixpkgs-fmt.enable = true;
          hooks.deadnix.enable = true;
          hooks.nil.enable = true;
          hooks.typos.enable = true;
          hooks.commitizen.enable = true;
          hooks.yamlfmt.enable = true;
          hooks.statix.enable = true;
          hooks.statix.settings.format = "stderr";
          hooks.statix.args = [ "--config" "${pkgs.writeText "conf.toml" "disabled = [ repeated_keys ]"}" ];
          hooks.typos.settings.ignored-words = [ "noice" ];
          hooks.typos.stages = [ "manual" ];
        };
      };

      treefmt.config = {
        programs.nixpkgs-fmt.enable = true;
        programs.yamlfmt.enable = true;
      };

    };
  };
}
