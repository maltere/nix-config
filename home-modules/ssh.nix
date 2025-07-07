{
  options,
  ...
}:
{
  programs.ssh = {
    enable = true;
    compression = true;

    includes = [
      # Place add. config files here. Allows for non-Nix managed, throw-away configs.
      "dynamic.d/*"
    ];

    matchBlocks = {
      "*.host.rddg.net" = {
        user = "maltere";
      };

      "ark.host.rddg.net" = {
        hostname = "10.10.100.1";
      };

      "router.ark.host.rddg.net" = {
        hostname = "10.10.100.254";
      };
    };
  };
}