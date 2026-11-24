{ inputs, ... }:
let
  getPackage =
    pkgs:
    if inputs ? psysonic then
      inputs.psysonic.packages.${pkgs.stdenv.hostPlatform.system}.default
    else
      null;
in
{
  flake-file.inputs = {
    psysonic = {
      url = "github:Psysonic/psysonic";
    };
  };

  flake.modules.nixos.psysonic =
    { pkgs, lib, ... }:
    {
      nix.settings = {
        substituters = [
          "https://cache.nixos.org/"
          "https://psysonic.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "psysonic.cachix.org-1:M9cQyQ7tgvUWOQ5Pyt8ozlMoPLtOZir6MfRuTH9/VYA="
        ];
      };

      environment.systemPackages = lib.optional (inputs ? psysonic) (getPackage pkgs);
    };

  flake.modules.homeManager.psysonic =
    { pkgs, lib, ... }:
    {
      nix.settings = {
        substituters = [
          "https://cache.nixos.org/"
          "https://psysonic.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "psysonic.cachix.org-1:M9cQyQ7tgvUWOQ5Pyt8ozlMoPLtOZir6MfRuTH9/VYA="
        ];
      };

      home.packages = lib.optional (inputs ? psysonic) (getPackage pkgs);
    };
}
