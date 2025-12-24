#!/bin/bash

# Kill existing session if running
tmux kill-session -t airplay 2>/dev/null

# Start new session with UxPlay
tmux new-session -d -s airplay 'uxplay -n "My AirPlay"'

echo "UxPlay started in tmux session 'airplay'"
echo "To view: tmux attach -s airplay"
echo "To detach: Ctrl+b then d"

#check session
#tmux ls
#kill session
#tmux kill-session -t airplay
