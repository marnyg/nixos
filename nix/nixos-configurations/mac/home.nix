{ pkgs, inputs, ... }:
let
  # Import shared user configurations  
  userConfigs = import ../home-modules/userConfigurations.nix { inherit inputs; };
in
userConfigs.mac // {

  home.packages = with pkgs; [
    coreutils
    curl
    wget
    slack
    teams-for-linux
    # outlook
    #    github-cli

    #m-cli # useful macOS CLI commands
  ];

}
