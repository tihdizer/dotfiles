{ ... }:
{
  flake.modules.nixos.mpv =
    { ... }:
    {
      networking.firewall.allowedTCPPorts = [
        23456
        61777
      ];
    };

  flake.modules.homeManager.mpv =
    { pkgs, ... }:
    let
      version = "0.1.9";
      mpv-subtitleminer-bin = pkgs.rustPlatform.buildRustPackage {
        pname = "mpv-subtitleminer";
        inherit version;
        src = pkgs.fetchFromGitHub {
          owner = "friedrich-de";
          repo = "mpv-subtitleminer";
          rev = "v${version}";
          hash = "sha256-ckOdtvd4tY+Xm2cHLY5lLnF+zyG/Z3Ja8KKm/B5SSLA=";
        };
        cargoHash = "sha256-dHAdBU6bGYTxczo7EW8Yj+N/0F/dAQiGvqsCEVDyfnI=";
        nativeBuildInputs = [ pkgs.pkg-config ];
        buildInputs = [ pkgs.openssl ];
      };

      mpv-subtitleminer-web-src = pkgs.fetchzip {
        url = "https://github.com/friedrich-de/mpv-subtitleminer/releases/download/v${version}/mpv-subtitleminer-x86_64-unknown-linux-gnu.zip";
        hash = "sha256-Bb6+vUTGEmBVKbzDPgdcuBRCL42lh6sh6HNRMvhDp70=";
        stripRoot = false;
      };

      mpv-subtitleminer-web = pkgs.runCommand "mpv-subtitleminer-web" { } ''
                mkdir -p $out
                cat << 'EOF' > $out/controls.html
        <div id="mpv-remote-bar" style="position:fixed;bottom:20px;right:20px;z-index:999999;display:flex;align-items:center;gap:10px;background:rgba(20,24,32,0.94);border:1px solid #374151;padding:10px 14px;border-radius:16px;box-shadow:0 12px 32px rgba(0,0,0,0.7);backdrop-filter:blur(10px);touch-action:none;user-select:none;-webkit-user-select:none;">
          <span id="mpv-drag-handle" style="cursor:grab;color:#9ca3af;font-size:18px;padding-right:4px;">⠿</span>
          <button onclick="mpvControl('seek/-5')" style="background:#282e3a;color:#e5e7eb;border:1px solid #3f4756;border-radius:10px;padding:9px 12px;font-size:15px;font-weight:600;cursor:pointer;">⏪ -5s</button>
          <button id="mpv-play-btn" onclick="mpvControl('toggle_pause')" style="background:#3ddc97;color:#0b1d14;border:none;border-radius:10px;padding:9px 16px;font-size:15px;font-weight:bold;cursor:pointer;">⏯ Play/Pause</button>
          <button onclick="mpvControl('seek/5')" style="background:#282e3a;color:#e5e7eb;border:1px solid #3f4756;border-radius:10px;padding:9px 12px;font-size:15px;font-weight:600;cursor:pointer;">+5s ⏩</button>
          <button onclick="mpvControl('toggle_sub')" style="background:#3b4252;color:#e5e7eb;border:1px solid #4c566a;border-radius:10px;padding:9px 12px;font-size:15px;font-weight:600;cursor:pointer;" title="Hide/Show Subtitles">👁 Subs</button>
          <button onclick="mpvControl('cycle_sub')" style="background:#3b4252;color:#e5e7eb;border:1px solid #4c566a;border-radius:10px;padding:9px 12px;font-size:15px;font-weight:600;cursor:pointer;" title="Cycle Next Subtitle Track">🔄 Next Sub</button>
        </div>
        <script>
          function mpvControl(action) {
            fetch('/api/' + action, { method: 'POST' })
              .catch(e => console.error('[MPV-Control]', e));
          }

          (function() {
            const el = document.getElementById('mpv-remote-bar');
            let isDragging = false, startX, startY, origX, origY;

            function onStart(e) {
              if (e.target.tagName === 'BUTTON') return;
              isDragging = true;
              const t = e.touches ? e.touches[0] : e;
              startX = t.clientX;
              startY = t.clientY;
              const rect = el.getBoundingClientRect();
              origX = rect.left;
              origY = rect.top;
            }

            function onMove(e) {
              if (!isDragging) return;
              const t = e.touches ? e.touches[0] : e;
              const dx = t.clientX - startX;
              const dy = t.clientY - startY;
              el.style.left = (origX + dx) + 'px';
              el.style.top = (origY + dy) + 'px';
              el.style.bottom = 'auto';
              el.style.right = 'auto';
            }

            function onEnd() { isDragging = false; }

            el.addEventListener('mousedown', onStart);
            window.addEventListener('mousemove', onMove);
            window.addEventListener('mouseup', onEnd);
            el.addEventListener('touchstart', onStart, { passive: true });
            window.addEventListener('touchmove', onMove, { passive: true });
            window.addEventListener('touchend', onEnd);
          })();
        </script>
        EOF
                substitute ${mpv-subtitleminer-web-src}/mpv/index.html $out/index.html \
                  --replace-fail 'connection:{host:"127.0.0.1"' 'connection:{host:window.location.hostname||"127.0.0.1"'
                sed -i -e '/<\/body>/e cat '"$out/controls.html" $out/index.html
                rm -f $out/controls.html
      '';

      mpv-control-bridge = pkgs.writers.writePython3Bin "mpv-control-bridge" { } ''
        import http.server
        import json
        import socket


        class Handler(http.server.BaseHTTPRequestHandler):
            def log_message(self, format, *args):
                pass

            def do_POST(self):
                if self.path == "/api/toggle_pause":
                    cmd = b'{"command":["cycle","pause"]}\n'
                elif self.path == "/api/toggle_sub":
                    cmd = b'{"command":["cycle","sub-visibility"]}\n'
                elif self.path == "/api/cycle_sub":
                    cmd = b'{"command":["cycle","sub"]}\n'
                elif self.path.startswith("/api/seek/"):
                    try:
                        sec = float(self.path.split("/api/seek/")[1])
                        payload = {"command": ["seek", sec, "relative"]}
                        cmd = json.dumps(payload).encode("utf-8") + b"\n"
                    except Exception:
                        self.send_response(400)
                        self.end_headers()
                        return
                else:
                    self.send_response(404)
                    self.end_headers()
                    return

                try:
                    s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
                    s.connect("/tmp/mpvsocket")
                    s.sendall(cmd)
                    res = s.recv(1024)
                    s.close()
                    self.send_response(200)
                    self.send_header("Content-Type", "application/json")
                    self.send_header("Access-Control-Allow-Origin", "*")
                    self.end_headers()
                    self.wfile.write(res)
                except Exception as e:
                    self.send_response(502)
                    self.send_header("Content-Type", "application/json")
                    self.send_header("Access-Control-Allow-Origin", "*")
                    self.end_headers()
                    err_msg = json.dumps({"error": str(e)}).encode("utf-8")
                    self.wfile.write(err_msg)

            def do_OPTIONS(self):
                self.send_response(200)
                self.send_header("Access-Control-Allow-Origin", "*")
                self.send_header("Access-Control-Allow-Methods", "POST, OPTIONS")
                self.send_header("Access-Control-Allow-Headers", "*")
                self.end_headers()


        server = http.server.ThreadingHTTPServer(("127.0.0.1", 23457), Handler)
        server.serve_forever()
      '';

      mpv-caddyfile = pkgs.writeText "Caddyfile" ''
        :23456 {
          handle /api/* {
            reverse_proxy 127.0.0.1:23457
          }
          handle {
            root * ${mpv-subtitleminer-web}
            file_server
          }
        }
      '';

      mpv-subtitleminer = pkgs.mpvScripts.buildLua {
        pname = "mpv-subtitleminer";
        inherit version;
        src = pkgs.fetchFromGitHub {
          owner = "friedrich-de";
          repo = "mpv-subtitleminer";
          rev = "v${version}";
          hash = "sha256-ckOdtvd4tY+Xm2cHLY5lLnF+zyG/Z3Ja8KKm/B5SSLA=";
        };
        dontUnpack = true;
        passthru = {
          scriptName = "mpv-subtitleminer.lua";
          bin = mpv-subtitleminer-bin;
        };
        installPhase = ''
          runHook preInstall
          mkdir -p $out/share/mpv/scripts
          substitute $src/mpv/mpv-subtitleminer.lua $out/share/mpv/scripts/mpv-subtitleminer.lua \
            --replace-fail 'local binary_path = utils.join_path(config_folder_path, binary_name)' 'local binary_path = "${mpv-subtitleminer-bin}/bin/mpv-subtitleminer"' \
            --replace-fail 'return ffmpeg_name' 'return "${pkgs.ffmpeg}/bin/ffmpeg"'
          runHook postInstall
        '';
      };

      mediaMimeTypes = [
        "video/mp4"
        "video/mkv"
        "video/x-matroska"
        "video/webm"
        "video/quicktime"
        "video/x-msvideo"
        "video/x-flv"
        "video/ogg"
        "video/x-ogm+ogg"
        "audio/mp3"
        "audio/mpeg"
        "audio/flac"
        "audio/ogg"
        "audio/wav"
        "audio/x-wav"
        "audio/aac"
        "audio/m4a"
      ];

      mimeAssociations = builtins.listToAttrs (
        map (mime: {
          name = mime;
          value = [ "mpv.desktop" ];
        }) mediaMimeTypes
      );
    in
    {
      programs.mpv = {
        enable = true;

        scripts = with pkgs.mpvScripts; [
          uosc
          thumbfast
          quality-menu
          mpris
          autoload
          mpv-subtitleminer
        ];

        config = {
          input-ipc-server = "/tmp/mpvsocket";
          save-position-on-quit = true;
          keep-open = true;

          osc = false;
          osd-bar = false;
          border = false;

          vo = "gpu-next";
          gpu-api = "vulkan";
          hwdec = "auto-safe";

          alang = "en,eng,en-uk,en-us,ru,rus";
          slang = "pgs,en-pgs,sdh,en-sdh,eng-sdh,en,eng,en-uk,en-us,en-forced,eng-forced,forced,ru,rus";

          sub-auto = "fuzzy";
          audio-file-auto = "fuzzy";

          sub-file-paths = "sub:subs:subtitles:Subtitles:Subs:Sub:srt:SRT:**";
          audio-file-paths = "audio:Audio:sound:tracks";

          ytdl-format = "bestvideo[height<=?2160]+bestaudio/best";
        };

        scriptOpts = {
          uosc = {
            timeline_style = "line";
            timeline_line_width = 3;
            timeline_size = 28;
            controls = "menu,gap,prev,play-pause,next,gap,subtitles,audio,video,playlist,fullscreen";
          };
          thumbfast = {
            hwdec = "auto-safe";
            network = true;
          };
          mpv-subtitleminer = {
            auto_start = "yes";
            ports = "61777,61778,61779,61780,61781";
          };
        };

        bindings = {
          "space" = "cycle pause; script-binding uosc/flash-pause-indicator";
          "MBTN_LEFT" = "cycle pause; script-binding uosc/flash-pause-indicator";
          "tab" = "script-binding uosc/toggle-ui";
          "m" = "script-binding uosc/menu";
          "MBTN_RIGHT" = "script-binding uosc/menu";
          "s" = "script-binding uosc/subtitles";
          "a" = "script-binding uosc/audio";
          "c" = "script-binding uosc/chapters";
          "p" = "script-binding uosc/items";
          "q" = "script-binding quality-menu/video_formats_toggle";
        };
      };

      xdg.mimeApps = {
        enable = true;
        defaultApplications = mimeAssociations;
      };

      xdg.configFile."mpv-subtitleminer".source = "${mpv-subtitleminer-web}";

      home.packages = with pkgs; [
        ffmpeg
        yt-dlp
        (pkgs.writeShellScriptBin "mpv-subtitleminer-ui" ''
          exec ''${pkgs.xdg-utils}/bin/xdg-open "http://localhost:23456"
        '')
      ];

      systemd.user.services.mpv-control-bridge = {
        Unit = {
          Description = "MPV Control Bridge";
          After = [ "network.target" ];
        };
        Service = {
          Type = "simple";
          ExecStart = "${mpv-control-bridge}/bin/mpv-control-bridge";
          Restart = "on-failure";
          RestartSec = "3s";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };

      systemd.user.services.mpv-subtitleminer-web = {
        Unit = {
          Description = "MPV Subtitle Miner Web UI Reverse Proxy";
          After = [
            "network.target"
            "mpv-control-bridge.service"
          ];
          Wants = [ "mpv-control-bridge.service" ];
        };
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.caddy}/bin/caddy run --config ${mpv-caddyfile} --adapter caddyfile";
          Restart = "on-failure";
          RestartSec = "3s";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
}
