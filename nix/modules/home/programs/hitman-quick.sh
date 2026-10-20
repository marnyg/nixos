# HITMAN 3 quicksave / quickload macro. The game has no hotkeys for these, so
# drive the pause menu with synthetic key presses via Hyprland's
# send_key_state and verify each step with a 1-pixel screenshot.
#
# Usage: hitman-quick save|load
# Bound in Hyprland to F6 (save) / F7 (load); if HITMAN isn't focused the
# key is passed through to the active window.
#
# Pause menu layout (top to bottom): SAVE, LOAD, RESTART MISSION, REPLAN
# MISSION, EXIT TO MENU. No wrap-around. SAVE is greyed out when saving is
# not allowed, in which case the cursor starts on LOAD instead of SAVE.
# Never press Enter blindly: the row below LOAD is RESTART MISSION.
#
# Packaged via writeShellApplication (hyprland.nix), which adds the shebang
# and `set -euo pipefail`. hyprctl comes from the running Hyprland session.

MODE="${1:-save}"
LOG=/tmp/hitman-quick.log
HOLD="${HITMAN_QS_HOLD:-0.05}"               # key hold; games poll per frame, a tap is missed
# Timings: 0.4/0.06/0.35/0.6 were occasionally too tight (menu transitions
# dropped a key); these are the slowest values that have proven reliable.
MENU_WAIT="${HITMAN_QS_MENU_WAIT:-0.5}"      # pause menu open animation
NAV_WAIT="${HITMAN_QS_NAV_WAIT:-0.1}"        # between cursor moves
PAGE_WAIT="${HITMAN_QS_PAGE_WAIT:-0.5}"      # between screens
CONFIRM_WAIT="${HITMAN_QS_CONFIRM_WAIT:-0.8}" # slot pick -> confirm prompt appears

case "$MODE" in
  save) KEY="${HITMAN_QS_SAVE_KEY:-F6}" ;;
  load) KEY="${HITMAN_QS_LOAD_KEY:-F7}" ;;
  *) echo "usage: $0 save|load" >&2; exit 2 ;;
esac

log() { echo "$(date +%T) [$MODE] $*" >> "$LOG"; }

# Hyprland with the Lua config only accepts Lua-form dispatchers via eval.
keystate() {  # keystate <key> <down|up>
  hyprctl eval "return hl.dispatch(hl.dsp.send_key_state({ mods = '', key = '$1', state = '$2' }))" 2>&1
}

# send <key> [seconds-to-wait-after]
send() {
  local r1 r2
  r1=$(keystate "$1" down); sleep "$HOLD"; r2=$(keystate "$1" up)
  log "send $1 -> down:$r1 up:$r2"
  sleep "${2:-0.25}"
}

# Sample one pixel of the active window at relative coords (fx, fy in 0..1).
sample() {  # prints "R G B"
  local fx=$1 fy=$2 x y w h
  read -r x y w h < <(hyprctl activewindow -j | jq -r '"\(.at[0]) \(.at[1]) \(.size[0]) \(.size[1])"')
  local px=$(( x + w * ${fx#0.} / 1000 )) py=$(( y + h * ${fy#0.} / 1000 ))
  grim -g "${px},${py} 1x1" -t ppm - | tail -c 3 | od -An -tu1 | tr -s ' '
}

is_red() {  # is_red "R G B"
  # shellcheck disable=SC2086  # split the "R G B" string on purpose
  set -- $1
  [ "$1" -gt 160 ] && [ "$2" -lt 90 ] && [ "$3" -lt 90 ]
}

# Menu row probe points, relative to the window. x=15% is inside the
# highlight bar but right of the label text: solid red or background.
HEADER="0.130 0.108"   # "PAUSE MENU" tab (red while any pause screen is open)
ROW_SAVE="0.150 0.241"
ROW_LOAD="0.150 0.303"

# shellcheck disable=SC2086  # $1 is a "fx fy" pair, split on purpose
row_red() { local rgb; rgb=$(sample $1); log "pixel($1): $rgb"; is_red "$rgb"; }

# Press Esc until the red pause header is gone (max 3), to get back in-game.
back_to_game() {
  for _ in 1 2 3; do
    send Escape "$PAGE_WAIT"
    row_red "$HEADER" || return 0
  done
  log "still in menu after 3 Esc"
}

bail() {
  send Escape 0
  log "$1"
  notify-send -t 2000 "HITMAN" "$1" 2>/dev/null || true
  exit 1
}

win=$(hyprctl activewindow -j | jq -r '.class // ""')
log "fired, class='$win'"
case "$win" in
  hitman3.exe|HITMAN3.exe|steam_app_1659040) ;;
  *) send "$KEY" 0; exit 0 ;;
esac

send Escape "$MENU_WAIT"           # open pause menu
send Up "$NAV_WAIT"; send Up "$NAV_WAIT"   # -> topmost enabled item (SAVE or LOAD)

case "$MODE" in
  save)
    row_red "$ROW_SAVE" || bail "Save not available right now"
    send Return "$PAGE_WAIT"       # open save slots
    send Return "$CONFIRM_WAIT"    # pick slot 1; overwrite prompt takes a moment
    send Return "$PAGE_WAIT"       # confirm overwrite
    log "saved"
    back_to_game
    ;;
  load)
    if row_red "$ROW_SAVE"; then send Down "$NAV_WAIT"; fi   # SAVE -> LOAD
    row_red "$ROW_LOAD" || bail "Could not reach LOAD"
    send Return "$PAGE_WAIT"       # open load slots
    send Return "$CONFIRM_WAIT"    # pick slot 1; confirm prompt takes a moment
    send Return 0                  # confirm load (game returns on its own)
    log "loaded"
    ;;
esac
