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
          echo
          #TODO: add collor to the output with special chars like 🐧 or 🍎 and collored text by using \033[0;31m
          echo -e "\033[0;32mWelcome to the repository!\033[0m"
          echo -e "\033[0;32mAvailable commands:\033[0m"
          echo "  sudo nixos-rebuild switch --flake .#<system>" # To rebuild and switch a nixos system"
          echo "  darwin-rebuild switch --flake .#mac" # To rebuild and switch a darwin system"
          echo
        '';

        # processes = {
        #   argocd = {
        #     exec = ''
        #
        #     '';
        #   };
        # };

        git-hooks = {
          hooks.nixpkgs-fmt.enable = true;
          hooks.deadnix.enable = true;
          hooks.deadnix.settings.quiet = true;
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
