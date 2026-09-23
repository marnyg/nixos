# Lazygit-style beads board for a herdr popup (see herdr.nix).
#
# fzf is the UI: the issue list on the left, `bd show` on the right.
# The search input starts hidden so single letters act as commands;
# `/` shows the input (and unbinds the letters) until esc/enter.
#
# The script re-invokes itself (`$self _<cmd>`) from fzf bindings, so
# every action lives in one file. Bindings run under bash via
# --with-shell; the user's $SHELL (fish) would mis-parse them.

self="${BASH_SOURCE[0]}"

# Letters bound in normal mode; unbound while typing a search query.
normal_keys='j,k,g,G,c,x,o,n,e,t,p,d,a,r,s,v,q,!,/'

# Closed issues are hidden unless toggled with `s`.
state_file() { printf '%s' "${BEADS_POPUP_STATE:?}"; }

list() {
  local all=()
  [[ "$(cat "$(state_file)")" == all ]] && all=(--all)
  bd list "${all[@]}" --json -n 0 2>/dev/null | jq -r '
    def c(code): "\u001b[" + code + "m";
    def reset: c("0");
    def rank: {"in_progress":0,"open":1,"blocked":2,"deferred":3,"closed":4}[.status] // 5;
    def icon: {
      "in_progress": c("33") + "◐",
      "open":        "○",
      "blocked":     c("31") + "●",
      "deferred":    c("34") + "❄",
      "closed":      c("2")  + "✓"
    }[.status] // "?";
    def prio: (if .priority <= 0 then c("1;31") elif .priority == 1 then c("33")
               elif .priority >= 3 then c("2") else "" end) + "P\(.priority)" + reset;
    sort_by(rank, .priority, (.updated_at | tostring | explode | map(-.)))
    | .[]
    | [ .id,
        "\(icon)\(reset) \(prio) \(c("36"))\(.issue_type | .[0:7] | . + (" " * (7 - length)))\(reset) "
        + (.title | gsub("\t"; " "))
        + (if (.labels // []) | length > 0 then " " + c("2") + "[" + (.labels | join(",")) + "]" + reset else "" end)
        + (if .assignee then " " + c("35") + "@" + .assignee + reset else "" end)
      ]
    | join("\t")'
}

prompt() {
  local reply
  read -r -p "$1: " reply </dev/tty || return 1
  printf '%s' "$reply"
}

pause_on_error() {
  if ! "$@"; then
    read -r -n 1 -s -p "(failed; press any key)" </dev/tty || true
  fi
}

# Normal mode `enter` opens the issue; in search mode it ends the search.
on_enter() {
  if [[ "${FZF_INPUT_STATE:-}" == enabled ]]; then
    printf 'hide-input+rebind(%s)' "$normal_keys"
  else
    printf 'execute(%s _view %s)' "$self" "$1"
  fi
}

# esc: leave search mode, else clear an active filter, else quit.
on_esc() {
  if [[ "${FZF_INPUT_STATE:-}" == enabled ]]; then
    printf 'hide-input+rebind(%s)' "$normal_keys"
  elif [[ -n "${FZF_QUERY:-}" ]]; then
    # With the input hidden fzf only re-filters on an explicit search.
    printf 'clear-query+search()'
  else
    printf 'abort'
  fi
}

toggle_closed() {
  local f
  f="$(state_file)"
  if [[ "$(cat "$f")" == all ]]; then
    echo open >"$f"
    printf 'change-list-label( beads: active )+reload(%s _list)' "$self"
  else
    echo all >"$f"
    printf 'change-list-label( beads: all )+reload(%s _list)' "$self"
  fi
}

case "${1:-}" in
  _list) list; exit ;;
  _enter) on_enter "$2"; exit ;;
  _esc) on_esc; exit ;;
  _toggle-closed) toggle_closed; exit ;;
  _view) CLICOLOR_FORCE=1 bd show "$2" | less -R; exit ;;
  _claim) pause_on_error bd update "$2" --claim; exit ;;
  _close)
    reason="$(prompt "Close $2 - reason (empty for none, ctrl+c to cancel)")" || exit 0
    if [[ -n "$reason" ]]; then pause_on_error bd close "$2" -r "$reason"
    else pause_on_error bd close "$2"; fi
    exit ;;
  _reopen) pause_on_error bd reopen "$2"; exit ;;
  _note)
    note="$(prompt "Note on $2")" || exit 0
    [[ -n "$note" ]] && pause_on_error bd note "$2" "$note"
    exit 0 ;;
  _edit) pause_on_error bd edit "$2"; exit ;;
  _title) pause_on_error bd edit "$2" --title; exit ;;
  _priority)
    p="$(prompt "Priority for $2 (0-4)")" || exit 0
    [[ "$p" =~ ^[0-4]$ ]] && pause_on_error bd update "$2" -p "$p"
    exit 0 ;;
  _defer)
    until="$(prompt "Defer $2 until (e.g. tomorrow, +1w; empty = indefinitely)")" || exit 0
    if [[ -n "$until" ]]; then pause_on_error bd defer "$2" --until "$until"
    else pause_on_error bd defer "$2"; fi
    exit ;;
  _create) pause_on_error bd create-form; exit ;;
  _shell) exec "${SHELL:-bash}" -i ;;
esac

# No database here: say so and fall back to a shell for `bd init` etc.
if ! bd where >/dev/null 2>&1; then
  echo "No beads database in $PWD."
  echo "Try 'bd bootstrap --dry-run' (existing data) or 'bd init'. Exit to close."
  exec "${SHELL:-bash}" -i
fi

BEADS_POPUP_STATE="$(mktemp -t beads-popup.XXXXXX)"
export BEADS_POPUP_STATE
trap 'rm -f "$BEADS_POPUP_STATE"' EXIT
echo open >"$BEADS_POPUP_STATE"

run() { printf 'execute(%s _%s {1})+reload(%s _list)' "$self" "$1" "$self"; }

header='enter view  c claim  x close  o reopen  n note  e edit  t title  p prio  d defer
a add  s show closed  r refresh  v preview  / search  ! shell  q quit'

fzf \
  --with-shell "$BASH -c" \
  --ansi --no-input --no-sort --track --id-nth 1 \
  --delimiter '\t' --with-nth 1,2 \
  --layout reverse --list-border rounded \
  --list-label ' beads: active ' --header "$header" --header-first \
  --preview 'CLICOLOR_FORCE=1 bd show {1}' \
  --preview-window 'right,55%,wrap,border-rounded' \
  --bind "start:reload($self _list)" \
  --bind 'j:down,k:up,g:first,G:last' \
  --bind "enter:transform($self _enter {1})" \
  --bind "esc:transform($self _esc)" \
  --bind "/:show-input+unbind($normal_keys)" \
  --bind "c:$(run claim)" \
  --bind "x:$(run close)" \
  --bind "o:$(run reopen)" \
  --bind "n:$(run note)" \
  --bind "e:$(run edit)" \
  --bind "t:$(run title)" \
  --bind "p:$(run priority)" \
  --bind "d:$(run defer)" \
  --bind "a:execute($self _create)+reload($self _list)" \
  --bind "r:reload($self _list)" \
  --bind "s:transform($self _toggle-closed)" \
  --bind 'v:toggle-preview' \
  --bind "!:become($self _shell)" \
  --bind 'q:abort' \
  </dev/null || true
