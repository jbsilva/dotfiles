{ ... }:
{
  home.activation.disableAdobeCreativeCloud = ''
    echo "Disabling Adobe Creative Cloud (user session scope)..."
    ADOBE_USER_LABELS="com.adobe.AdobeCreativeCloud com.adobe.CCXProcess com.adobe.AdobeIPCBroker"
    for label in $ADOBE_USER_LABELS; do
      launchctl disable "gui/$UID/$label" 2>/dev/null || true
      launchctl bootout "gui/$UID/$label" 2>/dev/null || true
    done

    pkill -if 'AdobeCreativeCloud' 2>/dev/null || true
    pkill -if 'CCXProcess' 2>/dev/null || true
    pkill -if 'AdobeIPCBroker' 2>/dev/null || true
    pkill -if 'ResourceSynchronizer' 2>/dev/null || true
    pkill -if 'CRDaemon' 2>/dev/null || true
    echo "(User Adobe labels processed; system-level handled in root activation script)"
  '';
}
