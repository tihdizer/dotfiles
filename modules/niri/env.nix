{ ... }:
{
  flake.modules.nixos.niri-env =
    { ... }:
    {
      environment.pathsToLink = [
        "/share/applications"
        "/share/xdg-desktop-portal"
      ];
    };
}
