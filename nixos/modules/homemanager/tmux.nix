{ pkgs, lib, config, ... }:
with lib;
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



        # yank keybinds
        bind-key -T copy-mode-vi v send-keys -X begin-selection
        bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
        bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

        
        bind '"' split-window -v -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"

      '';
      plugins = [
        pkgs.tmuxPlugins.vim-tmux-navigator
        pkgs.tmuxPlugins.catppuccin
        pkgs.tmuxPlugins.yank
      ];
    };
  };
}
