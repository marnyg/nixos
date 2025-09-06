{ lib, ... }:
{
  options.flake-parts.homeModules = lib.mkOption {
    type = lib.types.attrs;
    default = { };
    description = "Internal home-manager modules registry";
  };

  options.flake-parts.secretPaths = lib.mkOption {
    type = lib.types.attrs;
    default = { };
    description = "Internal secret paths registry";
  };

  config = {
    # Export as proper home-manager modules for external consumption
    flake.homeManagerModules = {
      default = { ... }: {
        imports = [
          # All home modules available for users
          ./sharedDefaults.nix
          ./sharedShellConfig.nix
          ./myPackages.nix
          ./other.nix
          ./secrets/secretsModule.nix

          # Programs
          ./programs/direnv.nix
          ./programs/fish.nix
          ./programs/fzf.nix
          ./programs/nushell.nix
          ./programs/tmux.nix
          ./programs/zellij.nix
          ./programs/zsh.nix
          ./programs/nixvim.nix
          ./programs/nvim.nix
          ./programs/ghostty.nix
          ./programs/kitty.nix
          ./programs/firefox.nix
          ./programs/qutebrowser.nix
          ./programs/lf.nix
          ./programs/git.nix
          ./programs/bspwm/bspwm.nix
          ./programs/xmonad
          ./programs/polybar/polybar.nix
          ./programs/dunst/dunst.nix
          ./programs/autorandr/desktop.nix
          ./programs/hyprland.nix
          ./programs/waybar.nix
          ./programs/wofi.nix
          ./programs/rofi.nix
          ./programs/newsboat.nix

          # Services
          ./services/cloneDefaultRepos.nix
          ./services/cloneWorkRepos.nix
          ./services/mcphub.nix
          ./services/s3fs.nix
          ./services/spotifyd.nix
        ];
      };
    };

    # Internal registry for use within the flake
    flake-parts.homeModules = {
      profiles = {
        desktop = ./profiles/desktop.nix;
        developer = ./profiles/developer.nix;
        minimal = ./profiles/minimal.nix;
      };

      secrets = ./secrets/secrets.nix;
    };

    flake-parts.secretPaths = {
      claudeToken = ./secrets/claudeToken.age;
      openrouterToken = ./secrets/openrouterToken.age;
      tailscaleAuthKey = ./secrets/tailscaleAuthKey.age;
    };
  };
}

