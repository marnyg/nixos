# Taskwarrior user configuration.
#
# Manages ~/.taskrc with our conventions on top of the defaults that
# Taskwarrior would otherwise auto-generate on first run. The agent
# system prompt (`modules.my.pi-agent.appendSystemPrompt`) relies on
# the `refs` UDA defined here for sketch/task cross-references.
{ config, lib, pkgs, ... }:

let
  cfg = config.modules.my.taskwarrior;

  # Columns/labels for the `next` and `list` reports, extended to show
  # the `refs` UDA so sketch-derived tasks are visible at a glance.
  # Taken from Taskwarrior 3.x defaults with `refs` inserted before
  # `urgency`.
  reportNextColumns =
    "id,start.age,entry.age,depends.indicator,priority,project,tags,"
    + "recur.indicator,scheduled.countdown,due.relative,until.remaining,"
    + "description,refs,urgency";
  reportNextLabels =
    "ID,Active,Age,D,P,Project,Tag,R,S,Due,Until,Description,Refs,Urg";
  reportListColumns =
    "id,start.age,depends.indicator,priority,project,tags,"
    + "recur.indicator,wait.remaining,scheduled.countdown,due,"
    + "until.remaining,description,refs,urgency";
  reportListLabels =
    "ID,Active,Age,D,P,Project,Tag,R,Wait,S,Due,Until,Description,Refs,Urg";

  baseRc = ''
    # Managed by Nix (nix/modules/home/programs/taskwarrior.nix).
    # Edits to this file are overwritten on next home-manager activation.

    data.location=~/.task

    # ---------------------------------------------------------------------
    # User-defined attributes (UDAs)
    # ---------------------------------------------------------------------
    #
    # refs: free-text reference to another task — typically the 8-char
    # UUID prefix of a +sketch task this one was derived from. Single-
    # valued string; for multiple references, comma-join the values and
    # filter with `task refs.contains:<uuid> list`.
    #
    # Get a sketch's UUID prefix:    task _get <id>.uuid | cut -c1-8
    # Find everything derived from:  task refs:<uuid> list
    # Find everything with any ref:  task refs.any: list
    uda.refs.type=string
    uda.refs.label=Refs

    # ---------------------------------------------------------------------
    # Reports: surface `refs` in the default views
    # ---------------------------------------------------------------------
    report.next.columns=${reportNextColumns}
    report.next.labels=${reportNextLabels}
    report.list.columns=${reportListColumns}
    report.list.labels=${reportListLabels}
  '';
in
{
  options.modules.my.taskwarrior = {
    enable = lib.mkEnableOption "Taskwarrior with managed .taskrc and refs UDA";

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        Additional lines appended to ~/.taskrc after the managed base.
        Use this for host-specific knobs (themes, hook paths, contexts)
        that shouldn't be baked into the shared module.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.taskwarrior3 ];

    # Taskwarrior 3.x auto-generates ~/.taskrc on first run if absent.
    # `force = true` lets home-manager clobber that auto-generated file
    # without manual cleanup the first time the module is enabled.
    home.file.".taskrc" = {
      force = true;
      text = baseRc + lib.optionalString (cfg.extraConfig != "") ''

        # ---------------------------------------------------------------------
        # extraConfig (from modules.my.taskwarrior.extraConfig)
        # ---------------------------------------------------------------------
        ${cfg.extraConfig}
      '';
    };
  };
}
