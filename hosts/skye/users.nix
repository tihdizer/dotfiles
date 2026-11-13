{ ... }:
{
  flake.modules.nixos.skye-users =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      users.mutableUsers = lib.mkDefault true;

      sops.secrets = {
        "tihdizer" = {
          sopsFile = ../../secrets/skye.yaml;
          neededForUsers = true;
        };
        "root" = {
          sopsFile = ../../secrets/skye.yaml;
          neededForUsers = true;
        };
      };

      users.users.tihdizer = {
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets."tihdizer".path;
        shell = pkgs.zsh;
        description = "TihDizer";
        extraGroups = [
          # TODO: move in modules
          "wheel"
          "systemd-journal"
          "libvirtd"
          "kvm"
          "plugdev"
          "docker"
          "networkmanager"
          "audio"
          "video"
          "input"
        ];
      };

      users.users.root = {
        hashedPasswordFile = config.sops.secrets."root".path;
      };
    };
}
