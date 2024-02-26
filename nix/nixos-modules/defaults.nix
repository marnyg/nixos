{ pkgs, lib, config, ... }:
{
  options.myModules.defaults.enable = lib.mkEnableOption "Create users";

  config = lib.mkIf config.myModules.defaults.enable {

    nixpkgs.config.allowUnfree = true; #TODO remove?
    nixpkgs.config.permittedInsecurePackages = [ "nodejs-16.20.0" ]; #TODO remove? 

    environment.systemPackages = with pkgs; [ wget curl tmux ];

    # Enable nix flakes
    nix = {
      settings.auto-optimise-store = true;
      settings.experimental-features = [ "nix-command" "flakes" ];
    };

    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;

    system.stateVersion = "22.11";
  };
}
