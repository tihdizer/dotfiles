{ ... }:
{
  flake.modules.nixos.mull-system =
    { ... }:
    {
      nix = {
        channel.enable = false;
        settings = {
          trusted-users = [
            "root"
            "@wheel"
          ];
          cores = 2;
          max-jobs = 1;
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

      boot.loader.grub = {
        enable = true;
        efiSupport = false;
      };

      boot.loader.efi.canTouchEfiVariables = true;

      nixpkgs.config.allowUnfree = true;
      system.stateVersion = "26.05";
    };
}
