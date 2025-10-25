{ ... }:
{
  home.activation.disableOneDrive = ''
    echo "Disabling OneDrive background agents..."
    LABELS="com.microsoft.OneDrive com.microsoft.OneDriveUpdater com.microsoft.OneDriveStandaloneUpdater com.microsoft.OneDrive.FinderSync com.microsoft.OneDriveLauncher"
    for label in $LABELS; do
      launchctl disable "gui/$UID/$label" 2>/dev/null || true
      launchctl bootout "gui/$UID/$label" 2>/dev/null || true
      launchctl bootout "system/$label" 2>/dev/null || true
      rm -f "$HOME/Library/LaunchAgents/$label.plist" 2>/dev/null || true
    done

    OD_PLIST="$HOME/Library/Containers/com.microsoft.OneDrive-mac/Data/Library/Preferences/com.microsoft.OneDrive-mac.plist"
    if [ -f "$OD_PLIST" ]; then
      /usr/bin/defaults delete "$OD_PLIST" OpenAtLogin 2>/dev/null || true
    fi

    /usr/bin/osascript - <<'EOF' 2>/dev/null || true
    tell application "System Events"
      repeat while (exists login item "OneDrive")
        delete login item "OneDrive"
      end repeat
      repeat while (exists login item "Microsoft OneDrive")
        delete login item "Microsoft OneDrive"
      end repeat
      repeat while (exists login item "OneDrive Launcher")
        delete login item "OneDrive Launcher"
      end repeat
    end tell
    EOF

    for domain in com.microsoft.OneDrive com.microsoft.OneDrive-mac; do
      /usr/bin/defaults write "$domain" OpenAtLogin -bool false 2>/dev/null || true
      /usr/bin/defaults write "$domain" DisableAutoStart -bool true 2>/dev/null || true
      /usr/bin/defaults write "$domain" AutoStart -bool false 2>/dev/null || true
    done

    pkill -if 'OneDriveStandaloneUpdater' 2>/dev/null || true
    pkill -if 'OneDriveUpdater' 2>/dev/null || true
    pkill -if 'OneDrive' 2>/dev/null || true
    pkill -if 'SyncReporter' 2>/dev/null || true
    echo "OneDrive agents disabled (they can still be launched manually)"
  '';
}
