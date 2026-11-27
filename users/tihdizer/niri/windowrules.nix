{ ... }:
{
  flake.modules.homeManager.tihdizer-niri-windowrules =
    { ... }:
    {
      programs.niri.settings = {
        layer-rules = [
          {
            matches = [ { namespace = "^awww-daemon$"; } ];
            place-within-backdrop = true;
          }
        ];

        window-rules = [
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
