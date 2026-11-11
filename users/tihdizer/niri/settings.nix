{ ... }:
{
  flake.modules.homeManager.tihdizer-niri-settings =
    { config, ... }:
    let
      scheme = config.lib.stylix.colors;
    in

    {
      programs.niri.settings = {
        window-rules = [
          {
            matches = [
              { is-window-cast-target = true; }
            ];

            border = {
              active.color = scheme.base08;
              inactive.color = scheme.base09;
            };

            tab-indicator = {
              active.color = scheme.base08;
              inactive.color = scheme.base09;
            };
          }
        ];
        cursor = {
          hide-after-inactive-ms = 3000;
          hide-when-typing = true;
          # theme = config.stylix.cursor.name;
        };
        overview = {
          zoom = 0.5;
        };
        layout = {
          empty-workspace-above-first = true;
          focus-ring.enable = false;

          border = {
            enable = true;
            width = 2;
            active.color = scheme.base0D;
            inactive.color = scheme.base03;
            urgent.color = scheme.base08;
          };

          center-focused-column = "never";

          background-color = scheme.base01;

          preset-window-heights = [
            { proportion = 1. / 3.; }
            { proportion = 1. / 2.; }
            { proportion = 2. / 3.; }
            { proportion = 1.; }
          ];

          preset-column-widths = [
            { proportion = 1. / 3.; }
            { proportion = 1. / 2.; }
            { proportion = 2. / 3.; }
            # { proportion = 1.; }
          ];

          default-column-width = {
            proportion = 1.0 / 3.0;
          };

          gaps = 2;
          struts = {
            left = 0;
            right = 0;
            top = 0;
            bottom = 0;
          };

          tab-indicator = {
            hide-when-single-tab = true;
            place-within-column = true;
            position = "left";
            corner-radius = 20.0;
            gap = -12.0;
            gaps-between-tabs = 10.0;
            width = 4.0;
            length.total-proportion = 0.1;
          };
        };

        gestures = {
          hot-corners.enable = false;
        };
        prefer-no-csd = true;
        hotkey-overlay.skip-at-startup = true;
        screenshot-path = "~/pictures/screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
      };

      dconf.settings."org/gnome/desktop/wm/preferences" = {
        button-layout = "";
      };

      gtk = {
        gtk3.extraConfig.gtk-decoration-layout = ":";
        gtk4.extraConfig.gtk-decoration-layout = ":";
      };
    };
}
