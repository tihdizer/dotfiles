{ ... }:
{
  flake.modules.nixos.mull-reverse-proxy =
    { ... }:
    {
      networking.firewall.allowedTCPPorts = [
        80
        443
      ];

      services.caddy = {
        enable = true;
        virtualHosts = {
          "music.tihdizer.online".extraConfig = ''
            reverse_proxy 127.0.0.1:4533
          '';
          "slskd.tihdizer.online".extraConfig = ''
            reverse_proxy 127.0.0.1:5030
          '';
          "file.tihdizer.online".extraConfig = ''
            reverse_proxy 127.0.0.1:8079
          '';
        };
      };
    };
}
