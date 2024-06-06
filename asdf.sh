#!/usr/bin/env bash
P=$(tmux show -wqv @myspecialpane)
if [ -n "$P" ] && tmux list-panes -F'#{pane_id}' | grep -q "^$P$"; then
     tmux send-keys -t "$P" 'Escape' C-m ':qa!' C-m
     sleep .5  # Give some time for nvim to close
     # tmux kill-pane -t "$P"
     # tmux set -wu @myspecialpane
else
     P=$(tmux splitw -PF'#{pane_id}' -- 'cd ~/git/notes/; nvim index.norg')
     tmux set -w @myspecialpane "$P"
fi
