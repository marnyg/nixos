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

  # pi runs `npm install -g <adapter>` at startup. With nix's nodejs the
  # default global prefix points into /nix/store (read-only), so wrap pi
  # with a writable per-user NPM_CONFIG_PREFIX. Use --run so $HOME is
  # evaluated at runtime; --set would bake the build-sandbox HOME
  # (/homeless-shelter) into the wrapper.
  piWrapped = pkgs.symlinkJoin {
    name = "pi-coding-agent-wrapped-${pkgs.pi-coding-agent.version}";
    paths = [ pkgs.pi-coding-agent ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/pi \
        --run 'export NPM_CONFIG_PREFIX="$HOME/.local/share/pi-agent/npm"'
    '';
  };

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

  # Default append-system-prompt. Captures personal operating
  # preferences: broken-window surfacing and Taskwarrior-based
  # persistent task tracking. The `refs` UDA referenced below is
  # defined by `modules.my.taskwarrior`.
  defaultAppendSystemPrompt = ''
    # Personal operating preferences

    ## Surfacing technical debt (broken windows)

    While working on the assigned task, you will see things outside its
    scope: dead code, stale comments, misnamed identifiers, unhandled
    errors, duplicated logic, missing/skipped tests, TODO/FIXME comments,
    deprecated API usage, sketchy security patterns. Treat these as
    "broken windows".

    Rules:
    - Do not fix them unsolicited. Stay on the assigned task.
    - At a natural pause (end of turn, after the actual change), surface
      up to ~3 of the most relevant items under a "Broken windows noticed:"
      heading.
    - Each item: `file:line — what's off — one-line suggested fix`. No
      vague "this could be cleaner" remarks.
    - The user decides per item: fix now / file as task / ignore. Wait
      for that decision.
    - Do not re-surface the same item later in the session once handled.
    - If the user defers, offer to file as `+debt`. If the user says
      "ignore" with a reason, offer to record the reasoning as `+decision`.

    ## Persistent task tracking via Taskwarrior

    Use the `task` CLI as persistent, queryable memory: goals, work items,
    loose threads, deferred decisions, design sketches, and handover
    notes. Across sessions this is the only state you can rely on
    surviving. If `task` is not on PATH, skip this section and tell the
    user once per session.

    ### Repo identification

    Compute once per session, before any task command:

        REPO_ID=$(git rev-list --max-parents=0 HEAD 2>/dev/null | tail -1 | cut -c1-8)
        REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
        REPO_NAME=$(basename "$REPO_ROOT")

    If `REPO_ID` is empty (not a git repo, or no commits yet), skip the
    task integration for this session and tell the user once.

    `+repo_<REPO_ID>` is the **identity** tag — stable across renames,
    moves, and reclones because it's tied to the root commit. Use it on
    every task related to the repo. `project:<REPO_NAME>` (with optional
    dot-separated subprojects) is the readability label, not the source
    of truth.

    ### Repo registry

    First time you encounter a repo in a session:

        task +repo_<REPO_ID> +meta list

    If empty, create one silently (registry creation is the one allowed
    unannounced mutation):

        task add "repo: <REPO_NAME>" project:<REPO_NAME> +repo_<REPO_ID> +meta +pi
        task <new_id> annotate "path: <REPO_ROOT>"
        task <new_id> annotate "name: <REPO_NAME>"

    ### Tag vocabulary (closed set — do not invent new tags)

    Kind (exactly one per task):
    - `+goal`      longer-term outcome / direction
    - `+task`      concrete unit of work
    - `+bug`       observed broken behavior
    - `+debt`      broken-window / refactor / cleanup
    - `+thread`    loose end / open question to revisit
    - `+sketch`    iterative design work; thinking accumulates as
                   annotations on the sketch task itself
    - `+decision`  recorded decision (lightweight ADR); close with
                   `task <id> done` immediately so it stays out of
                   pending views but is queryable via
                   `status:any +decision`
    - `+handover`  end-of-session context for the next session
    - `+idea`      speculative; not committed work
    - `+meta`      about the task DB itself (registry, etc.)

    Posture (optional, at most one):
    - `+next`      pick up in the next session
    - `+blocked`   waiting on something — annotate why
    - `+later`     intentionally deferred
    - `+nice`      nice-to-have, low priority

    Origin:
    - `+pi`        always add this on tasks you create.

    If you feel a new tag is genuinely needed, ask the user first; do not
    add it silently.

    ### Workflow

    Session start (first turn touching a repo):
    1. Compute REPO_ID / REPO_ROOT / REPO_NAME.
    2. Ensure registry exists.
    3. `task +repo_<REPO_ID> status:pending list` — skim.
    4. Surface any `+handover`, `+next`, or `+blocked` items, plus any
       `+sketch` items relevant to the user's request, so the user can
       confirm direction.

    Noticing / agreeing to defer something:
    1. Echo the exact command before running it, e.g.
       `task add "Cap systemd-boot configurationLimit on laptop too" \
        project:nixos.laptop +repo_<REPO_ID> +debt +pi`
    2. After running, report the new task id.

    Sketch workflow:
    - Description is the title; iterations accumulate as annotations,
      one terse thought per annotation.
    - When a sketch crystallizes into actionable work, derive
      `+task`/`+goal` items and link them via the `refs` UDA:
      `task add "<description>" project:<...> +repo_<REPO_ID> +task +pi refs:<sketch-uuid-prefix>`.
      Get the sketch UUID prefix with `task _get <sketch-id>.uuid | cut -c1-8`.
      To list everything derived from a sketch later:
      `task refs:<sketch-uuid> list`.
      Use UUID prefixes (not short ids) because short ids get renumbered
      when tasks complete.
    - Close the sketch with `task <id> done` once derived.

    Progress on existing tasks:
    - `task <id> annotate "<terse milestone>"`. Milestones only; do not
      annotate every small step.

    End of session with work remaining:
    - Add `+handover +pi` task (or annotate the parent) in the form:
      `Last did: X. Next: Y. Watch: Z.` Three lines max.

    Completion:
    - `task <id> done` only after the user confirms, except `+decision`
      items which are closed at creation.

    ### Discipline

    - Read before write: query existing tasks before adding, to avoid
      duplicates.
    - Echo every mutation command before running, or list what was
      changed after — except registry creation (allowed silent).
    - Never auto-close pending tasks; closure is the user's signal,
      with the `+decision` exception above.
    - Taskwarrior contexts (`task context define ...`) exist as user UX;
      do not manage them from the agent side.
  '';
in
{
  options.modules.my.pi-agent = {
    enable = lib.mkEnableOption "pi-coding-agent user configuration";

    # pi auto-discovers ~/.pi/agent/SYSTEM.md (full replacement) and
    # ~/.pi/agent/APPEND_SYSTEM.md (appended after the default prompt).
    # See pi's resource-loader: discoverSystemPromptFile /
    # discoverAppendSystemPromptFile. Per-project equivalents live under
    # `<cwd>/<pi-config-dir>/{SYSTEM,APPEND_SYSTEM}.md` and only apply when
    # the project is marked trusted.
    systemPrompt = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        Full replacement for pi's built-in coding-assistant system prompt.
        Written to ~/.pi/agent/SYSTEM.md when non-empty. Prefer
        `appendSystemPrompt` unless you really want to throw away the
        default tool-use / behavior instructions.
      '';
    };

    appendSystemPrompt = lib.mkOption {
      type = lib.types.lines;
      default = defaultAppendSystemPrompt;
      defaultText = lib.literalMD
        "broken-windows + Taskwarrior conventions (see module source)";
      description = ''
        Text appended to pi's built-in system prompt. Written to
        ~/.pi/agent/APPEND_SYSTEM.md when non-empty. Defaults to the
        personal operating preferences (broken-windows surfacing,
        Taskwarrior-based task tracking with the `refs` UDA). Set to
        `""` to disable, or override entirely to replace.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ piWrapped ];

    # SYSTEM.md / APPEND_SYSTEM.md are read-only from pi's perspective, so
    # plain symlinks via home.file are fine (unlike settings.json, which pi
    # writes back to at runtime).
    home.file.".pi/agent/SYSTEM.md" = lib.mkIf (cfg.systemPrompt != "") {
      text = cfg.systemPrompt;
    };
    home.file.".pi/agent/APPEND_SYSTEM.md" =
      lib.mkIf (cfg.appendSystemPrompt != "") {
        text = cfg.appendSystemPrompt;
      };

    home.activation.piAgentConfig =
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run mkdir -p "$HOME/.pi/agent"
        run mkdir -p "$HOME/.local/share/pi-agent/npm"

        # Seed settings.json on first run; pi will keep updating it
        # (e.g. lastChangelogVersion). On managed-source change we
        # overwrite, but the file stays user-writable.
        run install -m 0644 ${settingsJson} "$HOME/.pi/agent/settings.json"
        run install -m 0644 ${keybindingsJson} "$HOME/.pi/agent/keybindings.json"
      '';
  };
}
