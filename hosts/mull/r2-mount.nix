{ ... }:
{
  flake.modules.nixos.mull-r2-mount =
    {
      config,
      pkgs,
      ...
    }:
    let
      rclonePkg = pkgs.rclone;
      mountScript = pkgs.writeShellScript "rclone-r2-mount" ''
        mkdir -p /var/media/music
        for attempt in $(seq 1 60); do
          if [ -r ${config.sops.secrets.r2_bucket.path} ] && [ -r ${
            config.sops.templates."rclone-r2.conf".path
          } ]; then
            break
          fi
          if [ "$attempt" -eq 60 ]; then
            echo "Timed out waiting for SOPS R2 credentials" >&2
            exit 1
          fi
          sleep 1
        done
        BUCKET="$(< ${config.sops.secrets.r2_bucket.path})"
        exec ${rclonePkg}/bin/rclone mount "r2:$BUCKET" /var/media/music \
          --config ${config.sops.templates."rclone-r2.conf".path} \
          --cache-dir /var/cache/rclone-r2 \
          --allow-other \
          --allow-non-empty \
          --uid 1000 \
          --gid 100 \
          --umask 022 \
          --vfs-cache-mode full \
          --vfs-cache-max-size 10G \
          --vfs-cache-max-age 720h \
          --dir-cache-time 12h \
          --attr-timeout 12h \
          --vfs-read-chunk-size 2M \
          --vfs-read-chunk-size-limit 64M \
          --vfs-fast-fingerprint \
          --buffer-size 16M \
          --poll-interval 0 \
          --rc \
          --rc-addr 127.0.0.1:5572 \
          --rc-no-auth
      '';
    in
    {
      programs.fuse.userAllowOther = true;

      sops.secrets.r2_account_id = {
        sopsFile = ../../secrets/mull.yaml;
      };
      sops.secrets.r2_access_key_id = {
        sopsFile = ../../secrets/mull.yaml;
      };
      sops.secrets.r2_secret_access_key = {
        sopsFile = ../../secrets/mull.yaml;
      };
      sops.secrets.r2_bucket = {
        sopsFile = ../../secrets/mull.yaml;
      };

      sops.templates."rclone-r2.conf" = {
        content = ''
          [r2]
          type = s3
          provider = Cloudflare
          access_key_id = ${config.sops.placeholder.r2_access_key_id}
          secret_access_key = ${config.sops.placeholder.r2_secret_access_key}
          endpoint = https://${config.sops.placeholder.r2_account_id}.r2.cloudflarestorage.com
          acl = private
          no_check_bucket = true
        '';
        mode = "0600";
        owner = "root";
      };

      systemd.services.rclone-r2-music = {
        description = "Mount Cloudflare R2 bucket to /var/media/music";
        after = [
          "network-online.target"
          "sops-install-secrets.service"
        ];
        wants = [
          "network-online.target"
          "sops-install-secrets.service"
        ];
        wantedBy = [ "multi-user.target" ];
        path = [
          pkgs.fuse3
          "/run/wrappers"
        ];
        serviceConfig = {
          Type = "notify";
          CacheDirectory = "rclone-r2";
          ExecStartPre = [
            "-${pkgs.fuse3}/bin/fusermount3 -u -z /var/media/music"
          ];
          ExecStart = mountScript;
          ExecStop = "${pkgs.fuse3}/bin/fusermount3 -u -z /var/media/music";
          Restart = "on-failure";
          RestartSec = "10s";
        };
      };

      systemd.services.navidrome = {
        after = [ "rclone-r2-music.service" ];
        requires = [ "rclone-r2-music.service" ];
      };
    };
}
