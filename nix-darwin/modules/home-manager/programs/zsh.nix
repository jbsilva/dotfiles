{ ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initContent = builtins.readFile ../../../../.zshrc;
  };
}
