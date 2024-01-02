{ config, pkgs, ... }:
{
  imports = [
    inputs.nixos-wsl.nixosModules.wsl
    inputs.home-manager.nixosModules.home-manager
  ] ++ (builtins.attrValues inputs.my-modules.nixosModules.x86_64-linux);

  # Nix settings, auto cleanup and enable flakes
  #nix = {
  #  settings.auto-optimise-store = true;
  #  gc.automatic = true;
  #  gc.dates = "weekly";
  #  package = pkgs.nixUnstable;
  #  extraOptions = "experimental-features = nix-command flakes ";
  #  settings.experimental-features = [ "nix-command" "flakes" ];
  #};

  # Set your time zone.
  time.timeZone = "Europe/Oslo";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  environment.systemPackages = with pkgs; [ wget curl lf htop git tmux ];
  system.stateVersion = "22.11";
}
