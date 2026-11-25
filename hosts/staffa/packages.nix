{ ... }:
{
  flake.modules.homeManager.staffa-packages =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        kitty.terminfo
      ];
    };
}
