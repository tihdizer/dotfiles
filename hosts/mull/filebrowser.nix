{ ... }:
{
  flake.modules.nixos.mull-filebrowser =
    { config, ... }:
    let
      mediaFolder = "/var/media";
      configDir = "/var/lib/filebrowser";
    in
    {
      sops.secrets.password = {
        sopsFile = ../../secrets/mull.yaml;
      };

      sops.templates."filebrowser.env" = {
        content = ''
          FB_DEFAULT_PASSWORD=${config.sops.placeholder.password}
        '';
      };

      virtualisation.podman = {
        enable = true;
        defaultNetwork.settings.dns_enabled = true;
      };

      systemd.tmpfiles.rules = [
        "d ${configDir} 0750 tihdizer users -"
        "d ${mediaFolder} 0750 tihdizer users -"
      ];

      virtualisation.oci-containers = {
        backend = "podman";

        containers.filebrowser = {
          image = "docker.io/filebrowser/filebrowser:v2.31.0";
          autoStart = true;

          environment = {
            FB_AUTH_METHOD = "json";
            FB_USERNAME = "tihdizer";
            FB_PORT = "8080";
            FB_DATABASE = "/database/filebrowser.db";
          };

          environmentFiles = [
            config.sops.templates."filebrowser.env".path
          ];

          volumes = [
            "${configDir}:/database:Z"
            "${mediaFolder}:/srv:Z"
          ];

          ports = [
            "8079:8080"
          ];

          extraOptions = [
            "--name=filebrowser"
            "--hostname=filebrowser"
            "--user=1000:1000"
            "--cpus=0.3"
            "--memory=256m"
            "--memory-swap=512m"
          ];
        };
      };

      systemd.services.podman-filebrowser = {
        after = [ "systemd-tmpfiles-setup.service" ];
        requires = [ "systemd-tmpfiles-setup.service" ];
      };
    };
}
