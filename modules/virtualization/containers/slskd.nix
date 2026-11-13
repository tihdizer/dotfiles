{ ... }:
{
  flake.modules.nixos.slskd =
    { config, ... }:
    {
      sops.secrets.user = {
        sopsFile = ../../../secrets/mull.yaml;
      };

      sops.secrets.password = {
        sopsFile = ../../../secrets/mull.yaml;
      };

      sops.templates."slskd.env" = {
        content = ''
          SLSKD_SLSK_USERNAME=${config.sops.placeholder.user}
          SLSKD_SLSK_PASSWORD=${config.sops.placeholder.password}
          SLSKD_USERNAME=${config.sops.placeholder.user}
          SLSKD_PASSWORD=${config.sops.placeholder.password}
        '';
      };

      virtualisation.podman = {
        enable = true;
        defaultNetwork.settings.dns_enabled = true;
      };

      systemd.tmpfiles.rules = [
        "d /var/lib/containers/slskd 0750 tihdizer users -"
        "d /var/media/inbox 0750 tihdizer users -"
      ];

      virtualisation.oci-containers = {
        backend = "podman";

        containers.slskd = {
          image = "docker.io/slskd/slskd:latest";
          autoStart = true;

          environment = {
            SLSKD_REMOTE_CONFIGURATION = "true";
            SLSKD_DOWNLOADS_DIR = "/downloads";
            SLSKD_SLSK_LISTEN_PORT = "50300";
          };

          environmentFiles = [
            config.sops.templates."slskd.env".path
          ];

          volumes = [
            "/var/lib/containers/slskd:/app:Z"
            "/var/media/inbox:/downloads:Z"
          ];

          ports = [
            "127.0.0.1:5030:5030"
            "127.0.0.1:50300:50300"
          ];

          extraOptions = [
            "--name=slskd"
            "--hostname=slskd"
            "--user=1000:1000"
            "--cpus=0.5"
            "--memory=512m"
            "--memory-swap=768m"
          ];
        };
      };

      systemd.services.podman-slskd = {
        after = [ "systemd-tmpfiles-setup.service" ];
        requires = [ "systemd-tmpfiles-setup.service" ];
      };
    };
}
