# Karabiner-Elements key remapping service module
# Installs via Homebrew and manages config via home-manager
{ lib, config, pkgs, ... }:
let
  cfg = config.modules.darwin.services.karabiner;

  # Convert a rule attrset to the karabiner complex_modifications format
  karabinerConfig = builtins.toJSON {
    profiles = [{
      name = "Default";
      selected = true;
      complex_modifications = {
        rules = cfg.rules;
      };
      virtual_hid_keyboard = {
        keyboard_type_v2 = "ansi";
      };
    }];
  };

  configFile = pkgs.writeText "karabiner.json" karabinerConfig;
in
{
  options.modules.darwin.services.karabiner = {
    enable = lib.mkEnableOption "Karabiner-Elements key remapping";

    rules = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [ ];
      description = "Complex modification rules for Karabiner-Elements";
      example = lib.literalExpression ''
        [{
          description = "Cmd-Tab to Ctrl-Tab in browsers";
          manipulators = [{
            type = "basic";
            conditions = [{
              type = "frontmost_application_if";
              bundle_identifiers = [ "^org\\.mozilla\\.firefox" ];
            }];
            from = {
              key_code = "tab";
              modifiers.mandatory = [ "left_command" ];
            };
            to = [{
              key_code = "tab";
              modifiers = [ "left_control" ];
            }];
          }];
        }]
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    homebrew = {
      enable = true;
      casks = [ "karabiner-elements" ];
    };

    home-manager.users.${config.system.primaryUser}.home.file.".config/karabiner/karabiner.json" = {
      source = configFile;
    };
  };
}
