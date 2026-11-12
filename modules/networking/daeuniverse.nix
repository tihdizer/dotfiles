{ inputs, ... }:
let
  configTemplate = sub1: sub2: sub3: ''
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
      tcp_check_url: 'http://cp.cloudflare.com,1.1.1.1'
      tcp_check_http_method: GET
      udp_check_dns: '8.8.8.8:53'
      check_interval: 30s
      check_tolerance: 50ms
      disable_waiting_network: false
    }

    subscription {
      sub1: '${sub1}'
      # sub2: '${sub2}'
      sub3: '${sub3}'
    }

    dns {
      ipversion_prefer: 4

      upstream {
        googledns: 'tcp://8.8.8.8:53'
        landns: 'tcp://77.88.8.8:53'
      }
      routing {
        request {
          qname(
            suffix: ru,
            suffix: su,
            suffix: xn--p1ai
          ) -> landns

          fallback: googledns
        }

        response {
          fallback: accept
        }
      }
    }

    group {
      proxy {
        filter: !name(regex: '(?i).*(support|info|chat|канал|hysteria|grpc|⛔️|россия|швеция|гейминг|франция).*')
        policy: min_avg10
      }

      ai {
        filter: name(regex: '(?i).*(ai).*')
        policy: min_moving_avg
      }

      germany {
        filter: name(regex: '(?i).*(германия).*')
        policy: min_moving_avg
      }
    }

    routing {
      #system
      pname(
        NetworkManager
      ) -> direct

      dip(
        224.0.0.0/4,
        geoip:private,
        'ff00::/8'
      ) -> direct

      l4proto(udp) && dport(443) -> block

      #proxy
      domain(
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
        suffix: zoom.us
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

      #ai
      domain(
        geosite: openai
      ) -> proxy

      domain(
        geosite: anthropic,

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
        suffix: fast.com
      ) -> ai
      
      #google
      domain(
        geosite: youtube
      ) ->  proxy

      domain(
        geosite: google,
        geosite: google-gemini,

        suffix: mail.google.com,
        suffix: antigravity.google,
        suffix: cloudcode-pa.googleapis.com
      ) ->  ai

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

  flake.modules.nixos.dae =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      imports = [
        inputs.daeuniverse.nixosModules.dae
      ];

      services.dae = {
        enable = true;
        configFile = config.sops.templates."dae-config.dae".path;
        package = inputs.daeuniverse.packages.${pkgs.stdenv.hostPlatform.system}.dae;
      };

      sops.secrets.sub1 = { };
      sops.secrets.sub2 = { };
      sops.secrets.sub3 = { };

      sops.templates."dae-config.dae" = {
        content =
          configTemplate
            config.sops.placeholder.sub1
            config.sops.placeholder.sub2
            config.sops.placeholder.sub3;
        mode = "0600";
        owner = "root";
      };

      systemd.services.dae = {
        restartTriggers = [
          config.sops.templates."dae-config.dae".path
        ];
        serviceConfig = {
          Type = lib.mkForce "exec";
          Restart = "on-failure";
          RestartSec = "2s";
        };
      };
    };

  flake.modules.nixos.honk =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      imports = [
        inputs.daeuniverse.nixosModules.honk
      ];

      services.honk-proxy = {
        enable = true;
        configFile = config.sops.templates."honk-config.dae".path;
        package = inputs.daeuniverse.packages.${pkgs.stdenv.hostPlatform.system}.honk;
      };

      sops.secrets.sub1 = { };
      sops.secrets.sub2 = { };
      sops.secrets.sub3 = { };

      sops.templates."honk-config.dae" = {
        content =
          configTemplate
            config.sops.placeholder.sub1
            config.sops.placeholder.sub2
            config.sops.placeholder.sub3;
        mode = "0600";
        owner = "root";
      };

      systemd.services.honk = {
        restartTriggers = [
          config.sops.templates."honk-config.dae".path
        ];
        serviceConfig = {
          Type = lib.mkForce "exec";
          Restart = "on-failure";
          RestartSec = "2s";
        };
      };
    };
}
