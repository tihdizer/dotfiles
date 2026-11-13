{ ... }:
{
  flake.modules.nixos.mull-users =
    {
      pkgs,
      lib,
      ...
    }:
    let
      adminKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDaEXk5BESJlD71TOx9xfayzUhrvy4lc40JqQhY+Ict+ music-key"
      ];
    in
    {
      users.mutableUsers = lib.mkDefault false;

      users.users.tihdizer = {
        isNormalUser = true;
        shell = pkgs.bash;
        description = "TihDizer";
        openssh.authorizedKeys.keys = adminKeys;
        extraGroups = [
          "wheel"
          "systemd-journal"
        ];
      };

      security.sudo.wheelNeedsPassword = false;

      users.users.root = {
        openssh.authorizedKeys.keys = adminKeys;
      };
    };
}
