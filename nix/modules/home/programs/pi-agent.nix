# pi-coding-agent user configuration
#
# Manages ~/.pi/agent/{settings,keybindings}.json. We can't use plain
# `home.file` here because pi writes back to settings.json at runtime
# (e.g. `lastChangelogVersion`), which would fail against a read-only
# Nix-store symlink. Instead we write the files via an activation
# script so they remain user-writable, and only re-seed them when our
# managed source changes.
{ config, lib, pkgs, ... }:

let
  cfg = config.modules.my.pi-agent;

  settings = {
    lastChangelogVersion = "0.73.0";
    defaultProvider = "anthropic";
    defaultModel = "claude-opus-4-7";
    packages = [
      "npm:pi-claude-oauth-adapter"
      "npm:@burneikis/pi-vim"
      "git:github.com/marnyg/pi-ui"
      "git:github.com/marnyg/skills"
    ];
    defaultThinkingLevel = "high";
    hideThinkingBlock = true;
  };

  keybindings = {
    "app.model.cycleForward" = [ ];
    "app.model.cycleBackward" = [ ];
  };

  settingsJson = pkgs.writeText "pi-agent-settings.json"
    (builtins.toJSON settings);
  keybindingsJson = pkgs.writeText "pi-agent-keybindings.json"
    (builtins.toJSON keybindings);
in
{
  options.modules.my.pi-agent = {
    enable = lib.mkEnableOption "pi-coding-agent user configuration";
  };

  config = lib.mkIf cfg.enable {
    home.activation.piAgentConfig =
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run mkdir -p "$HOME/.pi/agent"

        # Seed settings.json on first run; pi will keep updating it
        # (e.g. lastChangelogVersion). On managed-source change we
        # overwrite, but the file stays user-writable.
        run install -m 0644 ${settingsJson} "$HOME/.pi/agent/settings.json"
        run install -m 0644 ${keybindingsJson} "$HOME/.pi/agent/keybindings.json"
      '';
  };
}
