{ pkgs, lib, config, ... }:
{
  options.modules.my.defaults.enable = lib.mkEnableOption "Create users";

  config = lib.mkIf config.modules.my.defaults.enable {

    environment.systemPackages = with pkgs; [ wget curl tmux ];

    # Enable nix flakes
    #    nix = {
    #  settings.auto-optimise-store = true;
    #  settings.experimental-features = [ "nix-command" "flakes" "pipe-operators" ];
    #};

    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;

    # Cache sudo authentication for 30 minutes, shared across all
    # terminals/sessions for the same user (instead of the default per-tty).
    security.sudo.extraConfig = ''
      Defaults timestamp_type=global
      Defaults timestamp_timeout=30
    '';

    system.stateVersion = lib.mkDefault "23.11";
  };
}
