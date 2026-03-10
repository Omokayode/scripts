#!/usr/bin/env bash

# === CONFIGURATION ===
REMOTE_NAME="marquetteDrive:"
MOUNT_POINT="$HOME/marquetteDrive"
CACHE_DIR="$HOME/.cache/rclone_marquette"
MAX_CACHE_SIZE="1G"
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
if [ -d "$MOUNT_POINT" ] && [ "$(ls -A $MOUNT_POINT 2>/dev/null)" ]; then
    echo "Cleaning up potential stale mount..."
    umount "$MOUNT_POINT" 2>/dev/null || true
    # On macOS, use diskutil if umount fails
    diskutil unmount force "$MOUNT_POINT" 2>/dev/null || true
fi

# === MOUNT IN FOREGROUND (for testing) ===
# Remove the --daemon flag to run in foreground initially
echo "Mounting $REMOTE_NAME to $MOUNT_POINT..."
rclone mount "$REMOTE_NAME" "$MOUNT_POINT" \
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
    --log-level INFO

# Note: On macOS, --allow-other requires FUSE permissions
# and may need: brew install macfuse
