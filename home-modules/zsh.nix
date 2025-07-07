{
  config,
  pkgs,
  flake-inputs,
  thisFlakePath,
  ...
}:
{
  programs.zsh = {
    enable = true;
    package = pkgs.zsh;

    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 100000000;
      save = 100000000;
      ignoreSpace = true;
      ignorePatterns = [
        "ls *"
        "pwd *"
        "exit *"
      ];
      extended = true;
    };

    oh-my-zsh = {
      enable  = true;
      theme   = "edvardm-mr";
      plugins = [
        "git"
        "maltere"
      ];
      custom  = "${thisFlakePath}/dotfiles/zsh/omz";
    };

    shellAliases = {
      edit = "sudo -e";
      update = "sudo nixos-rebuild switch";
      k = "kubectl";

      # let's try this out :) -- works great!
      cat = "bat";
    };
  };

  # make sure these are enabled, without forcing a specific package
  # (so the specific package can be set somewhere else).
  programs.eza.enable = true;
  programs.bat.enable = true;
}
