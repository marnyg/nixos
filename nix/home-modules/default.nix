{ inputs, ... }:
{
  flake.homemanagerModules = rec {
    autorandr = ./autorandr/desktop.nix;
    bspwm = ./bspwm/bspwm.nix;
    dunst = ./dunst/dunst.nix;
    firefox = ./firefox.nix;
    git = ./git.nix;
    direnv = ./direnv.nix;
    kitty = ./kitty.nix;
    newsboat = ./newsboat.nix;
    polybar = ./polybar/polybar.nix;
    xmonad = ./xmonad;
    zellij = ./zellij.nix;
    tmux = ./tmux.nix;
    fzf = ./fzf.nix;
    zsh = ./zsh.nix;
    spotifyd = ./spotifyd.nix;
    other = ./other.nix;
    myPackages = ./myPackages.nix;
    cloneDefaultRepos = ./cloneDefaultRepos.nix;
    cloneWorkRepos = ./cloneWorkRepos.nix;
    sharedDefaults = ./sharedDefaults.nix;
    hyperland = ./hyperland.nix;
    wofi = ./wofi.nix;
    waybar = ./waybar.nix;
    lf = ./lf.nix;
    nur = inputs.nur.hmModules.nur;
    # all modules as a list
    all = [
      autorandr
      bspwm
      dunst
      firefox
      git
      direnv
      kitty
      newsboat
      polybar
      xmonad
      zellij
      tmux
      fzf
      zsh
      spotifyd
      other
      myPackages
      cloneDefaultRepos
      cloneWorkRepos
      sharedDefaults
      hyperland
      wofi
      waybar
      lf
      nur
    ];
  };

  perSystem = { pkgs, ... }: {
    packages.homeboot = pkgs.writeShellApplication {
      name = "home-init";
      runtimeInputs = with pkgs; [ nix home-manager ];
      text = /* bash */''
        set -e

        echo "Installing Home Manager..."
        nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
        nix-channel --update

        echo "Setting up initial Home Manager configuration..."
        mkdir -p ~/.config/home-manager
        cat > ~/.config/home-manager/flake.nix << EOF
        {
          description = "Home Manager configuration";

          inputs = {
            nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
            home-manager = {
              url = "github:nix-community/home-manager";
              inputs.nixpkgs.follows = "nixpkgs";
            };
            custom-modules = {
              url = "github:marnyg/nixos";
              inputs.nixpkgs.follows = "nixpkgs";
            };
          };

          outputs = { nixpkgs, home-manager, custom-modules, ... }:
            let
              system = "x86_64-linux";
              pkgs = nixpkgs.legacyPackages.\''${system};
            in {
              homeConfigurations.$USER = home-manager.lib.homeManagerConfiguration {
                inherit pkgs;
                modules = [
                  ./home.nix
                  {
                    imports = custom-modules.hmModulesModules.x86_64-linux;
                  }
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
        nix run home-manager/master --extra-experimental-features nix-command  --extra-experimental-features flakes -- init switch

        echo "Home Manager setup complete!"
        echo "You can now edit ~/.config/home-manager/home.nix to customize your environment."
        echo "After making changes, run 'home-manager switch' to apply them."
      '';
    };
  };
}

