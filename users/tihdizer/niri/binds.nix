{ inputs, ... }:
{
  flake.modules.homeManager.tihdizer-niri-binds =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      inherit (lib) getExe mkMerge;
      wpctl = "${pkgs.wireplumber}/bin/wpctl";
      playerctl = "${pkgs.playerctl}/bin/playerctl";
      launcher = getExe pkgs.fuzzel;
      copyq = getExe pkgs.copyq;
      term = getExe pkgs.kitty;
      logout = getExe pkgs.wlogout;
      niri = getExe config.programs.niri.package;
      jq = getExe pkgs.jq;
      zellij = getExe pkgs.zellij;
      tele = getExe inputs.tele.packages.${pkgs.stdenv.hostPlatform.system}.default;
      notifySend = getExe pkgs.libnotify;
      castWindow = getExe (
        pkgs.writeShellScriptBin "niri-cast-window" ''
          ${niri} msg action set-dynamic-cast-window
          TITLE="$(${niri} msg -j focused-window 2>/dev/null | ${jq} -r '.title // .app_id // empty')"
          if [ -n "$TITLE" ]; then
            ${notifySend} -h string:synchronous:dynamic-cast -a "niri" -i video-display "Dynamic Cast" "Target: window ($TITLE)"
          else
            ${notifySend} -h string:synchronous:dynamic-cast -a "niri" -i video-display "Dynamic Cast" "Target: focused window"
          fi
        ''
      );
      castMonitor = getExe (
        pkgs.writeShellScriptBin "niri-cast-monitor" ''
          ${niri} msg action set-dynamic-cast-monitor
          OUTPUT="$(${niri} msg -j workspaces 2>/dev/null | ${jq} -r '.[] | select(.is_focused == true) | .output // empty')"
          if [ -n "$OUTPUT" ]; then
            ${notifySend} -h string:synchronous:dynamic-cast -a "niri" -i video-display "Dynamic Cast" "Target: monitor ($OUTPUT)"
          else
            ${notifySend} -h string:synchronous:dynamic-cast -a "niri" -i video-display "Dynamic Cast" "Target: focused monitor"
          fi
        ''
      );
      castClear = getExe (
        pkgs.writeShellScriptBin "niri-cast-clear" ''
          ${niri} msg action clear-dynamic-cast-target
          ${notifySend} -h string:synchronous:dynamic-cast -a "niri" -i video-display "Dynamic Cast" "Target cleared"
        ''
      );
    in
    {
      programs.niri.settings.binds =
        with config.lib.niri.actions;
        mkMerge [
          {
            #= Audio
            "XF86AudioMute" = {
              allow-when-locked = true;
              action.spawn = [
                wpctl
                "set-mute"
                "@DEFAULT_AUDIO_SINK@"
                "toggle"
              ];
            };
            "XF86AudioMicMute" = {
              allow-when-locked = true;
              action.spawn = [
                wpctl
                "set-mute"
                "@DEFAULT_AUDIO_SOURCE@"
                "toggle"
              ];
            };
            "XF86AudioRaiseVolume" = {
              allow-when-locked = true;
              action.spawn = [
                wpctl
                "set-volume"
                "@DEFAULT_AUDIO_SINK@"
                "5%+"
              ];
            };
            "XF86AudioLowerVolume" = {
              allow-when-locked = true;
              action.spawn = [
                wpctl
                "set-volume"
                "@DEFAULT_AUDIO_SINK@"
                "5%-"
              ];
            };

            "XF86AudioPlay" = {
              allow-when-locked = true;
              action.spawn = [
                playerctl
                "play-pause"
              ];
            };
            "XF86AudioStop" = {
              allow-when-locked = true;
              action.spawn = [
                playerctl
                "pause"
              ];
            };
            "XF86AudioPrev" = {
              allow-when-locked = true;
              action.spawn = [
                playerctl
                "previous"
              ];
            };
            "XF86AudioNext" = {
              allow-when-locked = true;
              action.spawn = [
                playerctl
                "next"
              ];
            };

            #= Launch/Spawn Software
            "Mod+Shift+T".action.spawn = [
              term
              "--class"
              "term-floating"
              "-e"
              zellij
              "attach"
              "-c"
              "float"
            ];
            "Mod+E".action.spawn = [
              term
              "--class"
              "yazi"
              "-e"
              (getExe config.programs.yazi.package)
            ];
            "Mod+Shift+E".action.spawn = [
              term
              "--class"
              "yazi-floating"
              "-e"
              (getExe config.programs.yazi.package)
            ];
            "Mod+A".action.spawn = [ 
              term
              "--class"
              "tele"
              "-e"
              tele
            ];
            "Mod+D".action.spawn = [ launcher ];
            "Mod+Y".action.spawn = [
              copyq
              "toggle"
            ];
            "Mod+P".action.spawn = [
              term
              "--class"
              "volume"
              "-e"
              (getExe pkgs.wiremix)
            ];
            "Mod+Escape".action.spawn = [
              term
              "--class"
              "btm"
              "-e"
              (getExe pkgs.bottom)
            ];
            "Mod+Shift+Escape".action.spawn = [ logout ];

            #= Screenshots
            "Print".action.screenshot.show-pointer = true;
            "Shift+Print".action.screenshot-window.write-to-disk = true;

            #= Dynamic Cast Target (Screencast)
            "Mod+Ctrl+M".action.spawn = [ castWindow ];
            "Mod+Shift+M".action.spawn = [ castMonitor ];
            "Mod+Ctrl+Shift+M".action.spawn = [ castClear ];

            #= Actions
            "Mod+W".action = toggle-column-tabbed-display;
            "Mod+O".action = toggle-overview;
            "Mod+Q".action = close-window;
            "Mod+R".action = switch-preset-column-width;
            "Mod+Ctrl+R".action = reset-window-height;
            "Mod+Shift+R".action = switch-preset-window-height;
            "Mod+Minus".action = set-column-width "-10%";
            "Mod+Equal".action = set-column-width "+10%";
            "Mod+Shift+Minus".action = set-window-height "-10%";
            "Mod+Shift+Equal".action = set-window-height "+10%";
            "Mod+F".action = maximize-column;
            "Mod+Ctrl+F".action = expand-column-to-available-width;
            "Mod+Shift+F".action = fullscreen-window;
            "Mod+Shift+Ctrl+F".action = toggle-windowed-fullscreen;
            "Mod+Shift+V".action = toggle-window-floating;
            "Mod+V".action = switch-focus-between-floating-and-tiling;

            "Mod+Shift+Slash".action = show-hotkey-overlay;

            "Mod+Comma".action = consume-or-expel-window-left;
            "Mod+Period".action = consume-or-expel-window-right;
            "Mod+C".action = center-column;
            "Mod+Ctrl+C".action = center-visible-columns;

            #= Focus Windows
            "Mod+H".action = focus-column-left;
            "Mod+J".action = focus-window-down;
            "Mod+K".action = focus-window-up;
            "Mod+L".action = focus-column-right;

            "Mod+U".action = focus-workspace-down;
            "Mod+I".action = focus-workspace-up;

            "Mod+Home".action = focus-column-first;
            "Mod+End".action = focus-column-last;

            "Mod+Shift+H".action = focus-monitor-left;
            "Mod+Shift+L".action = focus-monitor-right;
            "Mod+Shift+K".action = focus-monitor-up;
            "Mod+Shift+J".action = focus-monitor-down;

            #= Move Windows
            "Mod+Ctrl+H".action = move-column-left;
            "Mod+Ctrl+J".action = move-window-down;
            "Mod+Ctrl+K".action = move-window-up;
            "Mod+Ctrl+L".action = move-column-right;

            "Mod+Ctrl+U".action = move-column-to-workspace-down;
            "Mod+Ctrl+I".action = move-column-to-workspace-up;

            "Mod+Ctrl+Home".action = move-column-to-first;
            "Mod+Ctrl+End".action = move-column-to-last;

            "Mod+Shift+Ctrl+H".action = move-column-to-monitor-left;
            "Mod+Shift+Ctrl+L".action = move-column-to-monitor-right;
            "Mod+Shift+Ctrl+K".action = move-column-to-monitor-up;
            "Mod+Shift+Ctrl+J".action = move-column-to-monitor-down;
          }
        ];
    };
}
