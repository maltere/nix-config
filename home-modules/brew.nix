{ ... }:

{
  programs.homebrew = {
    enable = true;

    onActivation = {
      cleanup = "zap";
    };

    # A list of common packages to be installed via Homebrew
    brews = [
      "swagger-cli"
      "cloudflared"
      "ollama"
      "kubie"
      "kubernetes-cli"
      "grepcidr"
      "clickhouse-cli"
      "lua"
      "repomix"
      "protobuf"
    ];
  };
}

