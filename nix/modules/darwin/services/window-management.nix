# Combined window management configuration module
# Provides unified interface backed by home-manager's programs.aerospace
{ lib, config, ... }:

let
  cfg = config.modules.darwin.windowManagement;

  # Map layout names to AeroSpace equivalents
  aerospaceLayout = {
    "bsp" = "tiles";
    "stack" = "accordion";
    "float" = "tiles";
  }.${cfg.layout};

  # Generate workspace switching and move-to-workspace keybindings
  workspaceBindings = lib.listToAttrs (
    lib.concatMap
      (ws: [
        { name = "alt-${toString ws.number}"; value = "workspace ${ws.label}"; }
        { name = "shift-alt-${toString ws.number}"; value = "move-node-to-workspace ${ws.label}"; }
      ])
      cfg.workspaces
  );

  # Generate app-to-workspace window rules
  appWorkspaceRules = lib.concatMap
    (ws:
      map
        (app: {
          "if" = { app-name-regex-substring = app; };
          run = "move-node-to-workspace ${ws.label}";
        })
        ws.apps)
    cfg.workspaces;

  # Generate workspace-to-monitor assignment
  monitorAssignment = lib.listToAttrs (
    lib.concatMap
      (ws:
        lib.optional (ws.monitor != null) {
          name = ws.label;
          value = ws.monitor;
        })
      cfg.workspaces
  );

  # Generate floating window rules from rules config
  floatingRules = map
    (rule: {
      "if" =
        if rule.app != null then { app-name-regex-substring = rule.app; }
        else if rule.title != null then { window-title-regex-substring = rule.title; }
        else throw "Rule must have either app or title";
      run = if rule.manage then "layout tiling" else "layout floating";
    })
    cfg.rules;

  # Default keybindings (migrated from skhd)
  defaultKeybindings = lib.optionalAttrs cfg.keybindings.enable {
    # Reload config
    "alt-r" = "reload-config";

    # Open apps
    "alt-enter" = "exec-and-forget open -na ${cfg.keybindings.terminal}";
    "alt-f" = "exec-and-forget open -a ${cfg.keybindings.browser}";

    # Window focus navigation (crosses monitor boundaries)
    "alt-h" = "focus left";
    "alt-j" = "focus down";
    "alt-k" = "focus up";
    "alt-l" = "focus right";

    # Move windows (across monitors when at edge)
    "shift-alt-h" = "move left";
    "shift-alt-j" = "move down";
    "shift-alt-k" = "move up";
    "shift-alt-l" = "move right";

    # Resize windows
    "shift-cmd-h" = "resize width -50";
    "shift-cmd-j" = "resize height +50";
    "shift-cmd-k" = "resize height -50";
    "shift-cmd-l" = "resize width +50";

    # Layout management
    "alt-d" = "layout tiles horizontal vertical";
    "alt-t" = "layout floating tiling";
    "alt-m" = "fullscreen";

    # Focus monitor directly
    "alt-comma" = "focus-monitor --wrap-around left";
    "alt-period" = "focus-monitor --wrap-around right";

    # Move window to monitor
    "shift-alt-comma" = "move-node-to-monitor --wrap-around left";
    "shift-alt-period" = "move-node-to-monitor --wrap-around right";

    # Prevent macOS cmd-h window hiding
    "cmd-h" = "focus left";
  };
in
{
  options.modules.darwin.windowManagement = {
    enable = lib.mkEnableOption "window management with AeroSpace";

    layout = lib.mkOption {
      type = lib.types.enum [ "bsp" "stack" "float" ];
      default = "bsp";
      description = "Default window layout mode (bsp/stack map to AeroSpace tiles/accordion)";
    };

    workspaces = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          number = lib.mkOption {
            type = lib.types.int;
            description = "Workspace number (used for alt-N keybinding)";
          };
          label = lib.mkOption {
            type = lib.types.str;
            description = "Workspace label (used as AeroSpace workspace name)";
          };
          apps = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Apps to assign to this workspace";
          };
          monitor = lib.mkOption {
            type = lib.types.nullOr (lib.types.either lib.types.str (lib.types.listOf lib.types.str));
            default = null;
            description = ''
              Monitor to pin this workspace to. Accepts a single pattern
              ('main', 'secondary', or a case-insensitive regex substring of
              the monitor name) or a list of patterns tried in order as a
              fallback chain.
            '';
          };
        };
      });
      default = [ ];
      description = "Workspace configuration";
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
        default = "Ghostty";
        description = "Terminal application to open";
      };

      browser = lib.mkOption {
        type = lib.types.str;
        default = "Firefox";
        description = "Browser application to open";
      };

      custom = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        description = "Custom keybindings (AeroSpace format)";
      };
    };

    rules = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          app = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "App name pattern (regex)";
          };
          title = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Window title pattern (regex)";
          };
          manage = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to tile this window (false = floating)";
          };
        };
      });
      default = [ ];
      description = "Window management rules";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${config.system.primaryUser}.programs.aerospace = {
      enable = true;
      launchd.enable = true;
      settings = {
        start-at-login = true;
        enable-normalization-flatten-containers = true;
        enable-normalization-opposite-orientation-for-nested-containers = true;
        default-root-container-layout = aerospaceLayout;
        default-root-container-orientation = "auto";
        on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];

        gaps = {
          inner = { horizontal = 0; vertical = 0; };
          outer = { left = 0; right = 0; top = 0; bottom = 0; };
        };

        workspace-to-monitor-force-assignment = monitorAssignment;

        mode.main.binding =
          defaultKeybindings // workspaceBindings // cfg.keybindings.custom;

        on-window-detected = floatingRules ++ appWorkspaceRules;
      };
    };
  };
}
