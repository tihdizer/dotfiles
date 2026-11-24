{ inputs, ... }:
let
  configTemplate =
    sub1: sub2: sub3: doonaPath: xraySocksPort: ''
    global {
      tproxy_port: 12345
      tproxy_port_protect: true
      log_level: info
      wan_interface: auto
      lan_interface: virbr0, auto
      auto_config_kernel_parameter: true
      dial_mode: domain++
      tls_implementation: utls
      utls_imitate: chrome_auto
      tcp_check_url: 'https://www.gstatic.com/generate_204'
      tcp_check_http_method: HEAD
      udp_check_dns: '77.88.8.8:53', '8.8.8.8:53'
      bootstrap_resolver: '77.88.8.8:53'
      check_interval: 30s
      check_tolerance: 50ms
      disable_waiting_network: false
    }

    experimental {
      native_api {
        enabled: true
        listen: '127.0.0.1:9527'
        password_auth: true
        config_write: true
        ui: '${doonaPath}'
      }
    }

    node {
      xray: 'socks5://127.0.0.1:${toString xraySocksPort}'
    }

    subscription {
      sub1: '${sub1}'
      # sub2 is managed directly by xray
      # sub3: '${sub3}'
    }

    dns {
      ipversion_prefer: 4

      upstream {
        landns: 'udp://77.88.8.8:53'
        googledns: 'tcp://8.8.8.8:53' -> proxy
      }
      routing {
        request {
          qname(suffix: ru, suffix: su, suffix: 'xn--p1ai', suffix: '1o0.net', suffix: 'yandex.net') -> landns

          fallback: googledns
        }

        response {
          fallback: accept
        }
      }
    }

    group {
      proxy {
        filter: !name(regex: '(?i).*(support|info|chat|канал|⛔️|россия).*')
        policy: min_avg10
        final: direct
      }

      germany {
        filter: name(regex: '(?i).*(германия).*')
        policy: min_moving_avg
        final: proxy
      }

      ai {
        filter: name('xray')
        policy: fixed(0)
        final: germany
      }
    }

    routing {
      #system
      pname(
        NetworkManager,
        xray
      ) -> direct

      dip(
        224.0.0.0/4,
        geoip:private,
        'ff00::/8'
      ) -> direct

      l4proto(udp) && dport(443) -> block

      dip(
        84.21.191.196,
        84.21.191.197
      ) -> direct

      domain(
        suffix: 1o0.net
      ) -> direct

      domain(
        geosite: category-ru,
        geosite: steam,
        geosite: twitch,
        geosite: epicgames,
        geosite: riot,
        geosite: escapefromtarkov,
        geosite: faceit,
        geosite: apple,
        geosite: microsoft
      ) -> direct

      #proxy
      domain(
        geosite: google-play,
        geosite: discord,
        geosite: github,
        geosite: telegram,
        geosite: amazon,
        geosite: category-public-tracker,
        geosite: piratebay,
        geosite: 1337x,
        geosite: nyaa,
        geosite: rutracker,
        geosite: btdig,
        geosite: spotify,
        geosite: soundcloud,

        suffix: 1flex.org,
        suffix: ankiweb.net,
        suffix: ankisrs.net,
        suffix: annas-archive.li,
        suffix: b-cdn.net,
        suffix: b4mcx2ml.net,
        suffix: berserk-games.com,
        suffix: britishcouncil.org,
        suffix: captcha-delivery.com,
        suffix: cdn-perfprod.com,
        suffix: coursera.org,
        suffix: cyberia.is,
        suffix: cloudflare.com,
        suffix: deezer.com,
        suffix: dub.co,
        suffix: edx.org,
        suffix: ets.org,
        suffix: exodus.desync.com,
        suffix: givefreely.com,
        suffix: glotorrents.pw,
        suffix: englishclub.com,
        suffix: healthapp.google,
        suffix: hetzner.com,
        suffix: hetzner.de,
        suffix: hostbrr.com,
        suffix: jcode.sh,
        suffix: jetbrains.com,
        suffix: justwatch.com,
        suffix: kali.download,
        suffix: kali.org,
        suffix: kick.com,
        suffix: kinozal.me,
        suffix: kinozal.tv,
        suffix: last.fm,
        suffix: lrclib.net,
        suffix: linkedin.com,
        suffix: metabrainz.org,
        suffix: music-assistant.io,
        suffix: musicbrainz.org,
        suffix: nixos.org,
        suffix: numtide.com,
        suffix: online-latin-dictionary.com,
        suffix: open.demonii.com,
        suffix: open.stealth.si,
        suffix: opentrackr.org,
        suffix: openrouter.ai,
        suffix: ororo.tv,
        suffix: oup.com,
        suffix: oxfordlearnersdictionaries.com,
        suffix: penpot.app,
        suffix: polarbyte.com,
        suffix: p4p.arenabg.com,
        suffix: pages.dev,
        suffix: perplexity.ai,
        suffix: primevideo.com,
        suffix: protondb.com,
        suffix: public.popcorn-tracker.org,
        suffix: pyratelan.org,
        suffix: rapoo.com,
        suffix: roku.com,
        suffix: rutor.org,
        suffix: soundcloud.com,
        suffix: speedtest.net,
        suffix: speedtest.com,
        suffix: speed.cloudflare.com,
        suffix: starship.rs,
        suffix: tihdizer.online,
        suffix: throne.me,
        suffix: tor2me.info,
        suffix: tor4me.info,
        suffix: torrent.eu.org,
        suffix: torrent.gresille.org,
        suffix: torrent4me.com,
        suffix: tracker.bittor.pw,
        suffix: tracker.coppersurfer.tk,
        suffix: tracker.dler.org,
        suffix: tracker.internetwarriors.net,
        suffix: trustedhousesitters.com,
        suffix: whatismyipaddress.com,
        suffix: oracle.com,
        suffix: oraclecloud.com,
        suffix: oracleiaas.com,
        suffix: zoom.us,

        suffix: 2ip.ru,
        suffix: 2ip.io,
        suffix: browserleaks.com,
        suffix: whoer.net,
        suffix: ipleak.net,
        suffix: ipinfo.io,
        suffix: ifconfig.me,
        suffix: ifconfig.co,
        suffix: ip.sb,

        suffix: artstation.com,
        suffix: plati.market,
        suffix: plati.ru,
        suffix: ggsel.net,
        suffix: ggsel.com,
        suffix: oplata.info,
        suffix: digiseller.market,
        suffix: digiseller.ru
      ) -> proxy

      pname(
        .Telegram-wrapped,
        Telegram,
        tele,
        .Discord-wrapped,
        discord,
        .Vesktop-wrapped,
        vesktop,
        .anki-wrapped,
        anki,
        Anki,
        Tabletop,
        Tabletop.x86_64,
        'Tabletop Simulator',
        'Tabletop Simulator.x86_64',
        'Tabletop Simula',
        Tabletop.exe,
        'Tabletop Simulator.exe',
        'python3.13'
      ) -> proxy

      #ai & gemini
      domain(
        geosite: openai,
        geosite: anthropic,
        geosite: google-gemini,

        suffix: gemini.google.com,
        suffix: bard.google.com,
        suffix: ai.google.dev,
        suffix: aistudio.google.com,
        suffix: generativeai.googleapis.com,
        suffix: generativelanguage.googleapis.com,
        suffix: proactivebackend-pa.googleapis.com,
        suffix: alkalimakersuite-pa.clients6.google.com,
        suffix: oaiusercontent.com,
        suffix: oaistatic.com,
        suffix: claude.ai,
        suffix: claude.com,
        suffix: anthropic.com,
        suffix: kimi.ai,
        suffix: kimi.com,
        suffix: moonshot.cn,
        suffix: x.ai,
        suffix: grok.com,
        suffix: devin.ai,
        suffix: fast.com,
        suffix: mail.google.com,
        suffix: antigravity.google,
        suffix: cloudcode-pa.googleapis.com,
        suffix: deepmind.google,
        suffix: deepmind.com
      ) -> ai

      #google general
      domain(
        geosite: youtube
      ) -> germany

      domain(
        geosite: google
      ) -> germany

      dip(
        77.88.8.8,
        geoip:ru
      ) -> direct

      domain(
        suffix: ru,
        suffix: su,
        suffix: xn--p1ai
      ) -> direct



      #fallback
      fallback: direct
    }
  '';
