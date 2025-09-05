# Home-manager modules index
{ ... }:

let
  # Program modules
  programModules = {
    # Terminal & Shell
    direnv = ./programs/direnv.nix;
    fish = ./programs/fish.nix;
    fzf = ./programs/fzf.nix;
    nushell = ./programs/nushell.nix;
    tmux = ./programs/tmux.nix;
    zellij = ./programs/zellij.nix;
    zsh = ./programs/zsh.nix;

    # Editors
    nixvim = ./programs/nixvim.nix;
    nvim = ./programs/nvim.nix;

    # Terminal emulators
    ghostty = ./programs/ghostty.nix;
    kitty = ./programs/kitty.nix;

    # Browsers
    firefox = ./programs/firefox.nix;
    qutebrowser = ./programs/qutebrowser.nix;

    # File managers
    lf = ./programs/lf.nix;

    # Development tools
    git = ./programs/git.nix;

    # Desktop environments - X11
    bspwm = ./programs/bspwm/bspwm.nix;
    xmonad = ./programs/xmonad;
    polybar = ./programs/polybar/polybar.nix;
    dunst = ./programs/dunst/dunst.nix;
    autorandr = ./programs/autorandr/desktop.nix;

    # Desktop environments - Wayland
    hyperland = ./programs/hyperland.nix;
    waybar = ./programs/waybar.nix;
    wofi = ./programs/wofi.nix;

    # Other programs
    newsboat = ./programs/newsboat.nix;
  };

  # Service modules
  serviceModules = {
    cloneDefaultRepos = ./services/cloneDefaultRepos.nix;
    cloneWorkRepos = ./services/cloneWorkRepos.nix;
    mcphub = ./services/mcphub.nix;
    s3fs = ./services/s3fs.nix;
    spotifyd = ./services/spotifyd.nix;
  };

  # Core modules
  coreModules = {
    sharedDefaults = ./sharedDefaults.nix;
    sharedShellConfig = ./sharedShellConfig.nix;
    myPackages = ./myPackages.nix;
    other = ./other.nix;
    secrets = ./secrets/secretsModule.nix;
  };

  # Profile modules

in
programModules // serviceModules // coreModules
# Note: profileModules are NOT included in shared modules
# They are only imported when explicitly requested via user profiles
