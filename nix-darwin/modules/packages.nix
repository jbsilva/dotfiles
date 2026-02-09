{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    ack
    awscli2
    carapace
    coreutils
    curlFull
    discord
    exiftool
    file-rename
    findutils
    # firefox
    gawk
    # ghostty-bin
    git
    glow
    gnugrep
    gnupg
    gnused
    gnutar
    go
    hclfmt
    htop
    # hugo
    iina
    iperf
    jq
    loopwm
    mas
    neovim
    nil
    nixd
    nixfmt
    nodejs_24
    nodePackages.prettier
    notion-app
    # ollama
    p7zip
    raycast
    renameutils
    ripgrep
    rsync
    shottr
    slack
    swiftdefaultapps
    tree
    # tailscale
    terraform
    the-unarchiver
    vscode
    # warp-terminal
    wezterm
    wget
    # yt-dlp
    zellij
  ];
}
