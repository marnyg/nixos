{ pkgs, lib, config, ... }:
with lib;
let
  spotify-player-popup = pkgs.writeScript "spotify-player-popup" ''

#!/bin/bash

# The name for our dedicated spotify-player session
SESSION_NAME="spotify-music"

# Check if the session already exists
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    # If it doesn't exist, create it detached (-d) and run spotify_player
    echo "Creating new spotify-player session..."
    tmux new-session -d -s "$SESSION_NAME" "spotify_player"
fi

# Simply attach to the session - the popup will handle the toggle
# When you press Escape or the keybinding again, the popup closes
exec tmux attach-session -t "$SESSION_NAME"
'';



  tmux-sessionizer = pkgs.writeScript "tmux-sessionizer" ''

#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
    selected=$1
else
    # find folder with .git or .envrc in it
    folders=$(( ${pkgs.findutils}/bin/find ~/git ~/disks/*/git* ~/disks/*/archive ~/disks/*/etc/nixos -mindepth 1 -maxdepth 4 -name '.git' -exec dirname {} \; 2>/dev/null ; ${pkgs.findutils}/bin/find ~/git ~/disks/*/git* ~/disks/*/archive ~/disks/*/etc/nixos -mindepth 1 -maxdepth 4 -type f -name '.envrc' -exec dirname {} \; 2>/dev/null ) | ${pkgs.coreutils}/bin/sort -u)

    active_sessions=$(tmux list-sessions -F '#{session_name}' 2>/dev/null || true)

    inactive_lines=""
    active_lines=""
    while IFS= read -r folder; do
        [[ -z $folder ]] && continue
        name=$(basename "$folder" | tr . _)
        if printf '%s\n' "$active_sessions" | grep -qFx "$name"; then
            # bold green + bullet, active sessions go first so they land near the fzf prompt
            active_lines+=$'\e[1;32m● '"$folder"$'\e[0m\n'
        else
            inactive_lines+="  $folder"$'\n'
        fi
    done <<< "$folders"

    selected=$(printf '%s%s' "$active_lines" "$inactive_lines" | ${pkgs.fzf}/bin/fzf --ansi --prompt='session> ' --header='● = active session')
    # strip the active-session marker or inactive padding from the selection
    selected=$(printf '%s' "$selected" | ${pkgs.gnused}/bin/sed -e 's/^● //' -e 's/^  //')
fi

if [[ -z $selected ]]; then
    exit 0
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -s $selected_name -c $selected
    exit 0
fi

if ! tmux has-session -t=$selected_name 2> /dev/null; then
    tmux new-session -ds $selected_name -c $selected
fi

tmux switch-client -t $selected_name
'';
  tmux-worktree = pkgs.writeScript "tmux-worktree" ''

#!/usr/bin/env bash
# Create a new git worktree from the current repo and open it in a tmux
# session with three panes: nvim (left), claude (top-right), shell (bottom-right).
#
# Invoked from the tmux keybinding as:
#   tmux-worktree <pane_current_path> <branch>
#
# Worktree path follows worktrunk's default template:
#   {{ repo_path }}/../{{ repo }}.{{ branch | sanitize }}
# so `wt list` / `wt remove` from anywhere keep working.

set -euo pipefail

source_path="''${1:-}"
branch="''${2:-}"

if [[ -z $branch ]]; then
    tmux display-message "tmux-worktree: branch name required"
    exit 0
fi

cd "$source_path"

if ! repo_root=$(${pkgs.git}/bin/git rev-parse --show-toplevel 2>/dev/null); then
    tmux display-message "tmux-worktree: not in a git repository"
    exit 0
fi

