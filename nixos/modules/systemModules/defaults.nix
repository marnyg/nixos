{ pkgs, inputs, lib, config, ... }:
{
  options.myModules.defaults.enable = lib.mkEnableOption "Create users";
  #options.myModules.nixpkgsOverlays = lib.mkOption "Create users";

  config = lib.mkIf config.myModules.defaults.enable {
    nixpkgs.overlays = [ inputs.nur.overlay ]; #TODO how do i do this?
    nixpkgs.config.allowUnfree = true; #TODO remove?
    
    nixpkgs.config.permittedInsecurePackages = [
    "nodejs-16.20.0" #TODO remove?
    ];
    environment.systemPackages = with pkgs; [ wget curl lf ];

    # Enable nix flakes
    nix = {
      settings.auto-optimise-store = true;
      package = pkgs.nixUnstable;
      settings.experimental-features = [ "nix-command" "flakes" ];
    };

    system.stateVersion = "22.11";
  };
}
