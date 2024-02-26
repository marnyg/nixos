{ inputs, ... }:
{
  flake.homemanagerModules = {
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
  };
}
