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
    notion-app
    # ollama
    p7zip
    prettier
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
    terragrunt
    tflint
    the-unarchiver
    # vscode
    # warp-terminal
    wezterm
    wget
    # yt-dlp
    zellij
  ];
}
