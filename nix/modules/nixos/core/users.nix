# NixOS User Management Module
#
# This module provides a unified interface for managing system users and their
# home-manager configurations. It implements a registry-based approach where:
#
# 1. Users are defined in nix/users/<username>/ with metadata and config
# 2. Users can be enabled/disabled per host
# 3. Home-manager integration is optional per user
# 4. Profiles provide pre-configured sets of modules
#
# Usage in host configuration:
#   my.users.mar = {
#     enable = true;
#     enableHome = true;
#     profiles = [ "developer" "desktop" ];
#   };

{ pkgs, lib, config, inputs, self, userRegistry, homeModules, ... }:

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

  # Use the userRegistry passed from flake outputs
  users = userRegistry;

  # Get enabled users
  enabledUsers = lib.filterAttrs (_name: cfg: cfg.enable) cfg;

  # Get users with home-manager enabled
  homeManagerUsers = lib.filterAttrs (_name: cfg: cfg.enable && cfg.enableHome) cfg;

  # Check if any user has home-manager enabled
  anyHomeManagerUser = (lib.length (lib.attrNames homeManagerUsers)) > 0;

  # Build system user configuration
  # This function reads the user's system.nix file and merges it with any
  # extra configuration specified at the host level
  buildSystemUser = name: userCfg:
    let
      user = users.${name};
      systemConfig = import user.systemConfig { inherit pkgs config lib inputs; };
    in
    systemConfig // userCfg.extraSystemConfig;

  # Build home-manager configuration
  # This function creates a home-manager configuration by:
  # 1. Loading the requested profile modules (desktop, developer, minimal)
  # 2. Adding any extra modules specified at the host level
  # 3. Setting up basic home directory structure and environment
  buildHomeConfig = name: userCfg:
    let
      # Collect profile modules from the homeModules registry
      # Profiles are predefined sets of configurations that group related functionality
      profileModules = map
        (profile: homeModules.profiles.${profile})
        userCfg.profiles;
    in
    { inputs, ... }: {
      imports = [
        inputs.agenix.homeManagerModules.default # Secret management
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
          # Use homeManagerModules.default from flake outputs
          self.homeManagerModules.default
        ];
      };
    })
  ];
}
