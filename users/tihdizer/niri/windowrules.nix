{ ... }:
{
  flake.modules.homeManager.tihdizer-niri-windowrules =
    { ... }:
    let
      primary-monitor = "DP-4";
      # secondary-monitor = "DP-5";
      tv = "HDMI-A-2";
    in
    {
      programs.niri.settings = {
        workspaces = {
          "00-stash" = {
            name = "stash";
            open-on-output = primary-monitor;
          };
          "01-personal" = {
            name = "personal";
            open-on-output = primary-monitor;
          };
          "02-comms" = {
            name = "comms";
            open-on-output = primary-monitor;
          };
          "03-study" = {
            name = "study";
            open-on-output = primary-monitor;
          };
          "04-work" = {
            name = "work";
            open-on-output = primary-monitor;
          };
          "05-games" = {
            name = "games";
            open-on-output = primary-monitor;
          };
          "06-ops" = {
            name = "ops";
            open-on-output = primary-monitor;
          };
          "07-media" = {
            name = "media";
            open-on-output = tv;
          };
        };
        layer-rules = [
          {
            matches = [ { namespace = "^awww-daemon$"; } ];
            place-within-backdrop = true;
          }
        ];

        window-rules = [
          # personal
          # study
          # work
          # comms
          {
            matches = [
              { app-id = "org.telegram.desktop"; }
              { app-id = "^chrome-web\\.telegram\\.org"; }
              { app-id = "tele"; }
              { app-id = "^(discord|vesktop|Vesktop)(_canary)?$"; }
            ];
            default-column-width = {
              proportion = 1. / 2.;
            };
            block-out-from = "screencast";
            open-on-workspace = "comms";
          }

          # ops
          {
            matches = [
              { app-id = "io.github.ilya_zlobintsev.LACT"; }
              { app-id = "Throne"; }
              { app-id = ".virt-manager-wrapped"; }
              { app-id = "org.qbittorrent.qBittorrent"; }
              { app-id = ".blueman-manager-wrapped"; }
            ];
            default-column-width = {
              proportion = 1. / 2.;
            };
            open-on-workspace = "ops";
          }

          # games
          {
            matches = [
              { app-id = "^steam_app_\\d+"; }
              { app-id = "dota2"; }
              { app-id = "cs2"; }
              { title = "^Geometry Dash$"; }
            ];
            open-focused = false;
            open-on-workspace = "games";
          }

          {
            matches = [
              {
                title = "Steam";
                app-id = "steam";
              }
              {
                title = "Special Offers";
                app-id = "steam";
              }
              {
                title = "Launching...";
                app-id = "steam";
              }
            ];
            default-column-width = {
              proportion = 2. / 3.;
            };
            open-focused = false;
            open-on-workspace = "games";
          }

          {
            matches = [
              {
                title = "Friends List";
                app-id = "steam";
              }
            ];
            default-column-width = {
              proportion = 1. / 3.;
            };
            open-focused = false;
            open-on-workspace = "games";
          }

          {
            matches = [
              {
                title = "notificationtoasts";
                app-id = "steam";
              }
            ];
            open-floating = true;
            default-floating-position = {
              x = 10;
              y = 10;
              relative-to = "bottom-right";
            };
            open-focused = false;
            open-on-workspace = "games";
          }

          # stash

          # media
          {
            matches = [
              { app-id = "feishin"; }
              { app-id = "psysonic"; }
            ];
            default-column-width = {
              proportion = 1. / 2.;
            };
            open-on-workspace = "media";
          }

          # other
          {
            matches = [
              { app-id = "clipboard"; }
              { app-id = "copyq"; }
            ];
            open-floating = true;
            default-floating-position = {
              x = 0;
              y = 180;
              relative-to = "top";
            };
            default-column-width = {
              proportion = 1. / 3.;
            };
            default-window-height = {
              proportion = 2. / 3.;
            };
            min-height = 100;
            block-out-from = "screencast";
          }

          {
            matches = [
              { app-id = "yazi"; }
            ];
            default-column-width = {
              proportion = 1. / 2.;
            };
          }

          {
            matches = [
              { app-id = "org.pulseaudio.pavucontrol"; }
              { app-id = "com.saivert.pwvucontrol"; }
              { app-id = "yazi-floating"; }
              { app-id = "volume"; }
              { app-id = "btm"; }
              { app-id = "term-floating"; }
              { app-id = "file_chooser"; }
            ];
            open-floating = true;
            default-floating-position = {
              x = 0;
              y = 180;
              relative-to = "top";
            };
            default-column-width = {
              proportion = 2. / 3.;
            };
            default-window-height = {
              proportion = 2. / 3.;
            };
          }

          {
            matches = [ { title = "(?i)picture[- ]in[- ]picture"; } ];
            open-floating = true;
            default-floating-position = {
              x = 2;
              y = 6;
              relative-to = "bottom-left";
            };
            open-focused = false;
          }

          {
            geometry-corner-radius =
              let
                radius = 12.0;
              in
              {
                bottom-left = radius;
                bottom-right = radius;
                top-left = radius;
                top-right = radius;
              };
            clip-to-geometry = true;
          }

          {
            matches = [ { is-floating = true; } ];
            min-width = 100;
            min-height = 100;
          }
        ];
      };
    };
}
