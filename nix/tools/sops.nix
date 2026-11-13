{ inputs, ... }:
{
  flake-file.inputs = {
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.nixos.sops =
    { lib, ... }:
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      sops = {
        defaultSopsFile = lib.mkDefault ../../secrets/tihdizer.yaml;
        validateSopsFiles = false;

        age.keyFile = lib.mkDefault "/persistent/var/lib/sops-nix/key.txt";
      };
    };

  flake.modules.homeManager.sops =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        sops
        age
      ];
    };
}
