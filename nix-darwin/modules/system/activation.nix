{ ... }:
{
  system.activationScripts.extraActivation.text = ''
    echo "Setting up OpenJDK symlink..."

    # Create the required symlink for system Java detection
    if [ -d "/opt/homebrew/opt/openjdk/libexec/openjdk.jdk" ]; then
      # Ensure the target directory exists
      mkdir -p /Library/Java/JavaVirtualMachines
      # Create the symlink (force overwrite if it exists)
      ln -sfn /opt/homebrew/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
      echo "OpenJDK symlink created successfully"
    else
      echo "OpenJDK not found at expected location - ensure 'brew install openjdk' has completed"
    fi

    echo "Disabling system-level Adobe Creative Cloud agents/daemons..."
    ADOBE_SYSTEM_LABELS="com.adobe.GC.AGM com.adobe.GC.Invoker-1.0 com.adobe.AdobeCreativeCloud com.adobe.acc.installer.v2 com.adobe.acc.installer.helper com.adobe.AdobeIPCBroker com.adobe.CCXProcess com.adobe.AdobeCRDaemon com.adobe.AdobeResourceSynchronizer com.adobe.ARMDC.Communicator com.adobe.ARMDC.SMJobBlessHelper"
    for label in $ADOBE_SYSTEM_LABELS; do
      launchctl bootout "system/$label" 2>/dev/null || true
      launchctl disable "system/$label" 2>/dev/null || true

      # Remove plist if present (non-declarative vendor installed)
      rm -f "/Library/LaunchAgents/$label.plist" 2>/dev/null || true
      rm -f "/Library/LaunchDaemons/$label.plist" 2>/dev/null || true
    done

    # Remove blessed helper tool if present
    rm -f /Library/PrivilegedHelperTools/com.adobe.ARMDC.SMJobBlessHelper 2>/dev/null || true

    # Remove any other stray Adobe launchd plists
    find /Library/LaunchAgents /Library/LaunchDaemons -maxdepth 1 -type f -name 'com.adobe.*.plist' -exec rm -f {} + 2>/dev/null || true

    # Kill lingering Adobe processes (system context)
    pkill -if 'AdobeGC' 2>/dev/null || true
    pkill -if 'AdobeIPCBroker' 2>/dev/null || true
    pkill -if 'CCXProcess' 2>/dev/null || true
    pkill -if 'AGMService' 2>/dev/null || true
    echo "Adobe Creative Cloud system components processed."

    echo "Disabling system-level Microsoft OneDrive daemons..."
    ONEDRIVE_LAUNCHER_DIR="/Applications/OneDrive.app/Contents/Library/LoginItems"
    ONEDRIVE_LAUNCHER_APP="$ONEDRIVE_LAUNCHER_DIR/OneDriveLauncher.app"

    if [ -d "$ONEDRIVE_LAUNCHER_APP" ]; then
      echo "OneDriveLauncher.app still present after disabler attempt; applying fallback rename."
      if [ ! -d "$ONEDRIVE_LAUNCHER_APP.disabled" ]; then
        mv "$ONEDRIVE_LAUNCHER_APP" "$ONEDRIVE_LAUNCHER_APP.disabled" 2>/dev/null || echo "Warning: failed to rename OneDrive launcher (permissions?)"
      else
        echo "Fallback rename already in place."
      fi
    else
      echo "OneDrive launcher not present (already disabled or app missing)."
    fi

    # Optional re-enable path: create a marker file to restore on next activation.
    if [ -f "$ONEDRIVE_LAUNCHER_DIR/RESTORE_ONEDRIVE_LAUNCHER" ]; then
      if [ -d "$ONEDRIVE_LAUNCHER_APP.disabled" ] && [ ! -d "$ONEDRIVE_LAUNCHER_APP" ]; then
        echo "Restore marker detected; re-enabling OneDrive launcher.";
        mv "$ONEDRIVE_LAUNCHER_APP.disabled" "$ONEDRIVE_LAUNCHER_APP" 2>/dev/null || echo "Warning: failed to restore OneDrive launcher";
        rm -f "$ONEDRIVE_LAUNCHER_DIR/RESTORE_ONEDRIVE_LAUNCHER" || true
      fi
    fi

    echo "Microsoft OneDrive launcher helper processed (vendor disabler + fallback)."

    echo "Patching Ollama app-bundled LaunchAgent (RunAtLoad -> false)..."
    OLLAMA_APP_PLIST="/Applications/Ollama.app/Contents/Library/LaunchAgents/com.ollama.ollama.plist"
    if [ -f "$OLLAMA_APP_PLIST" ]; then
      /usr/libexec/PlistBuddy -c "Set :RunAtLoad false" "$OLLAMA_APP_PLIST" 2>/dev/null \
        && echo "Ollama app-bundled plist patched successfully." \
        || echo "Warning: could not patch Ollama plist (check App Management permissions)."
    else
      echo "Ollama app-bundled plist not found (app not installed?)."
    fi
  '';
}
