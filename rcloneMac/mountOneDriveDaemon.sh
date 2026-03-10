#!/usr/bin/env bash

# === CONFIGURATION ===
REMOTE_NAME="marquetteDrive:"
MOUNT_POINT="$HOME/marquetteDrive"
CACHE_DIR="$HOME/.cache/rclone_marquette"
MAX_CACHE_SIZE="5G"
LOG_FILE="$HOME/.cache/rclone_marquette/mount.log"

# === CREATE DIRECTORIES IF NEEDED ===
mkdir -p "$MOUNT_POINT"
mkdir -p "$CACHE_DIR"

# === CHECK IF ALREADY MOUNTED ===
if mount | grep -q "$MOUNT_POINT"; then
    echo "Already mounted at $MOUNT_POINT"
    exit 0
fi

# === UNMOUNT IF THERE'S A STALE MOUNT ===
if pgrep -f "rclone mount.*$MOUNT_POINT" > /dev/null; then
    echo "Killing existing rclone process..."
    pkill -f "rclone mount.*$MOUNT_POINT"
    sleep 2
fi

if mount | grep -q "$MOUNT_POINT"; then
    echo "Unmounting stale mount..."
    umount "$MOUNT_POINT" 2>/dev/null || diskutil unmount force "$MOUNT_POINT" 2>/dev/null
    sleep 1
fi

# === MOUNT IN BACKGROUND ===
echo "Mounting $REMOTE_NAME to $MOUNT_POINT in background..."
nohup rclone mount "$REMOTE_NAME" "$MOUNT_POINT" \
    --vfs-cache-mode full \
    --vfs-cache-max-size "$MAX_CACHE_SIZE" \
    --vfs-cache-max-age 1h \
    --cache-dir "$CACHE_DIR" \
    --dir-cache-time 1m \
    --poll-interval 30s \
    --buffer-size 64M \
    --transfers 16 \
    --multi-thread-streams 8 \
    --umask 022 \
    --log-file "$LOG_FILE" \
    --log-level INFO \
    > /dev/null 2>&1 &

# Wait a moment and check if mount succeeded
sleep 3
if mount | grep -q "$MOUNT_POINT"; then
    echo "✓ Successfully mounted $REMOTE_NAME at $MOUNT_POINT"
    echo "  Check logs at: $LOG_FILE"
else
    echo "✗ Mount may have failed. Check logs at: $LOG_FILE"
    exit 1
fi
