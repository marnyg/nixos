{ pkgs, lib, config, ... }:
with lib;
let
  swich-on-kill = pkgs.writeScript "" ''
    #!/bin/bash

    # Get current session name
    current_session=$(tmux display-message -p '#{session_name}')
  
    # Check if there are any panes left in the current session
    pane_count=$(tmux list-panes -t $current_session -F "#{pane_active}" | wc -l)
  
    if [ "$pane_count" -eq 0 ]; then
      # Switch to the next session
      tmux switch-client -n
    fi
  '';
  tmux-sessionizer = pkgs.writeScript "tmux-sessionizer" ''

#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(find ~/git -mindepth 1 -maxdepth 4 -type d -name '.git' -exec dirname {} \; | fzf)
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
in

{
  options.modules.tmux = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.tmux.enable {
    programs.tmux = {
      enable = true;
      keyMode = "vi";
      escapeTime = 0;
      mouse = true;
      terminal = "screen-256color";
      #newSession = true;
      extraConfig = ''
        set-option -ga terminal-overrides ",xterm-256color:Tc"

        # Start windows and panes at 1, not 0
        set -g base-index 1
        set -g pane-base-index 1
        set-window-option -g pane-base-index 1
        set-option -g renumber-windows on

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

        bind-key f run-shell "tmux neww ${tmux-sessionizer}"
        bind-key r source-file ~/.config/tmux/tmux.conf


        # yank keybinds
        bind-key -T copy-mode-vi v send-keys -X begin-selection
        bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
        bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

        
        bind '"' split-window -v -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"

        # Hook to run after a pane is killed
        set-hook -g pane-died 'run-shell "${swich-on-kill}"'
      '';
      plugins = [
        pkgs.tmuxPlugins.vim-tmux-navigator
        pkgs.tmuxPlugins.catppuccin
        pkgs.tmuxPlugins.yank
      ];
    };
  };
}
