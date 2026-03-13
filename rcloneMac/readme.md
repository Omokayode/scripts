# First test in foreground to see any errors
./mount_onedrive_mac.sh

# If it works, unmount and try daemon version
./unmount_onedrive.sh
./mount_onedrive_daemon.sh


# Copy the plist to LaunchAgents
cp com.rclone.marquetteDrive.plist ~/Library/LaunchAgents/

# Load it
launchctl load ~/Library/LaunchAgents/com.rclone.marquetteDrive.plist

# To unload later:
# launchctl unload ~/Library/LaunchAgents/com.rclone.marquetteDrive.plist

# load and unload is deprecated

launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.rclone.marquetteDrive.plist

launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.rclone.marquetteDrive.plist
