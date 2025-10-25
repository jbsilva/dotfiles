{ ... }:
{
  home.activation.dockerPlugins = ''
    echo "Setting up Docker CLI plugins..."

    # Create plugins directory
    mkdir -p ~/.docker/cli-plugins

    # Create symlinks (runs after Homebrew is available)
    if [ -f /opt/homebrew/bin/docker-compose ]; then
      ln -sfn /opt/homebrew/bin/docker-compose ~/.docker/cli-plugins/docker-compose
      echo "Linked docker-compose plugin"
    fi

    if [ -f /opt/homebrew/bin/docker-buildx ]; then
      ln -sfn /opt/homebrew/bin/docker-buildx ~/.docker/cli-plugins/docker-buildx
      echo "Linked docker-buildx plugin"
    fi

    # Install Docker Buildx
    if command -v docker >/dev/null 2>&1; then
      /opt/homebrew/bin/docker buildx install 2>/dev/null || true
      echo "Docker buildx installed"
    fi

    echo "Docker CLI plugins setup complete"
  '';
}
