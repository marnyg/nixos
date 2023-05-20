{ pkgs, lib, config, ... }:
let
  userType = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "User name";
      };
      homeManager = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to manage the user with Home Manager";
      };
      homeManagerConf = lib.mkOption {
        type = lib.types.attrs;
        default = { myHmModules.sharedDefaults.enable = true; };

        description = "Home Manager module configuration";
      };
    };
  };

  myMkUser = user: { config, pkgs, ... }: {

    modules.zsh.enable = true;
    modules.direnv.enable = true;
    modules.zellij.enable = true;
    modules.tmux.enable = true;
    modules.fzf.enable = true;
    modules.firefox.enable = true;
    modules.autorandr.enable = false;
    modules.bspwm.enable = false;
    modules.dunst.enable = true;
    modules.kitty.enable = true;
    myModules.git.enable = true;
    modules.newsboat.enable = true;
    modules.polybar.enable = false;
    modules.xmonad.enable = false;
    modules.spotifyd.enable = false;
    modules.other.enable = true;
    modules.myPackages.enable = true;
    modules.cloneDefaultRepos.enable = true;
  };

  anyHomeManagerUser = users: lib.any (user: user.homeManager) users;
in
{

  options.myModules.createUsers = {
    enable = lib.mkEnableOption "Create users";
    users = lib.mkOption {
      description = "List of users";
      type = lib.types.listOf userType;
      default = [{ name = "mar"; homeManager = true; }];
    };
    personalHomeManagerModules = lib.mkOption {
      description = "List of personal Home Manager modules";
      type = lib.types.listOf lib.types.attrs;
      default = [ ];
    };
  };

  config = lib.mkIf config.myModules.createUsers.enable {
    users.users = lib.listToAttrs (map
      (user: {
        name = user.name;
        value = {
          isNormalUser = true;
          shell = pkgs.zsh;
        };
      })
      config.myModules.createUsers.users);

    home-manager = lib.mkIf (anyHomeManagerUser config.myModules.createUsers.users) {
      useGlobalPkgs = true;
      useUserPackages = true;

      sharedModules = config.myModules.createUsers.personalHomeManagerModules;

      users = lib.listToAttrs (map (user: { name = user.name; value = myMkUser user; })
        (builtins.filter (user: user.homeManager) config.myModules.createUsers.users));
    };
  };

}
