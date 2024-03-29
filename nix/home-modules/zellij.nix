{ lib, config, ... }:
with lib;
{
  options.modules.zellij = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.zellij.enable {
    programs.zellij = {
      enable = true;
      settings = {
        keybinds = {
          entersearch = [
            {
              action = [{ SwitchToMode = "Search"; }];
              key = [{ Char = "\n"; }];
            }
            {
              action = [{ SearchInput = [ 27 ]; } { SwitchToMode = "Scroll"; }];
              key = [{ Ctrl = "c"; } "Esc"];
            }
            {
              action = [{ NewPane = null; }];
              key = [{ Alt = "n"; }];
            }
            {
              action = [{ MoveFocusOrTab = "Left"; }];
              key = [{ Alt = "h"; } { Alt = "Left"; }];
            }
            {
              action = [{ MoveFocusOrTab = "Right"; }];
              key = [{ Alt = "l"; } { Alt = "Right"; }];
            }
            {
              action = [{ MoveFocus = "Down"; }];
              key = [{ Alt = "j"; } { Alt = "Down"; }];
            }
            {
              action = [{ MoveFocus = "Up"; }];
              key = [{ Alt = "k"; } { Alt = "Up"; }];
            }
            {
              action = [{ Resize = "Increase"; }];
              key = [{ Alt = "="; }];
            }
            {
              action = [{ Resize = "Increase"; }];
              key = [{ Alt = "+"; }];
            }
            {
              action = [{ Resize = "Decrease"; }];
              key = [{ Alt = "-"; }];
            }
          ];
          locked = [{
            action = [{ SwitchToMode = "Normal"; }];
            key = [{ Ctrl = "g"; }];
          }];
          move = [
            {
              action = [{ SwitchToMode = "Locked"; }];
              key = [{ Ctrl = "g"; }];
            }
            {
              action = [{ SwitchToMode = "Pane"; }];
              key = [{ Ctrl = "p"; }];
            }
            {
              action = [{ SwitchToMode = "Tab"; }];
              key = [{ Ctrl = "t"; }];
            }
            #{
            #  action = [{ SwitchToMode = "Resize"; }];
            #  key = [{ Ctrl = "n"; }];
            #}
            #{
            #  action = [{ SwitchToMode = "Normal"; }];
            #  key = [ { Ctrl = "h"; } { Char = "\n"; } { Char = " "; } "Esc" ];
            #}
            {
              action = [{ SwitchToMode = "Scroll"; }];
              key = [{ Ctrl = "s"; }];
            }
            {
              action = [{ SwitchToMode = "Session"; }];
              key = [{ Ctrl = "o"; }];
            }
            {
              action = [ "Quit" ];
              key = [{ Ctrl = "q"; }];
            }
            {
              action = [{ MovePane = null; }];
              key = [{ Char = "n"; } { Char = "	"; }];
            }
            {
              action = [{ MovePane = "Left"; }];
              key = [{ Char = "h"; } "Left"];
            }
            {
              action = [{ MovePane = "Down"; }];
              key = [{ Char = "j"; } "Down"];
            }
            {
              action = [{ MovePane = "Up"; }];
              key = [{ Char = "k"; } "Up"];
            }
            {
              action = [{ MovePane = "Right"; }];
              key = [{ Char = "l"; } "Right"];
            }
            {
              action = [{ NewPane = null; }];
              key = [{ Alt = "n"; }];
            }
            {
              action = [{ MoveFocusOrTab = "Left"; }];
              key = [{ Alt = "h"; } { Alt = "Left"; }];
            }
            {
              action = [{ MoveFocusOrTab = "Right"; }];
              key = [{ Alt = "l"; } { Alt = "Right"; }];
            }
            {
              action = [{ MoveFocus = "Down"; }];
              key = [{ Alt = "j"; } { Alt = "Down"; }];
            }
            {
              action = [{ MoveFocus = "Up"; }];
              key = [{ Alt = "k"; } { Alt = "Up"; }];
            }
            {
              action = [{ Resize = "Increase"; }];
              key = [{ Alt = "="; }];
            }
            {
              action = [{ Resize = "Increase"; }];
              key = [{ Alt = "+"; }];
            }
            {
              action = [{ Resize = "Decrease"; }];
              key = [{ Alt = "-"; }];
            }
          ];
          normal = [
            {
              action = [{ SwitchToMode = "Locked"; }];
              key = [{ Ctrl = "g"; }];
            }
            {
              action = [{ SwitchToMode = "Pane"; }];
              key = [{ Ctrl = "p"; }];
            }
            #{
            #  action = [{ SwitchToMode = "Resize"; }];
            #  key = [{ Ctrl = "n"; }];
            #}
            {
              action = [{ SwitchToMode = "Tab"; }];
              key = [{ Ctrl = "t"; }];
            }
            {
              action = [{ SwitchToMode = "Scroll"; }];
              key = [{ Ctrl = "s"; }];
            }
            {
              action = [{ SwitchToMode = "Session"; }];
              key = [{ Ctrl = "o"; }];
            }
            #{
            #  action = [{ SwitchToMode = "Move"; }];
            #  key = [{ Ctrl = "h"; }];
            #}
            {
              action = [{ SwitchToMode = "Tmux"; }];
              key = [{ Ctrl = "b"; }];
            }
            {
              action = [ "Quit" ];
              key = [{ Ctrl = "q"; }];
            }
            {
              action = [{ NewPane = null; }];
              key = [{ Alt = "n"; }];
            }
            {
              action = [{ MoveFocusOrTab = "Left"; }];
              key = [{ Alt = "h"; } { Alt = "Left"; }];
            }
            {
              action = [{ MoveFocusOrTab = "Right"; }];
              key = [{ Alt = "l"; } { Alt = "Right"; }];
            }
            {
              action = [{ MoveFocus = "Down"; }];
              key = [{ Alt = "j"; } { Alt = "Down"; }];
            }
            {
              action = [{ MoveFocus = "Up"; }];
              key = [{ Alt = "k"; } { Alt = "Up"; }];
            }
            {
              action = [{ Resize = "Increase"; }];
              key = [{ Alt = "="; }];
            }
            {
              action = [{ Resize = "Increase"; }];
              key = [{ Alt = "+"; }];
            }
            {
              action = [{ Resize = "Decrease"; }];
              key = [{ Alt = "-"; }];
            }
          ];
          pane = [
            {
              action = [{ SwitchToMode = "Locked"; }];
              key = [{ Ctrl = "g"; }];
            }
            #{
            #  action = [{ SwitchToMode = "Resize"; }];
            #  key = [{ Ctrl = "n"; }];
            #}
            {
              action = [{ SwitchToMode = "Tab"; }];
              key = [{ Ctrl = "t"; }];
            }
            {
              action = [{ SwitchToMode = "Normal"; }];
              key = [{ Ctrl = "p"; } { Char = "\n"; } { Char = " "; } "Esc"];
            }
            {
              action = [{ SwitchToMode = "Scroll"; }];
              key = [{ Ctrl = "s"; }];
            }
            {
              action = [{ SwitchToMode = "Session"; }];
              key = [{ Ctrl = "o"; }];
            }
            #{
            #  action = [{ SwitchToMode = "Move"; }];
            #  key = [{ Ctrl = "h"; }];
            #}
            {
              action = [{ SwitchToMode = "Tmux"; }];
              key = [{ Ctrl = "b"; }];
            }
            {
              action = [ "Quit" ];
              key = [{ Ctrl = "q"; }];
            }
            {
              action = [{ MoveFocus = "Left"; }];
              key = [{ Char = "h"; } "Left"];
            }
            {
              action = [{ MoveFocus = "Right"; }];
              key = [{ Char = "l"; } "Right"];
            }
            {
              action = [{ MoveFocus = "Down"; }];
              key = [{ Char = "j"; } "Down"];
            }
            {
              action = [{ MoveFocus = "Up"; }];
              key = [{ Char = "k"; } "Up"];
            }
            {
              action = [ "SwitchFocus" ];
              key = [{ Char = "p"; }];
            }
            {
              action = [{ NewPane = null; } { SwitchToMode = "Normal"; }];
              key = [{ Char = "n"; }];
            }
            {
              action = [{ NewPane = "Down"; } { SwitchToMode = "Normal"; }];
              key = [{ Char = "d"; }];
            }
            {
              action = [{ NewPane = "Right"; } { SwitchToMode = "Normal"; }];
              key = [{ Char = "r"; }];
            }
            {
              action = [ "CloseFocus" { SwitchToMode = "Normal"; } ];
              key = [{ Char = "x"; }];
            }
            {
              action = [ "ToggleFocusFullscreen" { SwitchToMode = "Normal"; } ];
              key = [{ Char = "f"; }];
            }
            {
              action = [ "TogglePaneFrames" { SwitchToMode = "Normal"; } ];
              key = [{ Char = "z"; }];
            }
            {
              action = [ "ToggleFloatingPanes" { SwitchToMode = "Normal"; } ];
              key = [{ Char = "w"; }];
            }
            {
              action =
                [ "TogglePaneEmbedOrFloating" { SwitchToMode = "Normal"; } ];
              key = [{ Char = "e"; }];
            }
            {
              action = [{ NewPane = null; }];
              key = [{ Alt = "n"; }];
            }
            {
              action = [{ MoveFocusOrTab = "Left"; }];
              key = [{ Alt = "h"; } { Alt = "Left"; }];
            }
            {
              action = [{ MoveFocusOrTab = "Right"; }];
              key = [{ Alt = "l"; } { Alt = "Right"; }];
            }
            {
              action = [{ MoveFocus = "Down"; }];
              key = [{ Alt = "j"; } { Alt = "Down"; }];
            }
            {
              action = [{ MoveFocus = "Up"; }];
              key = [{ Alt = "k"; } { Alt = "Up"; }];
            }
            {
              action = [{ Resize = "Increase"; }];
              key = [{ Alt = "="; }];
            }
            {
              action = [{ Resize = "Increase"; }];
              key = [{ Alt = "+"; }];
            }
            {
              action = [{ Resize = "Decrease"; }];
              key = [{ Alt = "-"; }];
            }
            {
              action =
                [{ SwitchToMode = "RenamePane"; } { PaneNameInput = [ 0 ]; }];
              key = [{ Char = "c"; }];
            }
          ];
          renamepane = [
            {
              action = [{ SwitchToMode = "Normal"; }];
              key = [{ Char = "\n"; } { Ctrl = "c"; } "Esc"];
            }
            {
              action = [ "UndoRenamePane" { SwitchToMode = "Pane"; } ];
              key = [ "Esc" ];
            }
            {
              action = [{ NewPane = null; }];
              key = [{ Alt = "n"; }];
            }
            {
              action = [{ MoveFocusOrTab = "Left"; }];
              key = [{ Alt = "h"; } { Alt = "Left"; }];
            }
            {
              action = [{ MoveFocusOrTab = "Right"; }];
              key = [{ Alt = "l"; } { Alt = "Right"; }];
            }
            {
              action = [{ MoveFocus = "Down"; }];
              key = [{ Alt = "j"; } { Alt = "Down"; }];
            }
            {
              action = [{ MoveFocus = "Up"; }];
              key = [{ Alt = "k"; } { Alt = "Up"; }];
            }
            {
              action = [{ Resize = "Increase"; }];
              key = [{ Alt = "="; }];
            }
            {
              action = [{ Resize = "Increase"; }];
              key = [{ Alt = "+"; }];
            }
            {
              action = [{ Resize = "Decrease"; }];
              key = [{ Alt = "-"; }];
            }
          ];
          renametab = [
            {
              action = [{ SwitchToMode = "Normal"; }];
              key = [{ Char = "\n"; } { Ctrl = "c"; } "Esc"];
            }
            {
              action = [ "UndoRenameTab" { SwitchToMode = "Tab"; } ];
              key = [ "Esc" ];
            }
            {
              action = [{ NewPane = null; }];
              key = [{ Alt = "n"; }];
            }
            {
              action = [{ MoveFocusOrTab = "Left"; }];
              key = [{ Alt = "h"; } { Alt = "Left"; }];
            }
            {
              action = [{ MoveFocusOrTab = "Right"; }];
              key = [{ Alt = "l"; } { Alt = "Right"; }];
            }
            {
              action = [{ MoveFocus = "Down"; }];
              key = [{ Alt = "j"; } { Alt = "Down"; }];
            }
            {
              action = [{ MoveFocus = "Up"; }];
              key = [{ Alt = "k"; } { Alt = "Up"; }];
            }
            {
              action = [{ Resize = "Increase"; }];
              key = [{ Alt = "="; }];
            }
            {
              action = [{ Resize = "Increase"; }];
              key = [{ Alt = "+"; }];
            }
            {
              action = [{ Resize = "Decrease"; }];
              key = [{ Alt = "-"; }];
            }
          ];
          resize = [
            {
              action = [{ SwitchToMode = "Locked"; }];
              key = [{ Ctrl = "g"; }];
            }
            {
              action = [{ SwitchToMode = "Pane"; }];
              key = [{ Ctrl = "p"; }];
            }
            {
              action = [{ SwitchToMode = "Tab"; }];
              key = [{ Ctrl = "t"; }];
            }
            #{
            #  action = [{ SwitchToMode = "Normal"; }];
            #  key = [ { Ctrl = "n"; } { Char = "\n"; } { Char = " "; } "Esc" ];
            #}
            {
              action = [{ SwitchToMode = "Scroll"; }];
              key = [{ Ctrl = "s"; }];
            }
            {
              action = [{ SwitchToMode = "Session"; }];
              key = [{ Ctrl = "o"; }];
            }
            #{
            #  action = [{ SwitchToMode = "Move"; }];
            #  key = [{ Ctrl = "h"; }];
            #}
            {
              action = [{ SwitchToMode = "Tmux"; }];
              key = [{ Ctrl = "b"; }];
            }
            {
              action = [ "Quit" ];
              key = [{ Ctrl = "q"; }];
            }
            {
              action = [{ Resize = "Left"; }];
              key = [{ Char = "h"; } "Left"];
            }
            {
              action = [{ Resize = "Down"; }];
              key = [{ Char = "j"; } "Down"];
            }
            {
              action = [{ Resize = "Up"; }];
              key = [{ Char = "k"; } "Up"];
            }
            {
              action = [{ Resize = "Right"; }];
              key = [{ Char = "l"; } "Right"];
            }
            {
              action = [{ Resize = "Increase"; }];
              key = [{ Char = "="; }];
            }
            {
              action = [{ Resize = "Increase"; }];
              key = [{ Char = "+"; }];
            }
            {
              action = [{ Resize = "Decrease"; }];
              key = [{ Char = "-"; }];
            }
            {
              action = [{ NewPane = null; }];
              key = [{ Alt = "n"; }];
            }
            {
              action = [{ MoveFocusOrTab = "Left"; }];
              key = [{ Alt = "h"; } { Alt = "Left"; }];
            }
            {
              action = [{ MoveFocusOrTab = "Right"; }];
              key = [{ Alt = "l"; } { Alt = "Right"; }];
            }
            {
              action = [{ MoveFocus = "Down"; }];
              key = [{ Alt = "j"; } { Alt = "Down"; }];
            }
            {
              action = [{ MoveFocus = "Up"; }];
              key = [{ Alt = "k"; } { Alt = "Up"; }];
            }
            {
              action = [{ Resize = "Increase"; }];
              key = [{ Alt = "="; }];
            }
            {
              action = [{ Resize = "Increase"; }];
              key = [{ Alt = "+"; }];
            }
            {
              action = [{ Resize = "Decrease"; }];
              key = [{ Alt = "-"; }];
            }
          ];
          scroll = [
            {
              action = [ "EditScrollback" { SwitchToMode = "Normal"; } ];
              key = [{ Char = "e"; }];
            }
            {
              action = [{ SwitchToMode = "Normal"; }];
              key = [{ Ctrl = "s"; } { Char = " "; } { Char = "\n"; } "Esc"];
            }
            {
              action = [{ SwitchToMode = "Tab"; }];
              key = [{ Ctrl = "t"; }];
            }
            {
              action = [{ SwitchToMode = "Locked"; }];
              key = [{ Ctrl = "g"; }];
            }
            {
              action = [{ SwitchToMode = "Pane"; }];
              key = [{ Ctrl = "p"; }];
            }
            #{
            #  action = [{ SwitchToMode = "Move"; }];
            #  key = [{ Ctrl = "h"; }];
            #}
            {
              action = [{ SwitchToMode = "Tmux"; }];
              key = [{ Ctrl = "b"; }];
            }
            {
              action = [{ SwitchToMode = "Session"; }];
              key = [{ Ctrl = "o"; }];
            }
            #{
            #  action = [{ SwitchToMode = "Resize"; }];
            #  key = [{ Ctrl = "n"; }];
            #}
            {
              action = [ "ScrollToBottom" { SwitchToMode = "Normal"; } ];
              key = [{ Ctrl = "c"; }];
            }
            {
              action = [ "Quit" ];
              key = [{ Ctrl = "q"; }];
            }
            {
              action = [ "ScrollDown" ];
              key = [{ Char = "j"; } "Down"];
            }
            {
              action = [ "ScrollUp" ];
              key = [{ Char = "k"; } "Up"];
            }
            {
              action = [ "PageScrollDown" ];
              key = [{ Ctrl = "f"; } "PageDown" "Right" { Char = "l"; }];
            }
            {
              action = [ "PageScrollUp" ];
              key = [{ Ctrl = "b"; } "PageUp" "Left" { Char = "h"; }];
            }
            {
              action = [ "HalfPageScrollDown" ];
              key = [{ Char = "d"; }];
            }
            {
              action = [ "HalfPageScrollUp" ];
              key = [{ Char = "u"; }];
            }
            {
              action = [{ NewPane = null; }];
              key = [{ Alt = "n"; }];
            }
            {
              action = [{ MoveFocusOrTab = "Left"; }];
              key = [{ Alt = "h"; } { Alt = "Left"; }];
            }
            {
              action = [{ MoveFocusOrTab = "Right"; }];
              key = [{ Alt = "l"; } { Alt = "Right"; }];
            }
            {
              action = [{ MoveFocus = "Down"; }];
              key = [{ Alt = "j"; } { Alt = "Down"; }];
            }
            {
              action = [{ MoveFocus = "Up"; }];
              key = [{ Alt = "k"; } { Alt = "Up"; }];
            }
            {
              action = [{ Resize = "Increase"; }];
              key = [{ Alt = "="; }];
            }
            {
              action = [{ Resize = "Increase"; }];
              key = [{ Alt = "+"; }];
            }
            {
              action = [{ Resize = "Decrease"; }];
              key = [{ Alt = "-"; }];
            }
            {
              action =
                [{ SwitchToMode = "EnterSearch"; } { SearchInput = [ 0 ]; }];
              key = [{ Char = "s"; }];
            }
          ];
          search = [
            {
              action = [{ SwitchToMode = "Normal"; }];
              key = [{ Ctrl = "s"; } { Char = " "; } { Char = "\n"; } "Esc"];
            }
            {
              action = [{ SwitchToMode = "Tab"; }];
              key = [{ Ctrl = "t"; }];
            }
            {
              action = [{ SwitchToMode = "Locked"; }];
              key = [{ Ctrl = "g"; }];
            }
            {
              action = [{ SwitchToMode = "Pane"; }];
              key = [{ Ctrl = "p"; }];
            }
            {
              action = [{ SwitchToMode = "Move"; }];
              key = [{ Ctrl = "h"; }];
            }
            {
              action = [{ SwitchToMode = "Tmux"; }];
              key = [{ Ctrl = "b"; }];
            }
            {
              action = [{ SwitchToMode = "Session"; }];
              key = [{ Ctrl = "o"; }];
            }
            #{
            #  action = [{ SwitchToMode = "Resize"; }];
            #  key = [{ Ctrl = "n"; }];
            #}
            {
              action = [ "ScrollToBottom" { SwitchToMode = "Normal"; } ];
              key = [{ Ctrl = "c"; }];
            }
            {
              action = [ "Quit" ];
              key = [{ Ctrl = "q"; }];
            }
            {
              action = [ "ScrollDown" ];
              key = [{ Char = "j"; } "Down"];
            }
            {
              action = [ "ScrollUp" ];
              key = [{ Char = "k"; } "Up"];
            }
            {
              action = [ "PageScrollDown" ];
              key = [{ Ctrl = "f"; } "PageDown" "Right" { Char = "l"; }];
            }
            {
              action = [ "PageScrollUp" ];
              key = [{ Ctrl = "b"; } "PageUp" "Left" { Char = "h"; }];
            }
            {
              action = [ "HalfPageScrollDown" ];
              key = [{ Char = "d"; }];
            }
            {
              action = [ "HalfPageScrollUp" ];
              key = [{ Char = "u"; }];
            }
            {
              action = [{ NewPane = null; }];
              key = [{ Alt = "n"; }];
            }
            {
              action = [{ MoveFocusOrTab = "Left"; }];
              key = [{ Alt = "h"; } { Alt = "Left"; }];
            }
            {
              action = [{ MoveFocusOrTab = "Right"; }];
              key = [{ Alt = "l"; } { Alt = "Right"; }];
            }
            {
              action = [{ MoveFocus = "Down"; }];
              key = [{ Alt = "j"; } { Alt = "Down"; }];
            }
            {
              action = [{ MoveFocus = "Up"; }];
              key = [{ Alt = "k"; } { Alt = "Up"; }];
            }
            {
              action = [{ Resize = "Increase"; }];
              key = [{ Alt = "="; }];
            }
            {
              action = [{ Resize = "Increase"; }];
              key = [{ Alt = "+"; }];
            }
            {
              action = [{ Resize = "Decrease"; }];
              key = [{ Alt = "-"; }];
            }
            {
              action =
                [{ SwitchToMode = "EnterSearch"; } { SearchInput = [ 0 ]; }];
              key = [{ Char = "s"; }];
            }
            {
              action = [{ Search = "Down"; }];
              key = [{ Char = "n"; }];
            }
            {
              action = [{ Search = "Up"; }];
              key = [{ Char = "p"; }];
            }
            {
              action = [{ SearchToggleOption = "CaseSensitivity"; }];
              key = [{ Char = "c"; }];
            }
            {
              action = [{ SearchToggleOption = "Wrap"; }];
              key = [{ Char = "w"; }];
            }
            {
              action = [{ SearchToggleOption = "WholeWord"; }];
              key = [{ Char = "o"; }];
            }
          ];
          session = [
            {
              action = [{ SwitchToMode = "Locked"; }];
              key = [{ Ctrl = "g"; }];
            }
            #{
            #  action = [{ SwitchToMode = "Resize"; }];
            #  key = [{ Ctrl = "n"; }];
            #}
            {
              action = [{ SwitchToMode = "Pane"; }];
              key = [{ Ctrl = "p"; }];
            }
            #{
            #  action = [{ SwitchToMode = "Move"; }];
            #  key = [{ Ctrl = "h"; }];
            #}
            {
              action = [{ SwitchToMode = "Tmux"; }];
              key = [{ Ctrl = "b"; }];
            }
            {
              action = [{ SwitchToMode = "Tab"; }];
              key = [{ Ctrl = "t"; }];
            }
            {
              action = [{ SwitchToMode = "Normal"; }];
              key = [{ Ctrl = "o"; } { Char = "\n"; } { Char = " "; } "Esc"];
            }
            {
              action = [{ SwitchToMode = "Scroll"; }];
              key = [{ Ctrl = "s"; }];
            }
            {
              action = [ "Quit" ];
              key = [{ Ctrl = "q"; }];
            }
            {
              action = [ "Detach" ];
              key = [{ Char = "d"; }];
            }
            {
              action = [{ NewPane = null; }];
              key = [{ Alt = "n"; }];
            }
            {
              action = [{ MoveFocusOrTab = "Left"; }];
              key = [{ Alt = "h"; } { Alt = "Left"; }];
            }
            {
              action = [{ MoveFocusOrTab = "Right"; }];
              key = [{ Alt = "l"; } { Alt = "Right"; }];
            }
            {
              action = [{ MoveFocus = "Down"; }];
              key = [{ Alt = "j"; } { Alt = "Down"; }];
            }
            {
              action = [{ MoveFocus = "Up"; }];
              key = [{ Alt = "k"; } { Alt = "Up"; }];
            }
            {
              action = [{ Resize = "Increase"; }];
              key = [{ Alt = "="; }];
            }
            {
              action = [{ Resize = "Increase"; }];
              key = [{ Alt = "+"; }];
            }
            {
              action = [{ Resize = "Decrease"; }];
              key = [{ Alt = "-"; }];
            }
          ];
          tab = [
            {
              action = [{ SwitchToMode = "Locked"; }];
              key = [{ Ctrl = "g"; }];
            }
            {
              action = [{ SwitchToMode = "Pane"; }];
              key = [{ Ctrl = "p"; }];
            }
            #{
            #  action = [{ SwitchToMode = "Resize"; }];
            #  key = [{ Ctrl = "n"; }];
            #}
            {
              action = [{ SwitchToMode = "Normal"; }];
              key = [{ Ctrl = "t"; } { Char = "\n"; } { Char = " "; } "Esc"];
            }
            {
              action = [{ SwitchToMode = "Scroll"; }];
              key = [{ Ctrl = "s"; }];
            }
            #{
            #  action = [{ SwitchToMode = "Move"; }];
            #  key = [{ Ctrl = "h"; }];
            #}
            {
              action = [{ SwitchToMode = "Tmux"; }];
              key = [{ Ctrl = "b"; }];
            }
            {
              action = [{ SwitchToMode = "Session"; }];
              key = [{ Ctrl = "o"; }];
            }
            {
              action =
                [{ SwitchToMode = "RenameTab"; } { TabNameInput = [ 0 ]; }];
              key = [{ Char = "r"; }];
            }
            {
              action = [ "Quit" ];
              key = [{ Ctrl = "q"; }];
            }
            {
              action = [ "GoToPreviousTab" ];
              key = [{ Char = "h"; } "Left" "Up" { Char = "k"; }];
            }
            {
              action = [ "GoToNextTab" ];
              key = [{ Char = "l"; } "Right" "Down" { Char = "j"; }];
            }
            {
              action = [{ NewTab = null; } { SwitchToMode = "Normal"; }];
              key = [{ Char = "n"; }];
            }
            {
              action = [ "CloseTab" { SwitchToMode = "Normal"; } ];
              key = [{ Char = "x"; }];
            }
            {
              action = [ "ToggleActiveSyncTab" { SwitchToMode = "Normal"; } ];
              key = [{ Char = "s"; }];
            }
            {
              action = [{ GoToTab = 1; } { SwitchToMode = "Normal"; }];
              key = [{ Char = "1"; }];
            }
            {
              action = [{ GoToTab = 2; } { SwitchToMode = "Normal"; }];
              key = [{ Char = "2"; }];
            }
            {
              action = [{ GoToTab = 3; } { SwitchToMode = "Normal"; }];
              key = [{ Char = "3"; }];
            }
            {
              action = [{ GoToTab = 4; } { SwitchToMode = "Normal"; }];
              key = [{ Char = "4"; }];
            }
            {
              action = [{ GoToTab = 5; } { SwitchToMode = "Normal"; }];
              key = [{ Char = "5"; }];
            }
            {
              action = [{ GoToTab = 6; } { SwitchToMode = "Normal"; }];
              key = [{ Char = "6"; }];
            }
            {
              action = [{ GoToTab = 7; } { SwitchToMode = "Normal"; }];
              key = [{ Char = "7"; }];
            }
            {
              action = [{ GoToTab = 8; } { SwitchToMode = "Normal"; }];
              key = [{ Char = "8"; }];
            }
            {
              action = [{ GoToTab = 9; } { SwitchToMode = "Normal"; }];
              key = [{ Char = "9"; }];
            }
            {
              action = [ "ToggleTab" ];
              key = [{ Char = "	"; }];
            }
            {
              action = [{ NewPane = null; }];
              key = [{ Alt = "n"; }];
            }
            {
              action = [{ MoveFocusOrTab = "Left"; }];
              key = [{ Alt = "h"; } { Alt = "Left"; }];
            }
            {
              action = [{ MoveFocusOrTab = "Right"; }];
              key = [{ Alt = "l"; } { Alt = "Right"; }];
            }
            {
              action = [{ MoveFocus = "Down"; }];
              key = [{ Alt = "j"; } { Alt = "Down"; }];
            }
            {
              action = [{ MoveFocus = "Up"; }];
              key = [{ Alt = "k"; } { Alt = "Up"; }];
            }
            {
              action = [{ Resize = "Increase"; }];
              key = [{ Alt = "="; }];
            }
            {
              action = [{ Resize = "Increase"; }];
              key = [{ Alt = "+"; }];
            }
            {
              action = [{ Resize = "Decrease"; }];
              key = [{ Alt = "-"; }];
            }
          ];
          tmux = [
            {
              action = [{ SwitchToMode = "Locked"; }];
              key = [{ Ctrl = "g"; }];
            }
            #{
            #  action = [{ SwitchToMode = "Resize"; }];
            #  key = [{ Ctrl = "n"; }];
            #}
            {
              action = [{ SwitchToMode = "Pane"; }];
              key = [{ Ctrl = "p"; }];
            }
            #{
            #  action = [{ SwitchToMode = "Move"; }];
            #  key = [{ Ctrl = "h"; }];
            #}
            {
              action = [{ SwitchToMode = "Tab"; }];
              key = [{ Ctrl = "t"; }];
            }
            {
              action = [{ SwitchToMode = "Normal"; }];
              key = [{ Ctrl = "o"; } { Char = "\n"; } { Char = " "; } "Esc"];
            }
            {
              action = [{ SwitchToMode = "Scroll"; }];
              key = [{ Ctrl = "s"; }];
            }
            {
              action = [{ SwitchToMode = "Scroll"; }];
              key = [{ Char = "["; }];
            }
            {
              action = [ "Quit" ];
              key = [{ Ctrl = "q"; }];
            }
            {
              action = [{ Write = [ 2 ]; } { SwitchToMode = "Normal"; }];
              key = [{ Ctrl = "b"; }];
            }
            {
              action = [{ NewPane = "Down"; } { SwitchToMode = "Normal"; }];
              key = [{ Char = ''"''; }];
            }
            {
              action = [{ NewPane = "Right"; } { SwitchToMode = "Normal"; }];
              key = [{ Char = "%"; }];
            }
            {
              action = [ "ToggleFocusFullscreen" { SwitchToMode = "Normal"; } ];
              key = [{ Char = "z"; }];
            }
            {
              action = [{ NewTab = null; } { SwitchToMode = "Normal"; }];
              key = [{ Char = "c"; }];
            }
            {
              action =
                [{ SwitchToMode = "RenameTab"; } { TabNameInput = [ 0 ]; }];
              key = [{ Char = ","; }];
            }
            {
              action = [ "GoToPreviousTab" { SwitchToMode = "Normal"; } ];
              key = [{ Char = "p"; }];
            }
            {
              action = [ "GoToNextTab" { SwitchToMode = "Normal"; } ];
              key = [{ Char = "n"; }];
            }
            {
              action = [{ MoveFocus = "Left"; } { SwitchToMode = "Normal"; }];
              key = [ "Left" ];
            }
            {
              action = [{ MoveFocus = "Right"; } { SwitchToMode = "Normal"; }];
              key = [ "Right" ];
            }
            {
              action = [{ MoveFocus = "Down"; } { SwitchToMode = "Normal"; }];
              key = [ "Down" ];
            }
            {
              action = [{ MoveFocus = "Up"; } { SwitchToMode = "Normal"; }];
              key = [ "Up" ];
            }
            {
              action = [{ MoveFocus = "Left"; } { SwitchToMode = "Normal"; }];
              key = [{ Char = "h"; }];
            }
            {
              action = [{ MoveFocus = "Right"; } { SwitchToMode = "Normal"; }];
              key = [{ Char = "l"; }];
            }
            {
              action = [{ MoveFocus = "Down"; } { SwitchToMode = "Normal"; }];
              key = [{ Char = "j"; }];
            }
            {
              action = [{ MoveFocus = "Up"; } { SwitchToMode = "Normal"; }];
              key = [{ Char = "k"; }];
            }
            {
              action = [{ NewPane = null; }];
              key = [{ Alt = "n"; }];
            }
            {
              action = [{ MoveFocusOrTab = "Left"; }];
              key = [{ Alt = "h"; } { Alt = "Left"; }];
            }
            {
              action = [{ MoveFocusOrTab = "Right"; }];
              key = [{ Alt = "l"; } { Alt = "Right"; }];
            }
            {
              action = [{ MoveFocus = "Down"; }];
              key = [{ Alt = "j"; } { Alt = "Down"; }];
            }
            {
              action = [{ MoveFocus = "Up"; }];
              key = [{ Alt = "k"; } { Alt = "Up"; }];
            }
            {
              action = [ "FocusNextPane" ];
              key = [{ Char = "o"; }];
            }
            {
              action = [{ Resize = "Increase"; }];
              key = [{ Alt = "="; }];
            }
            {
              action = [{ Resize = "Increase"; }];
              key = [{ Alt = "+"; }];
            }
            {
              action = [{ Resize = "Decrease"; }];
              key = [{ Alt = "-"; }];
            }
            {
              action = [ "Detach" ];
              key = [{ Char = "d"; }];
            }
          ];
          unbind = true;
        };
        plugins = [
          {
            path = "tab-bar";
            tag = "tab-bar";
          }
          {
            path = "status-bar";
            tag = "status-bar";
          }
          {
            path = "strider";
            tag = "strider";
          }
          {
            path = "compact-bar";
            tag = "compact-bar";
          }
        ];
      };
    };
  };
}
