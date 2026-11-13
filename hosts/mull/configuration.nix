{ inputs, ... }:
{
  flake.modules.nixos.mull =
    { pkgs, ... }:
    {
      imports = with inputs.self.modules.nixos; [
        mull-disko
        mull-hardware
        mull-locales
        mull-system
        mull-users
        mull-reverse-proxy
        mull-litestream
        mull-r2-mount
        mull-beets
        mull-filebrowser
        mull-aven-server

        sops
        navidrome
        slskd
        ssh
        yazi
      ];

      sops.age.keyFile = null;
      sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

      environment.systemPackages = with pkgs; [
        bottom
      ];

      networking.hostName = "mull";

      zramSwap = {
        enable = true;
        memoryPercent = 50;
      };

      system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
    };
}
