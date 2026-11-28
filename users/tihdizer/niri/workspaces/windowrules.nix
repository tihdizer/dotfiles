{ ... }:
{
  flake.modules.homeManager.tihdizer-niri-workspaces-windowrules =
    { ... }:
    {
      programs.niri.settings.window-rules = [
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

        {
          matches = [
            { app-id = "mpv"; }
          ];
          default-column-width = {
            proportion = 1. ;
          };
          open-on-workspace = "media";
        }
      ];
    };
}
