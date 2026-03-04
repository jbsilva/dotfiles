{ pkgs, ... }:
let
  tflintPlugins = [
    pkgs.tflint-plugins.tflint-ruleset-aws
  ];
in
{
  home.activation.tflintPlugins = ''
    echo "Setting up TFLint plugins..."

    PLUGIN_DIR="$HOME/.tflint.d/plugins"
    mkdir -p "$PLUGIN_DIR"

    ${builtins.concatStringsSep "\n" (
      map (plugin: ''
        # Symlink plugin contents into the tflint plugin directory
        for src in "${plugin}"/github.com/*/*; do
          org="$(basename "$(dirname "$src")")"
          repo="$(basename "$src")"
          for ver in "$src"/*; do
            version="$(basename "$ver")"
            dest="$PLUGIN_DIR/github.com/$org/$repo/$version"
            mkdir -p "$dest"
            for bin in "$ver"/*; do
              ln -sfn "$bin" "$dest/$(basename "$bin")"
              echo "Linked $org/$repo/$version/$(basename "$bin")"
            done
          done
        done
      '') tflintPlugins
    )}

    echo "TFLint plugins setup complete"
  '';
}