in
{
  flake-file.inputs = {
    daeuniverse = {
      url = "github:daeuniverse/flake.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.nixos.honk =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      doona = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
        pname = "doona";
        version = "0.1.0-rc.7";

        src = pkgs.fetchurl {
          url = "https://github.com/Zakkaus/doona/releases/download/v${finalAttrs.version}/doona-${finalAttrs.version}.tar.gz";
          hash = "sha256-Xlm+9HDHCxzdMEshH/HhJ/ghbqRZk89Owh07f272MOM=";
        };

        fonts = pkgs.fetchurl {
          url = "https://github.com/Zakkaus/doona/releases/download/v${finalAttrs.version}/doona-fonts-${finalAttrs.version}.tar.gz";
          hash = "sha256-ku/O20mEFcM2eK+MSrulBA+mHx785Dcev15t7H+UAB0=";
        };

        dontUnpack = true;
        installPhase = ''
          runHook preInstall
          mkdir -p $out/share/doona
          tar -xzf $src -C $out/share/doona
          tar -xzf $fonts -C $out/share/doona
          runHook postInstall
        '';
      });

      honkPackage = inputs.daeuniverse.packages.${pkgs.stdenv.hostPlatform.system}.honk.overrideAttrs (old: {
        buildPhase = builtins.replaceStrings [ "--features ebpf" ] [ "--features ebpf,native-api" ] old.buildPhase;
      });

      xrayStateDir = "xray";
      xrayDataDir = "/var/lib/${xrayStateDir}";
      xraySubName = "sub2";
      xrayRawConfig = "${xrayDataDir}/${xraySubName}-raw.json";
      xrayExtractedConfig = "${xrayDataDir}/${xraySubName}-extracted.json";
      xrayConfig = "${xrayDataDir}/${xraySubName}.json";
      xraySecretPath = config.sops.secrets.${xraySubName}.path;
      xraySocksPort = 10808;
    in
    {
      imports = [
        inputs.daeuniverse.nixosModules.honk
      ];

      environment.systemPackages = [
        doona
        pkgs.xray
      ];

      services.honk-proxy = {
        enable = true;
        configFile = config.sops.templates."honk-config.dae".path;
        package = honkPackage;
      };

      sops.secrets.sub1 = { };
      sops.secrets.sub2 = { };
      sops.secrets.sub3 = { };

      sops.templates."honk-config.dae" = {
        content =
          configTemplate
            config.sops.placeholder.sub1
            config.sops.placeholder.sub2
            config.sops.placeholder.sub3
            "${doona}/share/doona"
            xraySocksPort;
        mode = "0600";
        owner = "root";
      };

      systemd.services.honk = {
        after = [ "xray.service" ];
        wants = [ "xray.service" ];
        restartTriggers = [
          config.sops.templates."honk-config.dae".path
        ];
        serviceConfig = {
          Type = lib.mkForce "exec";
          Restart = "on-failure";
          RestartSec = "2s";
        };
      };

      systemd.services.xray = {
        description = "Xray service";
        after = [ "network-online.target" "sops-nix.service" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "simple";
          Restart = "on-failure";
          RestartSec = "5s";
          StateDirectory = xrayStateDir;
          RuntimeDirectory = xrayStateDir;
        };

        path = with pkgs; [
          curl
          xray
          jq
          coreutils
        ];

        script = ''
          mkdir -p "${xrayDataDir}"

          if [ -f "${xraySecretPath}" ]; then
            SUB_URL=$(cat "${xraySecretPath}" | tr -d '[:space:]')
            if [ -n "$SUB_URL" ]; then
              echo "Fetching ${xraySubName} configuration from provider..."
              curl -sSL --retry 3 --max-time 15 -H "User-Agent: v2rayN/6.23" "$SUB_URL" -o "${xrayRawConfig}" || true
              if [ -s "${xrayRawConfig}" ]; then
                jq 'if type == "array" then (map(select(.remarks | test("(?i)AI")))[0] // .[0]) else . end' "${xrayRawConfig}" > "${xrayExtractedConfig}" 2>/dev/null || true

                if [ -s "${xrayExtractedConfig}" ] && xray run -c "${xrayExtractedConfig}" -test >/dev/null 2>&1; then
                  echo "Extracted AI configuration is valid; applying."
                  cp "${xrayExtractedConfig}" "${xrayConfig}"
                fi
              fi
            fi
          fi

          if [ ! -s "${xrayConfig}" ]; then
            echo "Error: ${xrayConfig} is missing or empty."
            exit 1
          fi

          exec xray run -c "${xrayConfig}"
        '';
      };
    };
}
