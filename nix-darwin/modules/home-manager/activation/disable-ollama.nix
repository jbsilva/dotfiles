{ ... }:
{
  home.activation.disableOllama = ''
    echo "Disabling Ollama auto-start..."

    OLLAMA_LABEL="com.ollama.ollama"

    # Boot out and disable the Ollama agent.
    launchctl bootout "gui/$UID/$OLLAMA_LABEL" 2>/dev/null || true
    launchctl disable "gui/$UID/$OLLAMA_LABEL" 2>/dev/null || true

    # Remove any user-level copy of the Ollama plist.
    rm -f "$HOME/Library/LaunchAgents/$OLLAMA_LABEL.plist"

    # Clean up the counter-agent if left over from a previous config.
    rm -f "$HOME/Library/LaunchAgents/local.disable-ollama.plist"
    launchctl bootout "gui/$UID/local.disable-ollama" 2>/dev/null || true

    # Remove legacy login item entries.
    /usr/bin/osascript - <<'EOF' 2>/dev/null || true
    tell application "System Events"
      repeat while (exists login item "Ollama")
        delete login item "Ollama"
      end repeat
    end tell
    EOF

    # Kill Ollama processes.
    pkill -if 'Ollama' 2>/dev/null || true
    pkill -f 'ollama serve' 2>/dev/null || true

    echo "Ollama auto-start disabled (manual launch still works)"
  '';
}
