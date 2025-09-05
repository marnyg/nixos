{ pkgs, lib, config, ... }:
{
  options.myModules.defaults.enable = lib.mkEnableOption "Create users";

  config = lib.mkIf config.myModules.defaults.enable {

    environment.systemPackages = with pkgs; [ wget curl tmux ];

    # Enable nix flakes
    nix = {
      settings.auto-optimise-store = true;
      settings.experimental-features = [ "nix-command" "flakes" "pipe-operators" ];
    };

    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;

    system.stateVersion = lib.mkDefault "22.11";
  };
}
