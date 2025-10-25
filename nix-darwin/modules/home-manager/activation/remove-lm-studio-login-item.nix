{ ... }:
{
  home.activation.removeLMStudioLoginItem = ''
    echo "Removing LM Studio login items..."
    /usr/bin/osascript - <<'EOF' 2>/dev/null || true
    tell application "System Events"
      repeat while (exists login item "LM Studio")
        delete login item "LM Studio"
      end repeat
      repeat while (exists login item "LM Studio Helper")
        delete login item "LM Studio Helper"
      end repeat
    end tell
    EOF
  '';
}