repo_name=$(${pkgs.coreutils}/bin/basename "$repo_root")
sanitized=''${branch//\//-}
worktree_path="$(${pkgs.coreutils}/bin/dirname "$repo_root")/''${repo_name}.''${sanitized}"

if [[ ! -d $worktree_path ]]; then
    if ! ${pkgs.git}/bin/git worktree add -b "$branch" "$worktree_path" 2> /tmp/tmux-worktree.err; then
        tmux display-message "tmux-worktree: $(${pkgs.coreutils}/bin/cat /tmp/tmux-worktree.err)"
        exit 0
    fi
fi

session_name=$(${pkgs.coreutils}/bin/basename "$worktree_path" | ${pkgs.coreutils}/bin/tr . _)

if ! tmux has-session -t="$session_name" 2>/dev/null; then
    # Left pane: nvim
    tmux new-session -ds "$session_name" -c "$worktree_path" -n editor
    tmux send-keys -t "''${session_name}:editor" "nvim ." C-m

    # Right column: claude on top, shell on bottom
    tmux split-window -h -l 40% -t "''${session_name}:editor" -c "$worktree_path"
    tmux send-keys -t "''${session_name}:editor.2" "claude" C-m

    tmux split-window -v -l 30% -t "''${session_name}:editor.2" -c "$worktree_path"

    tmux select-pane -t "''${session_name}:editor.1"
fi

if [[ -z ''${TMUX:-} ]]; then
    tmux attach-session -t "$session_name"
else
    tmux switch-client -t "$session_name"
fi
'';

  toggle-side-notes = pkgs.writeScript "toggle-side-notes" ''
    #!/usr/bin/env bash
    P=$(tmux show -wqv @myspecialpane)                                            # get the special pane id
    if [ -n "$P" ] && tmux list-panes -F'#{pane_id}' | grep -q "^$P$"; then       # check if notes pane is open
         tmux send-keys -t "$P" 'Escape' C-m ':qa!' C-m                           # if nvim is open, close it. this will also close the pane
         sleep .5                                                                 # Give some time for nvim to close
    else
         P=$(tmux splitw -hPF'#{pane_id}' -- 'cd ~/git/notes/; nvim index.norg')   # if not, open a new one
         tmux set -w @myspecialpane "$P"                                          # set the special pane id
    fi
  '';
in

{
  options.modules.my.tmux = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.my.tmux.enable {
    programs.tmux = {
      enable = true;
      keyMode = "vi";
      escapeTime = 0;
      mouse = true;
      terminal = "tmux-256color";
      #shell = "${pkgs.fish}/bin/fish";
      #newSession = true;
      extraConfig = /* */''
        set-option -ga terminal-overrides ",xterm-256color:Tc"
        set-option -ga terminal-overrides ",ghostty:Tc"
        
        # Enable RGB colour if running in xterm or 256 color mode
        set-option -sa terminal-features ',xterm-256color:RGB'
        set-option -sa terminal-features ',tmux-256color:RGB'
        
        # Enable extended keys
        set -s extended-keys on
        
        # Enable focus events
        set -g focus-events on

        # Fix double-click to select pane - select and pass through in one click
        bind -n MouseDown1Pane select-pane -t = \; send-keys -M

        # Start windows and panes at 1, not 0
        set -g base-index 1
        set -g pane-base-index 1
        set-window-option -g pane-base-index 1
        set-option -g renumber-windows on
        
        # CRITICAL: Set allow-passthrough to 'on' for image support
        # Note: image.nvim expects 'on' not 'all'
        set -g allow-passthrough on
        set -g visual-activity off

        bind-key n run-shell "${toggle-side-notes}"

        bind-key -r C-h prev
        bind-key -r C-l next
        bind-key -r C-j switch-client -p
        bind-key -r C-k switch-client -n
        bind-key -r C-Left resize-pane -L 10
        bind-key -r C-Right resize-pane -R 10
        bind-key -r C-Up resize-pane -U 10
        bind-key -r C-Down resize-pane -D 10
        bind -n M-u attach-session -t . -c '#{pane_current_path}'
        set -g repeat-time 1000

        bind-key r source-file ~/.config/tmux/tmux.conf
        # --- POPUP BINDINGS ---
        # `f` for find-session (sessionizer)
        bind-key f run-shell "tmux display-popup -w 90% -h 90% -E '${tmux-sessionizer}'"

        # `W` for new worktree: prompt for branch, create worktree, open session
        bind-key W command-prompt -p "new worktree branch:" "run-shell '${tmux-worktree} #{pane_current_path} %%'"

        # `g` for git 
        bind-key g run-shell "tmux display-popup -w 90% -h 90% -d '#{pane_current_path}' -T 'GitUi' -E 'gitui'"

        # `y` for yazi file manager
        bind-key y run-shell "tmux display-popup -w 90% -h 90% -d '#{pane_current_path}' -T 'Yazi' -E 'yazi'"

        # `m` for music (spotify-player) - toggles popup
        bind-key m if-shell -F '#{==:#{session_name},spotify-music}' 'detach-client' "run-shell \"tmux display-popup -w 90% -h 90% -T 'Spotify' -E '${spotify-player-popup}'\""

        # `k` for keybingd
        bind-key k run-shell "tmux display-popup -w 90% -h 90% -d '#{pane_current_path}' -T 'Keybindings' -E 'tmux list-keys | fzf'"

        # yank keybinds
        bind-key -T copy-mode-vi v send-keys -X begin-selection
        bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
        bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

        
        bind '"' split-window -v -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"


        bind-key x confirm-before -p "Kill #S (y/n)?" "run-shell 'tmux switch-client -n \\\; kill-session -t \"#S\"'"
      '';
      plugins = [
        pkgs.tmuxPlugins.vim-tmux-navigator
        pkgs.tmuxPlugins.catppuccin
        pkgs.tmuxPlugins.yank
      ];
    };
  };
}
