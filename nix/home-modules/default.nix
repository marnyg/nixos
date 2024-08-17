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
    # all = [
    #   autorandr
    #   bspwm
    #   dunst
    #   firefox
    #   git
    #   direnv
    #   kitty
    #   newsboat
    #   polybar
    #   xmonad
    #   zellij
    #   tmux
    #   fzf
    #   zsh
    #   spotifyd
    #   other
    #   myPackages
    #   cloneDefaultRepos
    #   cloneWorkRepos
    #   sharedDefaults
    #   hyperland
    #   wofi
    #   waybar
    #   lf
    #   nur
    # ];
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
                    imports = custom-modules.homemanagerModules.all;
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
              
          # Add more configuration as needed
          nix = {
            package = pkgs.nix;
            settings.experimental-features = [ "nix-command" "flakes" ];
          };

          imports = [
            {
              myHmModules.sharedDefaults.enable = true;

              modules.zsh.enable = true;
              modules.direnv.enable = true;
              modules.zellij.enable = false;
              modules.tmux.enable = true;
              modules.fzf.enable = true;
              modules.firefox.enable = true;
              modules.autorandr.enable = false;
              modules.bspwm.enable = false;
              modules.dunst.enable = false;
              modules.kitty.enable = true;
              myModules.git.enable = true;
              modules.newsboat.enable = false;
              modules.polybar.enable = false;
              modules.xmonad.enable = false;
              modules.spotifyd.enable = false;
              modules.other.enable = false;
              modules.myPackages.enable = true;
              modules.cloneDefaultRepos.enable = true;
              modules.lf.enable = true;
              programs.yazi.enable = true;
            }
          ];
        }
        EOF

        echo "Running Home Manager install..."
        rm ~/.profile ~/.bashrc
        nix run home-manager/master --extra-experimental-features nix-command  --extra-experimental-features flakes -- init switch  --extra-experimental-features nix-command  --extra-experimental-features flakes 

        echo "Home Manager setup complete!"
        echo "You can now edit ~/.config/home-manager/home.nix to customize your environment."
        echo "After making changes, run 'home-manager switch' to apply them."
        echo 
        echo "sudo bash -c 'echo /home/mar/.nix-profile/bin/zsh >> /etc/shells' && chsh -s ~/.nix-profile/bin/zsh"
      '';
    };
  };
}

