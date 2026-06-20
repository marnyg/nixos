# Taskwarrior user configuration.
#
# Manages ~/.taskrc with our conventions on top of the defaults that
# Taskwarrior would otherwise auto-generate on first run. The agent
# system prompt (`modules.my.pi-agent.appendSystemPrompt`) relies on
# the `refs` UDA defined here for sketch/task cross-references.
{ config, lib, pkgs, ... }:

let
  cfg = config.modules.my.taskwarrior;

  # Columns/labels for the `next` and `list` reports, extended in two
  # ways relative to Taskwarrior 3.x defaults:
  #
  #   - `uuid.short` column right after `id` so the 8-char UUID prefix
  #     is always visible — this is what `refs:` values point at, and
  #     short ids get renumbered as tasks complete, so the UUID prefix
  #     is the only stable cross-task reference.
  #   - `refs` UDA column before `urgency` so sketch-derived links are
  #     visible at a glance.
  #
  # IMPORTANT: column and label counts must match exactly or Taskwarrior
  # prints "different numbers of columns and labels" on every report
  # invocation. Keep the two strings in lockstep when editing. The
  # `list` report does not include `entry.age` (so no "Age" label),
  # while `next` does.
  reportNextColumns =
    "id,uuid.short,start.age,entry.age,depends.indicator,priority,project,tags,"
    + "recur.indicator,scheduled.countdown,due.relative,until.remaining,"
    + "description,refs,urgency";
  reportNextLabels =
    "ID,UUID,Active,Age,D,P,Project,Tag,R,S,Due,Until,Description,Refs,Urg";
  reportListColumns =
    "id,uuid.short,start.age,depends.indicator,priority,project,tags,"
    + "recur.indicator,wait.remaining,scheduled.countdown,due,"
    + "until.remaining,description,refs,urgency";
  reportListLabels =
    "ID,UUID,Active,D,P,Project,Tag,R,Wait,S,Due,Until,Description,Refs,Urg";

  # Parameterless custom report: "everything with any refs value set".
  # Useful for overview of the link graph; for parameterized lookups
  # ("incoming to task X", "outgoing from task X") see the task-refsto /
  # task-refsfrom helpers below — Taskwarrior reports cannot take
  # positional arguments, so those have to be external shell helpers.
  reportRefsColumns =
    "id,uuid.short,project,tags,description,refs,urgency";
  reportRefsLabels =
    "ID,UUID,Project,Tag,Description,Refs,Urg";

  # External helpers shipped on PATH alongside `task`. They follow the
  # git-style `<command>-<verb>` convention: invoked as `task-refsto 1`,
  # not `task refsto 1` (Taskwarrior has no plugin-style command
  # dispatch).
  taskRefsto = pkgs.writeShellScriptBin "task-refsto" ''
    # Show tasks whose `refs` UDA contains the given task's UUID prefix.
    # Argument may be a short id, a full UUID, or any UUID prefix (>=8
    # hex chars). Extra arguments are passed through to `task` as
    # additional filters/modifiers.
    set -eu
    if [ $# -lt 1 ]; then
      echo "Usage: task-refsto <id|uuid|uuid-prefix> [extra task args...]" >&2
      exit 2
    fi
    target=$1
    shift

    # Heuristic: >=8 chars and hex-only (dashes allowed) → treat as UUID
    # prefix. Otherwise look up via `task _get <id>.uuid`. Short ids in
    # Taskwarrior are decimal (1, 2, …) so the 8-char hex test is
    # unambiguous.
    if [ ''${#target} -ge 8 ] \
       && printf '%s' "$target" | grep -Eq '^[0-9a-fA-F-]+$'; then
      uuid_prefix=$(printf '%s' "$target" | tr -d '-' | cut -c1-8)
    else
      full=$(${pkgs.taskwarrior3}/bin/task _get "$target".uuid 2>/dev/null || true)
      if [ -z "$full" ]; then
        echo "task-refsto: could not resolve '$target' to a UUID" >&2
        exit 1
      fi
      uuid_prefix=$(printf '%s' "$full" | cut -c1-8)
    fi

    exec ${pkgs.taskwarrior3}/bin/task refs.contains:"$uuid_prefix" all "$@"
  '';

  taskRefsfrom = pkgs.writeShellScriptBin "task-refsfrom" ''
    # Show the task(s) referenced by the given task's `refs` UDA — i.e.
    # walk outgoing refs. `refs` is a single string but may be
    # comma-joined for multi-target references; this helper handles
    # both.
    set -eu
    if [ $# -lt 1 ]; then
      echo "Usage: task-refsfrom <id|uuid|uuid-prefix>" >&2
      exit 2
    fi
    target=$1

    refs=$(${pkgs.taskwarrior3}/bin/task _get "$target".refs 2>/dev/null || true)
    if [ -z "$refs" ]; then
      echo "task-refsfrom: '$target' has no refs set (or could not be resolved)" >&2
      exit 1
    fi

    # refs may be "uuid1,uuid2,…". Look each one up via uuid.startswith.
    IFS=,
    for ref in $refs; do
      ref=$(printf '%s' "$ref" | tr -d ' ')
      [ -z "$ref" ] && continue
      printf '→ %s:\n' "$ref"
      ${pkgs.taskwarrior3}/bin/task uuid.startswith:"$ref" all || true
    done
  '';

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

    # Custom report: "everything with any refs value set". Parameterless;
    # for parameterized incoming/outgoing lookups, use the external
    # `task-refsto` / `task-refsfrom` helpers (Taskwarrior reports can't
    # take positional arguments).
    report.refs.description=Tasks that link to another task via the refs UDA
    report.refs.columns=${reportRefsColumns}
    report.refs.labels=${reportRefsLabels}
    report.refs.filter=refs.any:
    report.refs.sort=refs+,urgency-
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
    home.packages = [
      pkgs.taskwarrior3
      taskRefsto
      taskRefsfrom
    ];

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
