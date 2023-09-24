{
  description = "A very basic flake";
  inputs = {
    #nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    my-nvim.url = "github:marnyg/nixos?dir=nvim";
    #my-nvim.url = "path:/home/mar/git/nixos/nvim";
    #my-nvim.url = "git+file://../../?dir=nvim";
    home-manager.url = "github:nix-community/home-manager";
    #home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, my-nvim, flake-utils, home-manager }:
    flake-utils.lib.eachDefaultSystem (system:
      {
        hmModulesModules = [
          (import ./homemanager/autorandr/desktop.nix)
          (import ./homemanager/bspwm/bspwm.nix)
          (import ./homemanager/dunst/dunst.nix)
          (import ./homemanager/firefox.nix)
          (import ./homemanager/git.nix)
          (import ./homemanager/direnv.nix)
          (import ./homemanager/kitty.nix)
          (import ./homemanager/newsboat.nix)
          (import ./homemanager/polybar/polybar.nix)
          (import ./homemanager/xmonad)
          (import ./homemanager/zellij.nix)
          (import ./homemanager/tmux.nix)
          (import ./homemanager/fzf.nix)
          (import ./homemanager/zsh.nix)
          (import ./homemanager/spotifyd.nix)
          (import ./homemanager/other.nix)
          (import ./homemanager/myPackages.nix)
          (import ./homemanager/cloneDefaultRepos.nix)
          (import ./homemanager/sharedDefaults.nix)
          (import ./homemanager/hyperland.nix)
          (import ./homemanager/wofi.nix)
          (import ./homemanager/waybar.nix)
          (import ./homemanager/lf.nix)
        ];
        #hmModules = {
        #  autorandr = import ./homemanager/autorandr/desktop.nix;
        #  bspwm = import ./homemanager/bspwm/bspwm.nix;
        #  dunst = import ./homemanager/dunst/dunst.nix;
        #  firefox = import ./homemanager/firefox.nix;
        #  git = import ./homemanager/git.nix;
        #  direnv = import ./homemanager/direnv.nix;
        #  kitty = import ./homemanager/kitty.nix;
        #  newsboat = import ./homemanager/newsboat.nix;
        #  polybar = import ./homemanager/polybar/polybar.nix;
        #  xmonad = import ./homemanager/xmonad;
        #  zellij = import ./homemanager/zellij.nix;
        #  tmux = import ./homemanager/tmux.nix;
        #  fzf = import ./homemanager/fzf.nix;
        #  zsh = import ./homemanager/zsh.nix;
        #  spotifyd = import ./homemanager/spotifyd.nix;
        #  other = import ./homemanager/other.nix;
        #  myPackages = import ./homemanager/myPackages.nix;
        #  cloneDefaultRepos = import ./homemanager/cloneDefaultRepos.nix;
        #  sharedDefaults = import ./homemanager/sharedDefaults.nix;
        #};
        nixosModules = {
          syncthing = import ./systemModules/syncthingService.nix;
          tailscale = import ./systemModules/tailscaleService.nix;
          wsl = import ./systemModules/wsl.nix;
          users = import ./systemModules/users.nix;
          defaults = import ./systemModules/defaults.nix;
          nvim = my-nvim.nixosModule2."${system}";
        };
        devShells = import ./flakeUtils/shell.nix (import nixpkgs { inherit system; });
        checks = import ./flakeUtils/checks.nix (import nixpkgs { inherit system; });
        formatter = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
      });
}
