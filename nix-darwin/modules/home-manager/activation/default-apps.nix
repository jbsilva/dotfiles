{ pkgs, ... }:
{
  ###########################################################################
  # Default applications, via SwiftDefaultApps
  #
  # Two things about `swda` shape this script:
  #
  #   1. It ALWAYS exits 0, even when it prints
  #      "SwiftDefaultApps ERROR -10810: An unknown error has occurred."
  #      So success has to be detected by grepping its output. The previous
  #      version tested the exit status, which meant its retry loop never
  #      actually retried and every failure was silently swallowed by `|| true`.
  #
  #   2. -10810 (kLSUnknownErr) is what it reports for a UTI LaunchServices
  #      does not know. Retrying that forever is pointless, so UTIs are
  #      validated against `swda getUTIs` first and unknown ones are reported
  #      as such instead of burning three sleeps on a cryptic error.
  #
  # Output is quiet on success -- ~100 SUCCESS lines buried the five real
  # failures. Only problems and a one-line summary are printed.
  ###########################################################################
  home.activation.setDefaultApps = ''
    SWDA_CMD="${pkgs.swiftdefaultapps}/bin/swda"

    if [ ! -x "$SWDA_CMD" ]; then
      echo "SwiftDefaultApps (swda: $SWDA_CMD) not found"
    else
      echo "Setting default applications using SwiftDefaultApps..."

      # LaunchServices can be mid-rebuild right after Homebrew cask
      # installs/upgrades or login item changes earlier in activation, which
      # causes transient -10810. Let it settle.
      sleep 3

      swdaKnownUTIs="$(mktemp -t swda-utis)"
      "$SWDA_CMD" getUTIs 2>/dev/null | cut -f1 | sort -u > "$swdaKnownUTIs"

      swdaOK=0
      swdaSkipped=0
      swdaFailed=0
      swdaProblems=""

      # setHandler, retried on transient failures. Success is detected in the
      # output because swda's exit status is meaningless.
      swda_try() {
        local label="$1"
        shift
        local out delay
        for delay in 0 1 2 4; do
          [ "$delay" != 0 ] && sleep "$delay"
          out="$("$SWDA_CMD" "$@" 2>&1)"
          case "$out" in
            *SUCCESS*)
              swdaOK=$((swdaOK + 1))
              return 0
              ;;
          esac
        done
        swdaFailed=$((swdaFailed + 1))
        swdaProblems="$swdaProblems
      $label: $out"
        return 0
      }

      # Skip UTIs LaunchServices has never heard of, rather than retrying them.
      swda_uti() {
        local app="$1" uti="$2"
        if ! grep -qx -- "$uti" "$swdaKnownUTIs"; then
          swdaSkipped=$((swdaSkipped + 1))
          swdaProblems="$swdaProblems
      $uti: unknown to LaunchServices (no app declares it) -- skipped"
          return 0
        fi
        swda_try "$app <- $uti" setHandler --app "$app" --UTI "$uti"
      }

      ###################################################################
      # Video and audio (IINA)
      ###################################################################
      for uti in \
        com.apple.avurlasset-content \
        com.apple.m4v-video \
        com.apple.mediaextension-content \
        com.apple.protected-mpeg-4-video \
        com.apple.quicktime-audio \
        com.apple.quicktime-movie \
        com.apple.tv.database \
        com.apple.tv.ite \
        com.apple.tv.library \
        com.apple.tv.movpkg \
        com.audible.aa-audio \
        com.digidesign.sd2-audio \
        com.microsoft.waveform-audio \
        com.microsoft.windows-media-wm \
        com.microsoft.windows-media-wma \
        com.microsoft.windows-media-wmv \
        io.iina.mkv \
        io.iina.webm \
        org.3gpp.adaptive-multi-rate-audio \
        org.webmproject.webm \
        public.3gpp \
        public.3gpp2 \
        public.aiff-audio \
        public.au-audio \
        public.audio \
        public.audiovisual-content \
        public.avi \
        public.dv-movie \
        public.enhanced-ac3-audio \
        public.movie \
        public.mp3 \
        public.mpeg \
        public.mpeg-2-transport-stream \
        public.mpeg-2-video \
        public.mpeg-4 \
        public.mpeg-4-audio \
        public.ulaw-audio \
        public.video; do
        swda_uti "IINA" "$uti"
      done

      ###################################################################
      # Images (Preview)
      ###################################################################
      for uti in \
        com.apple.icns \
        com.canon.tif-raw-image \
        com.compuserve.gif \
        com.microsoft.bmp \
        com.microsoft.ico \
        com.microsoft.ppt.export.ext.jpg \
        com.microsoft.ppt.export.ext.png \
        com.microsoft.ppt.export.ext.tiff \
        org.webmproject.webp \
        public.camera-raw-image \
        public.heic \
        public.heif \
        public.image \
        public.jpeg \
        public.png \
        public.tiff; do
        swda_uti "Preview" "$uti"
      done

      ###################################################################
      # Browser (Vivaldi)
      ###################################################################
      swda_uti "Vivaldi" public.svg-image
      swda_uti "Vivaldi" com.microsoft.internet-shortcut
      swda_try "Vivaldi <- http" setHandler --app "Vivaldi" --URL http
      swda_try "Vivaldi <- internet" setHandler --app "Vivaldi" --internet

      ###################################################################
      # Text and code (VS Code)
      ###################################################################
      for uti in \
        com.apple.ascii-property-list \
        com.apple.finalcutpro.xml \
        com.apple.property-list \
        com.apple.rtfd \
        com.apple.xml-property-list \
        com.sun.java-source \
        net.daringfireball.markdown \
        org.khronos.collada.digital-asset-exchange \
        public.assembly-source \
        public.bash-script \
        public.c-plus-plus-source \
        public.c-source \
        public.delimited-values-text \
        public.fortran-source \
        public.geojson \
        public.json \
        public.make-source \
        public.ndjson \
        public.objective-c-source \
        public.patch-file \
        public.perl-script \
        public.plain-text \
        public.python-script \
        public.rtf \
        public.ruby-script \
        public.script \
        public.shell-script \
        public.source-code \
        public.swift-source \
        public.utf8-plain-text \
        public.xml \
        public.yaml \
        public.zsh-script; do
        swda_uti "/Applications/Visual Studio Code.app" "$uti"
      done

      ###################################################################
      # Archives (The Unarchiver)
      ###################################################################
      for uti in \
        com.microsoft.cab \
        com.microsoft.msi-installer \
        org.gnu.gnu-zip-archive \
        public.tar-archive \
        public.zip-archive; do
        swda_uti "The Unarchiver" "$uti"
      done

      ###################################################################
      # Office documents and PDF
      ###################################################################
      swda_uti "Microsoft Excel" com.microsoft.excel.xls
      swda_uti "Microsoft Excel" org.openxmlformats.spreadsheetml.sheet
      swda_uti "Microsoft Word" com.microsoft.word.doc
      swda_uti "Microsoft Word" org.openxmlformats.wordprocessingml.document
      swda_uti "Adobe Acrobat" com.adobe.pdf

      rm -f "$swdaKnownUTIs"

      if [ -n "$swdaProblems" ]; then
        echo "Default apps: $swdaOK set, $swdaSkipped skipped, $swdaFailed failed.$swdaProblems"
      else
        echo "Default apps: $swdaOK set, all OK."
      fi

      sleep 3
    fi
  '';
}
