#!/usr/bin/env bash

MOUNT_POINT="$HOME/marquetteDrive"

echo "Unmounting $MOUNT_POINT..."

# Kill rclone process
if pgrep -f "rclone mount.*$MOUNT_POINT" > /dev/null; then
    echo "Stopping rclone process..."
    pkill -f "rclone mount.*$MOUNT_POINT"
    sleep 2
fi

# Unmount
if mount | grep -q "$MOUNT_POINT"; then
    echo "Unmounting filesystem..."
    umount "$MOUNT_POINT" 2>/dev/null || diskutil unmount force "$MOUNT_POINT"
fi

echo "✓ Unmounted"
