{ inputs, ... }:
{
  flake.modules.homeManager.tihdizer-niri-workspaces =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      inherit (lib) getExe;
      primary-monitor = "DP-4";
      tv = "HDMI-A-2";

      niri = getExe config.programs.niri.package;
      jq = getExe pkgs.jq;
      term = getExe pkgs.kitty;
      zellij = getExe pkgs.zellij;

      workspaceTerm = getExe (
        pkgs.writeShellScriptBin "niri-workspace-term" ''
          WS_NAME="$(${niri} msg -j workspaces 2>/dev/null | ${jq} -r 'first(.[] | select(.is_focused == true) | (.name // (.idx | tostring))) // "main"')"
          exec ${term} -e ${zellij} attach -c "$WS_NAME"
        ''
      );

      popStash = getExe (
        pkgs.writeShellScriptBin "niri-pop-stash" ''
          STASH_WS_ID="$(${niri} msg -j workspaces 2>/dev/null | ${jq} -r 'first(.[] | select(.name == "stash") | .id) // empty')"
          if [ -z "$STASH_WS_ID" ]; then
            exit 0
          fi

          CURRENT_WS_ID="$(${niri} msg -j workspaces 2>/dev/null | ${jq} -r 'first(.[] | select(.is_focused == true) | .id) // empty')"
          if [ -z "$CURRENT_WS_ID" ] || [ "$CURRENT_WS_ID" = "$STASH_WS_ID" ]; then
            exit 0
          fi

          CURRENT_WS_REF="$(${niri} msg -j workspaces 2>/dev/null | ${jq} -r 'first(.[] | select(.is_focused == true) | (.name // (.idx | tostring))) // empty')"
          if [ -z "$CURRENT_WS_REF" ]; then
            exit 0
          fi

          WIN_ID="$(${niri} msg -j windows 2>/dev/null | ${jq} -r --argjson stash_ws "$STASH_WS_ID" '[.[] | select(.workspace_id == $stash_ws)] | sort_by([.focus_timestamp.secs // 0, .focus_timestamp.nanos // 0, .id]) | last | .id // empty')"
          if [ -n "$WIN_ID" ]; then
            ${niri} msg action move-window-to-workspace --window-id "$WIN_ID" "$CURRENT_WS_REF"
            ${niri} msg action focus-window --id "$WIN_ID"
          fi
        ''
      );
    in
    {
      imports = [
        inputs.self.modules.homeManager.tihdizer-niri-workspaces-chromium
        inputs.self.modules.homeManager.tihdizer-niri-workspaces-windowrules
      ];

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

        binds =
          with config.lib.niri.actions;
          lib.mkMerge [
            {
              "Mod+T".action.spawn = [ workspaceTerm ];
              "Mod+B".action.spawn = [ "chromium-workspace" ];

              "Mod+U".action = lib.mkDefault focus-workspace-down;
              "Mod+I".action = lib.mkDefault focus-workspace-up;
              "Mod+Ctrl+U".action = lib.mkDefault move-column-to-workspace-down;
              "Mod+Ctrl+I".action = lib.mkDefault move-column-to-workspace-up;

              "Mod+1".action.focus-workspace = "personal";
              "Mod+2".action.focus-workspace = "comms";
              "Mod+3".action.focus-workspace = "study";
              "Mod+4".action.focus-workspace = "work";
              "Mod+5".action.focus-workspace = "games";
              "Mod+6".action.focus-workspace = "ops";
              "Mod+7".action.focus-workspace = "media";
              "Mod+8".action.focus-workspace = 8;
              "Mod+9".action.focus-workspace = 9;
              "Mod+S".action.focus-workspace = "stash";

              "Mod+Ctrl+1".action.move-window-to-workspace = "personal";
              "Mod+Ctrl+2".action.move-window-to-workspace = "comms";
              "Mod+Ctrl+3".action.move-window-to-workspace = "study";
              "Mod+Ctrl+4".action.move-window-to-workspace = "work";
              "Mod+Ctrl+5".action.move-window-to-workspace = "games";
              "Mod+Ctrl+6".action.move-window-to-workspace = "media";
              "Mod+Ctrl+7".action.move-window-to-workspace = 7;
              "Mod+Ctrl+8".action.move-window-to-workspace = 8;
              "Mod+Ctrl+9".action.move-window-to-workspace = 9;
              "Mod+Ctrl+0".action.move-window-to-workspace = "ops";
              "Mod+Ctrl+S".action.move-window-to-workspace = [
                { focus = false; }
                "stash"
              ];
              "Mod+Shift+S".action.spawn = [ popStash ];

              "Mod+Tab".action = focus-workspace-previous;
            }
          ];
      };
    };
}
