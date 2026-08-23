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
    # Note: do not set `lastChangelogVersion` here. Pi writes that field
    # itself on first run and bumps it on every upgrade. Managing it from
    # nix means every `home-manager switch` clobbers pi's current value
    # back to whatever we hardcoded, which then re-triggers the changelog
    # popup on next pi launch.
    defaultProvider = "anthropic";
    defaultModel = "claude-opus-4-7";
    packages = [
      # Anthropic OAuth (Claude Pro/Max) compatibility shim.
      # Replaces pi's verbose default preamble with a minimal neutral
      # one and strips known Pi-specific paragraphs (identity/docs/filler)
      # via anchor-based paragraph removal — without touching
      # APPEND_SYSTEM.md content. Replaces the older
      # `pi-claude-oauth-adapter`, which over-stripped because its
      # docs-section extractor used a closed END_MARKERS list that ate
      # everything between the Pi docs paragraph and `Current date:`,
      # including our broken-windows + Taskwarrior preferences.
      "npm:@gotgenes/pi-anthropic-auth"
      "npm:@burneikis/pi-vim"
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
  # preferences: broken-window surfacing and beads-based persistent
  # task tracking (`bd`, repo-scoped, installed via the developer
  # profile). Taskwarrior remains installed only as the legacy system
  # for lazy per-repo migration — see the migration subsection below.
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
    - If the user defers, offer to file as a `debt`-labeled chore. If the
      user says "ignore" with a reason, offer to record the reasoning as
      a `decision` issue.

    ## Persistent task tracking via beads

    Use the `bd` CLI (beads) as persistent, queryable memory: goals,
    work items, loose threads, deferred decisions, design sketches, and
    handover notes. Beads is repo-scoped: the local database lives in
    `.beads/`, which is globally gitignored here, and the shared state
    travels in the git remote's `refs/dolt/data` ref rather than in the
    worktree. There is no cross-repo or
    host-wide task tracking — everything belongs to some repo. Across
    sessions this is the only state you can rely on surviving. If `bd`
    is not on PATH, skip this section and tell the user once per
    session.

    ### Database discovery

    Session start (first turn touching a repo):
    1. Run `bd ready`. If it errors with "no beads database found",
       first check whether the repo already has beads data elsewhere —
       run `bd bootstrap --dry-run` (it detects a Dolt DB on the git
       remote via `refs/dolt/data`, a configured `sync.remote`, or a
       tracked `.beads/issues.jsonl`). If it finds existing data, ask
       the user before running `bd bootstrap`; only fall back to
       `bd init` when there is genuinely nothing to adopt. Never init
       or bootstrap silently — `bd init` on a repo whose remote already
       carries a Dolt DB creates a divergent, empty history. If the
       user declines, skip the task integration for this repo.
       Because `.beads/` is gitignored, a fresh clone has no tracked
       `config.yaml`, so `bd bootstrap` may need a remote spelled out:
       `bd dolt remote add origin git+<clone-url>`. Check
       `bd dolt remote list` before concluding there is no data, and
       run `bd hooks install` after bootstrapping so Dolt push/pull
       stays wired to git.
    2. If a database exists, skim `bd ready` and
       `bd list --status in_progress,blocked`.
    3. Surface any `handover`-labeled issues, in_progress/blocked items,
       and any `spike` issues relevant to the user's request, so the
       user can confirm direction.

    ### Legacy Taskwarrior migration (lazy, per repo)

    Taskwarrior (`task`) is the previous system; it stays installed
    only so old tasks can be migrated. Once per repo, when a beads
    database exists, check for leftovers:

        REPO_ID=$(git rev-list --max-parents=0 HEAD 2>/dev/null | tail -1 | cut -c1-8)
        task +repo_$REPO_ID status:pending count

    If non-zero, offer to migrate (user confirms first): one
    `bd create` per pending task — map tags to the vocabulary below,
    carry annotations into `--notes`, skip `+meta` registry tasks.
    Then in taskwarrior: `task <id> annotate "migrated to beads <bd-id>"`
    and `task <id> done`. If the user declines, do not offer again this
    session.

    ### Vocabulary (built-in types/statuses; closed label set)

    Types (`bd create -t <type>`, exactly one per issue):
    - `task`      concrete unit of work (default)
    - `bug`       observed broken behavior
    - `feature`   new user-visible capability
    - `chore`     maintenance / cleanup (broken windows → label `debt`)
    - `epic`      longer-term outcome / direction (was `+goal`)
    - `spike`     iterative design/investigation work (was `+sketch`);
                  thinking accumulates as notes on the spike itself
    - `decision`  recorded decision / lightweight ADR; close immediately
                  after creation so it stays out of ready views but is
                  queryable via `bd list -t decision --status closed`

    Labels (closed set — do not invent new labels):
    - `pi`        always add this on issues you create
    - `debt`      broken-window / refactor / cleanup
    - `thread`    loose end / open question to revisit
    - `idea`      speculative; not committed work
    - `handover`  end-of-session context for the next session

    Posture maps to native status/priority, not labels:
    - blocked          → `bd update <id> --status blocked` + a note why
    - intentionally deferred → `bd update <id> --status deferred`
    - pick up next session   → priority 1
    - nice-to-have           → priority 3 (or 4 for backlog)
    Priorities: 0 critical … 4 backlog; default 2.

    If you feel a new label or custom type is genuinely needed, ask the
    user first; do not add it silently.

    ### Workflow

    Noticing / agreeing to defer something:
    1. Echo the exact command before running it, e.g.
       `bd create "Cap systemd-boot configurationLimit on laptop too" \
        -t chore -l pi,debt`
    2. After running, report the new issue id.

    Spike workflow:
    - Title is the question/design under investigation; iterations
      accumulate via `bd note <id> "<terse thought>"`, one thought per
      note.
    - When a spike crystallizes into actionable work, derive task/epic
      issues linked back to it:
      `bd create "<title>" -t task -l pi --deps discovered-from:<spike-id>`.
    - Walk the graph with `bd dep tree <id>`; `bd dep list <id>` shows
      direct dependencies/dependents.
    - Close the spike (`bd close <spike-id>`) once derived.

    Progress on existing issues:
    - `bd update <id> --status in_progress` when starting work.
    - `bd note <id> "<terse milestone>"`. Milestones only; do not
      note every small step.

    End of session with work remaining:
    - `bd create "Last did: X. Next: Y. Watch: Z." -t task -l pi,handover`
      (or note the parent issue). Three lines max. Close any handover
      issue you surfaced at session start once its context is absorbed.

    Completion:
    - `bd close <id>` only after the user confirms, except `decision`
      issues which are closed at creation.

    ### Discipline

    - Read before write: `bd search <text>` / `bd list` before creating,
      to avoid duplicates (`bd` also detects similar issues on create).
    - Echo every mutation command before running, or list what was
      changed after.
    - Never auto-close open issues; closure is the user's signal, with
      the `decision` exception above.
    - Leave `.beads/` internals alone: no manual edits to its files, no
      git operations on its behalf beyond what `bd` itself does.
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
        "broken-windows + beads conventions (see module source)";
      description = ''
        Text appended to pi's built-in system prompt. Written to
        ~/.pi/agent/APPEND_SYSTEM.md when non-empty. Defaults to the
        personal operating preferences (broken-windows surfacing,
        beads-based repo-scoped task tracking via `bd`). Set to
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
