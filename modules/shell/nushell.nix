{ ... }:
{
  flake.modules.nixos.nushell =
    { ... }:
    {
      programs.nushell = {
        enable = true;
      };
    };

  flake.modules.homeManager.nushell =
    { ... }:
    {
      programs.nushell = {
        enable = true;
        loadSessionVariables = true;
      };
    };
}
