# NixOS User Management Module
# This module handles the creation of system users and optionally configures home-manager for them
{ pkgs, lib, config, inputs, ... }:

let
  cfg = config.my.users;

  # User option type definition
  userOptionType = lib.types.submodule {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to enable this user on the system";
      };

      enableHome = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to manage this user with Home Manager";
      };

      profiles = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "List of profiles to apply to this user";
      };

      extraHomeModules = lib.mkOption {
        type = lib.types.listOf lib.types.anything;
        default = [ ];
        description = "Additional home-manager modules to include for this user";
      };

      extraSystemConfig = lib.mkOption {
        type = lib.types.attrs;
        default = { };
        description = "Additional system-level configuration for this user";
      };
    };
  };

  # Available users registry
  userRegistry = {
    users = {
      mar = ../../../users/mar;
      testUser = ../../../users/testUser;
    };
  };

  # Get enabled users
  enabledUsers = lib.filterAttrs (_name: cfg: cfg.enable) cfg;

  # Get users with home-manager enabled
  homeManagerUsers = lib.filterAttrs (_name: cfg: cfg.enable && cfg.enableHome) cfg;

  # Check if any user has home-manager enabled
  anyHomeManagerUser = (lib.length (lib.attrNames homeManagerUsers)) > 0;

  # Build system user configuration
  buildSystemUser = name: userCfg:
    let
      userPath = userRegistry.users.${name};
      systemConfigFn = import "${userPath}/system.nix";
      systemConfig = systemConfigFn { inherit pkgs config lib inputs; };
    in
    systemConfig // userCfg.extraSystemConfig;

  # Build home-manager configuration
  buildHomeConfig = name: userCfg:
    let

      # Collect profile modules
      profileModules = map
        (profile:
          ../../../modules/home/profiles/${profile}.nix
        )
        userCfg.profiles;
    in
    { inputs, ... }: {
      imports = [
        inputs.agenix.homeManagerModules.default
      ] ++ profileModules ++ userCfg.extraHomeModules;

      # Basic home configuration - applied directly instead of importing
      home.username = name;
      home.homeDirectory = "/home/${name}";
      home.stateVersion = "23.11";

      # Enable secrets management 
      modules.secrets.enable = true;

      # Basic session variables
      home.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };
    };

in
{
  options.my.users = lib.mkOption {
    type = lib.types.attrsOf userOptionType;
    default = { };
    description = "User configurations";
    example = lib.literalExpression ''
      {
        mar = {
          enable = true;
          enableHome = true;
          profiles = [ "developer" ];
        };
        guest = {
          enable = true;
          enableHome = false;
        };
      }
    '';
  };

  config = lib.mkMerge [
    # System user creation
    (lib.mkIf (enabledUsers != { }) {
      users.users = lib.mapAttrs buildSystemUser enabledUsers;

      # Enable shells that users require
      programs.fish.enable = lib.mkIf
        (lib.any (u: (buildSystemUser u enabledUsers.${u}).shell == pkgs.fish)
          (lib.attrNames enabledUsers))
        true;

      programs.zsh.enable = lib.mkIf
        (lib.any (u: (buildSystemUser u enabledUsers.${u}).shell == pkgs.zsh)
          (lib.attrNames enabledUsers))
        true;
    })

    # Home-manager configuration
    (lib.mkIf anyHomeManagerUser {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;

        # Build home configurations for enabled users
        users = lib.mapAttrs buildHomeConfig homeManagerUsers;

        # Share home-manager modules across all users
        sharedModules = [
          # Import all home modules so they're available
          { imports = lib.attrValues (import ../../../modules/home { inherit inputs; }); }
        ];
      };
    })
  ];
}
