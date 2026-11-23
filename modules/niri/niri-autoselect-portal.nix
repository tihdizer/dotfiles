{ inputs, ... }:
{
  flake-file.inputs = {
    niri-autoselect-portal = {
      url = "git+https://codeberg.org/debugloop/niri-autoselect-portal.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.nixos.niri-autoselect-portal =
    { ... }:
    {
      imports = [
        inputs.niri-autoselect-portal.nixosModules.default
      ];

      services.niri-autoselect-portal.enable = true;
    };
}
