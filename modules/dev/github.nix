{ ... }:
{
  flake.modules.nixos.github =
    { config, ... }:
    {
      sops.secrets."github-token" = { };

      sops.templates."nix-github-token.conf" = {
        content = ''
          extra-access-tokens = github.com=${config.sops.placeholder."github-token"}
        '';
        mode = "0440";
        group = "users";
      };

      nix.extraOptions = ''
        !include ${config.sops.templates."nix-github-token.conf".path}
      '';
    };

  flake.modules.homeManager.github =
    { pkgs, ... }:
    {
      programs.gh = {
        enable = true;
      };
    };
}
