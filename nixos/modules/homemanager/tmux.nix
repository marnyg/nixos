{ pkgs, lib, config, ... }:
with lib;
let
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

        # scroll tmux buffer if not in (n)vim
        #bind -n C-u if-shell "ps -o comm= -p #{pane_tty}| tail -1 | grep -iqE '(vim|nvim)'" "send-keys C-u" "if-shell -F -t = '#{pane_in_mode}' 'send-keys -X halfpage-up' 'copy-mode -u; send-keys -X halfpage-up'"
        #bind -n C-d if-shell "ps -o comm= -p #{pane_tty}| tail -1 | grep -iqE '(vim|nvim)'" "send-keys C-d" "if-shell -F -t = '#{pane_in_mode}' 'send-keys -X halfpage-down' 'copy-mode -u; send-keys -X halfpage-down'"
        #bind -n C-e if-shell "ps -o comm= -p #{pane_tty}| tail -1 | grep -iqE '(vim|nvim)'" "send-keys C-e" "if-shell -F -t = '#{pane_in_mode}' 'send-keys -X scroll-down' 'copy-mode -u; send-keys -X scroll-down'"
        #bind -n C-y if-shell "ps -o comm= -p #{pane_tty}| tail -1 | grep -iqE '(vim|nvim)'" "send-keys C-y" "if-shell -F -t = '#{pane_in_mode}' 'send-keys -X scroll-up' 'copy-mode -u; send-keys -X scroll-up'"

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
