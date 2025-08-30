{
  imports = [
    ./nixvim
    ./agentic-dm
  ];
  perSystem = { pkgs, system, ... }: {
    packages.home-init = pkgs.writeShellApplication {
      name = "home-init";
      runtimeInputs = with pkgs; [ nix home-manager ];
      text = ''
        set -e

        echo "Setting up initial Home Manager configuration..."
        mkdir -p ~/.config/home-manager
        cat > ~/.config/home-manager/flake.nix << EOF
        {
          description = "Home Manager configuration";

          inputs = {
            nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
            home-manager.url = "github:nix-community/home-manager";
            home-manager.inputs.nixpkgs.follows = "nixpkgs";
            custom-modules.url = "github:marnyg/nixos";
            custom-modules.inputs.nixpkgs.follows = "nixpkgs";
          };

          outputs = { nixpkgs, home-manager, custom-modules, ... }:
            let
              system = "x86_64-linux";
              pkgs = nixpkgs.legacyPackages.${system};
            in {
              homeConfigurations.$USER = home-manager.lib.homeManagerConfiguration {
                inherit pkgs;
                modules = [
                  ./home.nix
                  { imports = custom-modules.hmModulesModules.x86_64-linux; }
                ];
              };
            };
        }
        EOF

        cat > ~/.config/home-manager/home.nix << EOF
        { config, pkgs, ... }:

        {
          home.username = "$USER";
          home.homeDirectory = "$HOME";
              
          home.stateVersion = "23.11";

          programs.home-manager.enable = true;

          home.packages = with pkgs; [
            # Add your desired packages here
            git
            vim
          ];

          # Add more configuration as needed
        }
        EOF

        echo "Running Home Manager install..."
        nix run  --extra-experimental-features nix-command --extra-experimental-features flakes home-manager/master -- init --switch

      '';
    };
  };
}
