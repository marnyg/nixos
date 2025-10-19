{ pkgs, lib, config, ... }:
with lib;
let
  ncspot = pkgs.writeScript "ncspot" ''
          
#!/bin/bash

# The name for our dedicated ncspot session
SESSION_NAME="ncspot-music"

# Check if the session already exists.
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    # If it doesn't exist, create it detached (-d) and run ncspot.
    echo "Creating new ncspot session..."
    tmux new-session -d -s "$SESSION_NAME" "ncspot"
fi

# Attach to the session.
exec tmux attach-session -t "$SESSION_NAME"
'';



  tmux-sessionizer = pkgs.writeScript "tmux-sessionizer" ''

#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
    selected=$1
else
    # find folder with .git or .envrc in it
    selected=$(( ${pkgs.findutils}/bin/find ~/git -mindepth 1 -maxdepth 4 -name '.git' -exec dirname {} \; ; ${pkgs.findutils}/bin/find ~/git -mindepth 1 -maxdepth 4 -type f -name '.envrc' -exec dirname {} \; ) | ${pkgs.coreutils}/bin/sort -u | ${pkgs.fzf}/bin/fzf)
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

        # `g` for git 
        bind-key g run-shell "tmux display-popup -w 90% -h 90% -d '#{pane_current_path}' -T 'GitUi' -E 'gitui'"

        # `y` for yazi file manager
        bind-key y run-shell "tmux display-popup -w 90% -h 90% -d '#{pane_current_path}' -T 'Yazi' -E 'yazi'"

        # `s` for ncspot (Spotify client)
        bind-key m run-shell "tmux display-popup -w 90% -h 90% -T 'ncspot' -E '${ncspot}'"

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
