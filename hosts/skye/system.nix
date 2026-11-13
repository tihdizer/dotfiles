{ ... }:
{
  flake.modules.nixos.skye-system =
    { ... }:
    {
      nix = {
        channel.enable = false;
        settings = {
          trusted-users = [
            "root"
            "@wheel"
          ];
          cores = 4;
          max-jobs = 2;
          substituters = [ "https://cache.nixos.org/" ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          ];
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          auto-optimise-store = true;
          keep-derivations = false;
          keep-outputs = true;
        };

        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 7d";
        };
      };

      services.gvfs.enable = true;

      security.sudo.extraConfig = ''
        Defaults lecture = never
      '';

      nixpkgs.config.allowUnfree = true;
      system.stateVersion = "25.11";
    };
}
