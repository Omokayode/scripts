#!/usr/bin/env bash

# === CONFIGURATION ===
REMOTE_NAME="marquettedrive:"
MOUNT_POINT="$HOME/marquettedrive"
TMUX_SESSION="rclone_marquette"
CACHE_DIR="$HOME/.cache/rclone_marquette"
MAX_CACHE_SIZE="30G"

# === CREATE MOUNT DIRECTORY IF NEEDED ===
mkdir -p "$MOUNT_POINT"
mkdir -p "$CACHE_DIR"

# === CHECK IF ALREADY MOUNTED ===
if mount | grep -q "$MOUNT_POINT"; then
    echo "Already mounted at $MOUNT_POINT"
    exit 0
fi

# === START TMUX SESSION IF NOT EXISTS ===
if ! tmux has-session -t $TMUX_SESSION 2>/dev/null; then
    tmux new-session -d -s $TMUX_SESSION
fi

# === RUN RCLONE MOUNT INSIDE TMUX SESSION ===
tmux send-keys -t $TMUX_SESSION "
rclone mount $REMOTE_NAME $MOUNT_POINT \
    --vfs-cache-mode full \
    --vfs-cache-max-size $MAX_CACHE_SIZE \
    --vfs-cache-max-age 24h \
    --cache-dir $CACHE_DIR \
    --dir-cache-time 72h \
    --poll-interval 30s \
    --buffer-size 64M \
    --transfers 16 \
    --multi-thread-streams 8 \
    --umask 022
#    --allow-other \
#    --daemon
" C-m

echo "Mounted $REMOTE_NAME inside tmux session '$TMUX_SESSION'"

