# Homebrew integration module for nix-darwin
# Provides unified interface for managing Homebrew packages and casks
{ lib, config, ... }:

let
  cfg = config.modules.darwin.brew;
in
{
  options.modules.darwin.brew = {
    enable = lib.mkEnableOption "Homebrew package management";

    taps = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of Homebrew taps to enable";
      example = [ "homebrew/cask-fonts" "homebrew/services" ];
    };

    brews = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of Homebrew formulae to install";
      example = [ "wget" "jq" ];
    };

    casks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of Homebrew casks to install";
      example = [ "firefox" "visual-studio-code" ];
    };

    masApps = lib.mkOption {
      type = lib.types.attrsOf lib.types.int;
      default = { };
      description = "Mac App Store apps to install (name -> id)";
      example = {
        "Xcode" = 497799835;
        "1Password" = 1333542190;
      };
    };

    cleanup = lib.mkOption {
      type = lib.types.enum [ "none" "zap" "uninstall" ];
      default = "none";
      description = "How to handle packages not in the configuration";
    };

    autoUpdate = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable automatic Homebrew updates";
    };
  };

  config = lib.mkIf cfg.enable {
    homebrew = {
      enable = true;

      # Global options
      onActivation = {
        autoUpdate = cfg.autoUpdate;
        cleanup = cfg.cleanup;
        upgrade = cfg.autoUpdate;
      };

      # Package lists
      taps = cfg.taps;
      brews = cfg.brews;
      casks = cfg.casks;
      masApps = cfg.masApps;

      # Global Homebrew preferences
      global = {
        autoUpdate = cfg.autoUpdate;
        brewfile = true;
      };
    };
  };
}
