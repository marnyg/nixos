{ ... }: {
  perSystem = { config, ... }:
    {
      config = {
        treefmt.config = {
          programs.nixpkgs-fmt.enable = true;
          programs.yamlfmt.enable = true;
        };

        devenv.shells.agentic-dm = {
          name = "my-project";
          imports = [ ];
          languages.elixir.enable = true;
          #languages.gleam.enable = true;
          # packages = with pkgs; [
          #   gleam
          #   erlang
          # ];
        };
      };
    };
}
