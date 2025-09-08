# Combined window management configuration module
# Provides unified interface for yabai and skhd
{ lib, config, ... }:

let
  cfg = config.modules.darwin.windowManagement;
in
{
  options.modules.darwin.windowManagement = {
    enable = lib.mkEnableOption "window management with yabai and skhd";

    layout = lib.mkOption {
      type = lib.types.enum [ "bsp" "stack" "float" ];
      default = "bsp";
      description = "Default window layout mode";
    };

    workspaces = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          number = lib.mkOption {
            type = lib.types.int;
            description = "Workspace number";
          };
          label = lib.mkOption {
            type = lib.types.str;
            description = "Workspace label";
          };
          apps = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Apps to assign to this workspace";
          };
        };
      });
      default = [ ];
      description = "Workspace configuration";
      example = lib.literalExpression ''
        [
          { number = 1; label = "todo"; apps = [ "Reminder" "Mail" "Calendar" ]; }
          { number = 2; label = "code"; apps = [ "Visual Studio Code" "IntelliJ IDEA" ]; }
          { number = 3; label = "web"; apps = [ "Firefox" "Safari" "Arc" ]; }
        ]
      '';
    };

    keybindings = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable default keybindings";
      };

      modifier = lib.mkOption {
        type = lib.types.str;
        default = "alt";
        description = "Primary modifier key for shortcuts";
      };

      terminal = lib.mkOption {
        type = lib.types.str;
        default = "~/Applications/Home\\ Manager\\ Trampolines/Ghostty.app/";
        description = "Terminal application to open";
      };

      browser = lib.mkOption {
        type = lib.types.str;
        default = "~/Applications/Home\\ Manager\\ Trampolines/Firefox.app/";
        description = "Browser application to open";
      };

      custom = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        description = "Custom keybindings";
      };
    };

    rules = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          app = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "App name pattern";
          };
          title = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Window title pattern";
          };
          manage = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to manage this window";
          };
        };
      });
      default = [ ];
      description = "Window management rules";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable yabai with our configuration
    modules.darwin.services.yabai = {
      enable = true;
      layout = cfg.layout;
      workspaces = lib.listToAttrs (map
        (ws: {
          name = toString ws.number;
          value = {
            label = ws.label;
            apps = ws.apps;
          };
        })
        cfg.workspaces);
    };

    # Enable skhd with our configuration
    modules.darwin.services.skhd = {
      enable = true;
      defaultKeybindings = cfg.keybindings.enable;
      keybindings = cfg.keybindings.custom;
      # Note: terminal and browser keybindings are already in defaultKeybindings
    };

    # Add custom rules to yabai config
    services.yabai.extraConfig = lib.mkAfter (
      lib.concatMapStringsSep "\n"
        (rule:
          let
            selector =
              if rule.app != null then "app=\"${rule.app}\""
              else if rule.title != null then "title=\"${rule.title}\""
              else throw "Rule must have either app or title";
            manage = if rule.manage then "on" else "off";
          in
          "yabai -m rule --add ${selector} manage=${manage}"
        )
        cfg.rules
    );
  };
}
