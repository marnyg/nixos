{ }
# { inputs, self, ... }:
# let
#   pkgs = import inputs.nixpkgs { inherit inputs; system = "x86_64-linux"; };
# in
# {
#   flake.homeConfigurations.mar = inputs.home-manager.lib.homeManagerConfiguration
#     {
#       nix = {
#         package = pkgs.nix;
#         settings.experimental-features = [ "nix-command" "flakes" ];
#       };
#       users.users.yourname.shell = pkgs.zsh;
#
#       home.sessionVariables = {
#         NIXPKGS_ALLOW_UNFREE = "1";
#       };
#
#       # Let Home Manager install and manage itself.
#       programs.home-manager.enable = true;
#       imports = [
#         {
#           myHmModules.sharedDefaults.enable = true;
#
#           modules.zsh.enable = true;
#           modules.direnv.enable = true;
#           modules.zellij.enable = false;
#           modules.tmux.enable = true;
#           modules.fzf.enable = true;
#           modules.firefox.enable = true;
#           modules.autorandr.enable = false;
#           modules.bspwm.enable = false;
#           modules.dunst.enable = false;
#           modules.kitty.enable = true;
#           myModules.git.enable = true;
#           modules.newsboat.enable = false;
#           modules.polybar.enable = false;
#           modules.xmonad.enable = false;
#           modules.spotifyd.enable = false;
#           modules.other.enable = false;
#           modules.myPackages.enable = true;
#           modules.cloneDefaultRepos.enable = true;
#           modules.lf.enable = true;
#           programs.yazi.enable = true;
#         }
#       ]
#       ++ self.homemanagerModules.x86_64-linux;
#     };
# }
