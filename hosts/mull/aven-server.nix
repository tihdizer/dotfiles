{ inputs, ... }:
let
  getPackage = pkgs: inputs.aven.packages.${pkgs.stdenv.hostPlatform.system}.default;
  publicUrl = "https://aven.tihdizer.online";
  port = 3746;
in
{
  flake.modules.nixos.mull-aven-server =
    { pkgs, ... }:
    let
      aven = getPackage pkgs;
      setupScript = pkgs.writeShellScript "aven-server-setup" ''
        set -euo pipefail
        DB="/var/lib/aven/sync-server.sqlite"
        INVITE="/var/lib/aven/setup-invitation.txt"

        if [ ! -f "$DB" ]; then
          echo "Initializing Aven server storage..."
          ${aven}/bin/aven server setup \
            --url "${publicUrl}" \
            --data "$DB" \
            --invitation-only > "$INVITE" 2>&1 || true
          chmod 600 "$INVITE" || true
        fi
      '';
    in
    {
      systemd.services.aven-server = {
        description = "Aven encrypted sync server";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "simple";
          User = "aven";
          Group = "aven";
          DynamicUser = true;
          StateDirectory = "aven";
          StateDirectoryMode = "0700";

          ExecStartPre = setupScript;
          ExecStart = "${aven}/bin/aven server --bind 127.0.0.1:${toString port} --data /var/lib/aven/sync-server.sqlite";

          Restart = "on-failure";
          RestartSec = 5;

          # Hardening
          NoNewPrivileges = true;
          ProtectSystem = "strict";
          ProtectHome = true;
          PrivateTmp = true;
          PrivateDevices = true;
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectControlGroups = true;
          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
            "AF_UNIX"
          ];
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          LockPersonality = true;
        };
      };

      services.caddy.virtualHosts."aven.tihdizer.online".extraConfig = ''
        reverse_proxy 127.0.0.1:${toString port}
      '';
    };
}
