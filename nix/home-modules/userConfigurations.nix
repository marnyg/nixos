{ inputs, ... }:
{
  # Standard desktop user configuration with GUI applications
  desktop = {
    imports = [ inputs.agenix.homeManagerModules.default ];
    programs.ncspot.enable = true;

    modules.sharedDefaults.enable = true;
    modules.nixvim.enable = true;
    modules.fish.enable = true;
    modules.direnv.enable = true;
    modules.zellij.enable = false;
    modules.tmux.enable = true;
    modules.firefox.enable = true;
    modules.autorandr.enable = false;
    modules.bspwm.enable = true;
    modules.dunst.enable = false;
    modules.kitty.enable = false;
    modules.ghostty.enable = true;
    modules.git.enable = true;
    modules.newsboat.enable = false;
    modules.polybar.enable = false;
    modules.xmonad.enable = false;
    modules.hyperland.enable = true;
    modules.spotifyd.enable = false;
    modules.other.enable = false;
    modules.myPackages.enable = true;
    modules.cloneDefaultRepos.enable = true;
    modules.qutebrowser.enable = true;
    modules.secrets.enable = true;

    programs.yazi.enable = true;
  };

  # Laptop configuration variant
  laptop = {
    modules.sharedDefaults.enable = true;
    modules.nixvim.enable = true;
    modules.zsh.enable = true;
    modules.direnv.enable = true;
    modules.zellij.enable = false;
    modules.tmux.enable = true;
    modules.fzf.enable = true;
    modules.firefox.enable = true;
    modules.autorandr.enable = false;
    modules.bspwm.enable = true;
    modules.dunst.enable = false;
    modules.kitty.enable = true;
    modules.git.enable = true;
    modules.newsboat.enable = false;
    modules.polybar.enable = false;
    modules.xmonad.enable = false;
    modules.hyperland.enable = true;
    modules.spotifyd.enable = false;
    modules.other.enable = false;
    modules.myPackages.enable = true;
    modules.cloneDefaultRepos.enable = false;
    modules.lf.enable = true;
  };

  # WSL configuration for Windows Subsystem for Linux
  wsl = { config, ... }: {
    imports = [ inputs.agenix.homeManagerModules.default ];
    modules.secrets.enable = true;
    modules.sharedDefaults.enable = true;
    modules.nixvim.enable = true;

    # WSL-specific services
    myServices.s3fs.enable = true;
    myServices.s3fs.keyId = "";
    myServices.s3fs.accessKey = "";

    modules.zsh.enable = true;
    modules.direnv.enable = true;
    modules.zellij.enable = false;
    modules.tmux.enable = true;
    modules.firefox.enable = true;
    modules.autorandr.enable = false;
    modules.bspwm.enable = false;
    modules.dunst.enable = false;
    modules.kitty.enable = false;
    modules.ghostty.enable = true;
    modules.git.enable = true;
    modules.newsboat.enable = false;
    modules.polybar.enable = false;
    modules.xmonad.enable = false;
    modules.spotifyd.enable = false;
    modules.other.enable = false;
    modules.myPackages.enable = true;
    modules.cloneDefaultRepos.enable = true;
    modules.services.cloneWorkRepos = {
      enable = false;
      gitDir = "${config.home.homeDirectory}/git";
      repoInfo = {
        sendra = {
          key = "${config.home.homeDirectory}/.ssh/id_rsa";
          repos = [ ];
        };
        hiplog = {
          key = "${config.home.homeDirectory}/.ssh/id_ed25519";
          repos = [ ];
        };
      };
    };
    modules.lf.enable = true;

    programs.yazi.enable = true;
  };

  # macOS configuration
  mac = {
    imports = [ inputs.agenix.homeManagerModules.default ];

    home.stateVersion = "23.05";
    home.homeDirectory = "/Users/mariusnygard";

    programs.ncspot.enable = true;

    modules.sharedDefaults.enable = false;
    modules.zsh.enable = false;
    modules.fish.enable = true;
    modules.direnv.enable = true;
    modules.myPackages.enable = true;
    modules.cloneDefaultRepos.enable = false;
    modules.tmux.enable = true;
    modules.firefox.enable = true;
    modules.git.enable = true;
    modules.kitty.enable = true;
    modules.spotifyd.enable = true;
    modules.secrets.enable = true;
    modules.ghostty.enable = true;
    modules.ghostty.fontsize = 14;

    programs.yazi.enable = true;
    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;
    programs.htop.enable = true;
    programs.htop.settings.show_program_path = true;

    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };
}
