{ ... }:
{
  flake.modules.nixos.mull-beets =
    { pkgs, ... }:
    let
      inboxFolder = "/var/media/inbox";
      musicFolder = "/var/media/music";
      configDir = "/var/lib/beets";

      beetsConfigFile = pkgs.writeText "config.yaml" ''
        directory: ${musicFolder}

        library: ${configDir}/beets_library.db

        import:
          write: yes
          copy: no
          move: yes   
          quiet: no    
          autotag: yes  
          quiet_fallback: asis

        match:
          strong_rec_thresh: 0.30
          medium_rec_thresh: 0.50
          distance_weights:
            data_source: 2.0
            artist: 3.0
            album: 3.0
            media: 1.0
            mediums: 1.0
            year: 1.0
            country: 0.5
            label: 0.5
            catalognum: 0.5
            albumdisambig: 0.5
            album_id: 5.0
            tracks: 2.0
            missing_tracks: 0.0
            unmatched_tracks: 0.0
            track_title: 3.0
            track_artist: 2.0
            track_index: 1.0
            track_length: 2.0
            track_id: 5.0
            medium: 1.0

        paths:
          default: $albumartist/$album/$track - $title
          comp: Compilations/$album/$track - $title
          singleton: Non-Album/$artist - $title

        plugins: fetchart embedart lastgenre scrub musicbrainz fromfilename lyrics

        embedart:
          auto: yes 

        fetchart:
          auto: yes
          maxwidth: 1000
      '';

      beetsWatchScript = pkgs.writeShellScript "beets-watch" ''
        PATH="${
          pkgs.lib.makeBinPath [
            pkgs.beets
            pkgs.inotify-tools
            pkgs.coreutils
            pkgs.lsof
          ]
        }"

        mkdir -p "${inboxFolder}" "${musicFolder}" "${configDir}"

        echo "Starting beets watcher on ${inboxFolder}..."
        while true; do
          inotifywait -r -e close_write -e moved_to -e create "${inboxFolder}" > /dev/null 2>&1
          
          echo "Activity detected. Waiting for transfers to settle..."
          sleep 5

          while lsof +D "${inboxFolder}" > /dev/null 2>&1; do
            sleep 3
          done

          prev_size=$(du -sb "${inboxFolder}" 2>/dev/null | cut -f1)
          sleep 15
          curr_size=$(du -sb "${inboxFolder}" 2>/dev/null | cut -f1)

          while [ "$prev_size" != "$curr_size" ] || lsof +D "${inboxFolder}" > /dev/null 2>&1; do
            echo "Files are still growing or being written. Holding off..."
            prev_size=$curr_size
            sleep 5
            curr_size=$(du -sb "${inboxFolder}" 2>/dev/null | cut -f1)
          done

          if [ -z "$(ls -A "${inboxFolder}")" ]; then
            continue
          fi

          echo "Transfers fully completed. Running beets import..."
          beet -c "${beetsConfigFile}" import "${inboxFolder}"
        done
      '';
    in
    {
      environment.systemPackages = [
        pkgs.beets
        pkgs.inotify-tools
        pkgs.lsof
      ];

      systemd.tmpfiles.rules = [
        "d ${inboxFolder} 0775 tihdizer users -"
        "d ${musicFolder} 0775 tihdizer users -"
        "d ${configDir} 0750 tihdizer users -"
      ];

      systemd.services.beets-watcher = {
        description = "Beets Automated Music Importer";
        wantedBy = [ "multi-user.target" ];
        after = [
          "rclone-r2-music.service"
        ];
        requires = [
          "rclone-r2-music.service"
        ];

        serviceConfig = {
          Type = "simple";
          User = "tihdizer";
          Group = "users";
          ExecStart = beetsWatchScript;
          Restart = "on-failure";
          RestartSec = "10s";
          MemoryMax = "1G";
          MemoryHigh = "300M";
          CPUQuota = "30%";
        };
      };
    };
}
