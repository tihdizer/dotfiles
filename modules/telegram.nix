{ inputs, ... }:
{
  flake-file.inputs = {
    tele = {
      url = "github:sorokin-vladimir/tele";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  flake.modules.nixos.telegram =
    { pkgs, lib, ... }:
    {
      environment.systemPackages =
        (lib.optional (inputs ? tele) inputs.tele.packages.${pkgs.system}.default)
        ++ [ pkgs.telegram-desktop ];
    };

  flake.modules.homeManager.telegram =
    { pkgs, ... }:
    {
      # TODO: add HM pkg for tele
      home.packages = [
        pkgs.telegram-desktop
      ];
    };
}
