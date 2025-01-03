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
        # type = lib.types.attrs;
        default = { myHmModules.sharedDefaults.enable = true; };

        description = "Home Manager module configuration";
      };
    };
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
  };

  config = lib.mkIf config.myModules.createUsers.enable {
    users.users = lib.listToAttrs (map
      (user: {
        name = user.name;
        value = {
          isNormalUser = lib.mkDefault true;
          shell = pkgs.nushell; #todo why: because when wsl it will create user with bash as shell. but i dont know why mkDefault is not working
          extraGroups = [ "wheel" ];
        };
      })
      config.myModules.createUsers.users);
    programs.zsh.enable = true; #TODO: needed if i set default user shell to zsh

    home-manager = lib.mkIf (anyHomeManagerUser config.myModules.createUsers.users) {
      useGlobalPkgs = true;
      useUserPackages = true;

      #sharedModules = lib.attrValues config.myHomemanagerModules.modules;

      users = lib.listToAttrs (map
        (user: { name = user.name; value = user.homeManagerConf; })
        (builtins.filter
          (user: user.homeManager)
          config.myModules.createUsers.users));
    };
  };

}
