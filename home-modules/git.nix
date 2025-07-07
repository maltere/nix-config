{ options, config, lib, pkgs, ... }:
{
  options.programs.git.signingKeyPub = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    description = "Path to the public SSH key used for signing commits.";
  };

  config.programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    userName = "Malte Reddig";

    aliases = {
      lola = "log --graph --pretty='format:%C(auto)%h %d %s %C(green)(%ad) %C(bold blue)<%an>' --abbrev-commit --all --date=relative";
    };

    delta = {
      enable = true;

      options = {
        hyperlinks = true;
         # use n and N to move between diff sections
        navigate = true;
      };
    };

    extraConfig = {
      branch = {
        sort = "-committerdate";
      };
      commit = {
        gpgsign = config.programs.git.signingKeyPub != null;
        verbose = true;
      };
      core = {
        autocrlf = false;
        editor = "vim";
        eol = "lf";
        fsmonitor = true;
      };
      fetch = {
        prune = "true";
        pruneTags = "true";
      };
      init = {
        defaultBranch = "main";
      };
      merge = {
        # conflictstyle = "zdiff3";
        conflictstyle = "merge";
      };
      pull = {
        ff = "only";
        prune = "true";
      };
      push = {
        autoSetupRemote = true;
        followTags = true;
      };
      rebase = {
        autoStash = "true";
      };
      user = {
        signingKey = config.programs.git.signingKeyPub;
      };
      fpf = {
        format = "ssh";
      };

      rerere.enable = true;
    };

    lfs.enable = true;
  };

  config.programs.git.ignores = [
    # General-purpose, low-false positive items.
    # https://git-scm.com/docs/gitignore#_pattern_format
    ".DS_Store"
    "playground/" # In-repo temporary experiments
  ];
}
