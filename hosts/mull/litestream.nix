{ ... }:
{
  flake.modules.nixos.mull-litestream =
    {
      config,
      pkgs,
      ...
    }:
    let
      rcloneConf = config.sops.templates."rclone-r2.conf".path;
      backupScript = pkgs.writeShellScript "backup-navidrome-db" ''
        set -euo pipefail
        BUCKET="$(< ${config.sops.secrets.r2_bucket.path})"
        BACKUP_DIR="$(mktemp -d)"
        trap 'rm -rf "$BACKUP_DIR"' EXIT

        DB="/var/lib/navidrome/navidrome.db"
        if [ -f "$DB" ]; then
          echo "Backing up Navidrome database..."
          ${pkgs.sqlite}/bin/sqlite3 "$DB" ".backup '$BACKUP_DIR/navidrome.db'"
        else
          echo "Navidrome database not found at $DB" >&2
          exit 1
        fi

        echo "Uploading database backups to R2..."
        ${pkgs.rclone}/bin/rclone copy "$BACKUP_DIR" "r2:$BUCKET/backups/db" \
          --config "${rcloneConf}"
        echo "Backup complete."
      '';
    in
    {
      systemd.services.navidrome-db-backup = {
        description = "Daily Navidrome SQLite Database Backup to Cloudflare R2";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];

        serviceConfig = {
          Type = "oneshot";
          ExecStart = backupScript;
        };
      };

      systemd.timers.navidrome-db-backup = {
        description = "Trigger nightly Navidrome SQLite backup";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "03:00";
          Persistent = true;
          RandomizedDelaySec = "15m";
        };
      };
    };
}
