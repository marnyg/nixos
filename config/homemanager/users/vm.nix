{ config, pkgs, ... }:
{
  users.users.vm = {
    isNormalUser = true;
    extraGroups = [ "docker" "networkmanager" "wheel" ]; # Enable ‘sudo’ for the user.
    initialHashedPassword = "HNTH57eGshHyQ"; #test
    shell = pkgs.zsh;
  };

  # home-manager.users.vm= {
  #   imports = [ ./mar.nix ];
  # };
}
