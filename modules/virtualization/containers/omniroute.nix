{ ... }:
{
  flake.modules.homeManager.omniroute =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      containerName = "omniroute";
      image = "docker.io/diegosouzapw/omniroute:latest";
      dataDir = "${config.home.homeDirectory}/.local/share/omniroute";
      hostPort = 8000;
      containerPort = 20128;
    in
    {
      home.packages = [ pkgs.podman ];

      programs.ssh = {
        enable = true;

        settings.omniroute = {
          hostname = "localhost";
          user = config.home.username;
          requestTTY = "force";
          remoteCommand = "${pkgs.podman}/bin/podman exec -it ${containerName} bash";
        };
      };

      systemd.user.services.omniroute = {
        Unit = {
          Description = "OmniRoute AI Gateway (Podman Container)";
          After = [ "network.target" ];
        };

        Service = {
          ExecStartPre = [
            "${pkgs.coreutils}/bin/mkdir -p ${dataDir}"
            "-${pkgs.podman}/bin/podman rm -f ${containerName}"
            "${pkgs.podman}/bin/podman pull ${image}"
          ];

          ExecStart = lib.concatStringsSep " \\\n  " [
            "${pkgs.podman}/bin/podman run --rm"
            "--name ${containerName}"
            "--memory=1.5g"
            "--memory-swap=2g"
            "-p ${toString hostPort}:${toString containerPort}"
            "-v ${dataDir}:/app/data:U"
            "-e PORT=${toString containerPort}"
            "-e MALLOC_ARENA_MAX=2"
            "-e OMNIROUTE_PRESSURE_SELF_RESTART=true"
            "--stop-timeout=40"
            image
          ];

          ExecStop = "${pkgs.podman}/bin/podman stop --timeout 40 ${containerName}";

          Restart = "always";
          RestartSec = "5s";
        };

        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
}
