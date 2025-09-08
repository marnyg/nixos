# Yabai tiling window manager service module
{ lib, config, ... }:
with lib;
let
  cfg = config.modules.darwin.services.yabai;
in
{
  options.modules.darwin.services.yabai = {
    enable = mkEnableOption "Yabai window manager";

    layout = mkOption {
      type = types.enum [ "bsp" "stack" "float" ];
      default = "bsp";
      description = "Default layout mode";
    };

    workspaces = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          label = mkOption {
            type = types.str;
            description = "Workspace label";
          };
          apps = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Apps to assign to this workspace";
          };
        };
      });
      default = { };
      description = "Workspace configuration";
    };
  };

  config = mkIf cfg.enable {
    services.yabai = {
      enable = true;
      enableScriptingAddition = true;
      config.layout = cfg.layout;

      extraConfig =
        let
          # Generate workspace labels
          workspaceLabels = lib.concatMapStringsSep "\n"
            (name:
              let ws = cfg.workspaces.${name}; in
              "yabai -m space ${name} --label ${ws.label}")
            (lib.attrNames cfg.workspaces);

          # Generate app rules
          appRules = lib.concatMapStringsSep "\n"
            (name:
              let ws = cfg.workspaces.${name}; in
              lib.concatMapStringsSep "\n"
                (app: "yabai -m rule --add app=\"${app}\" space=${ws.label}")
                ws.apps)
            (lib.attrNames cfg.workspaces);
        in
        ''
          # System app rules
          yabai -m rule --add app="^System Settings$"    manage=off
          yabai -m rule --add app="^System Information$" manage=off
          yabai -m rule --add app="^System Preferences$" manage=off
          yabai -m rule --add title="Preferences$"       manage=off
          yabai -m rule --add title="Settings$"          manage=off
        
          ${workspaceLabels}
          ${appRules}
        '';
    };
  };
}
